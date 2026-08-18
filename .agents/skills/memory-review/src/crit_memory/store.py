from __future__ import annotations

import hashlib
import json
import os
import shutil
from dataclasses import asdict, dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Callable, Iterable, Sequence, cast

from chdb import dbapi

from .context import extract_context, language_for


MODEL_NAME = "BAAI/bge-small-en-v1.5"
MODEL_DIMENSION = 384


@dataclass(frozen=True)
class Memory:
    memory_id: str
    source_key: str
    source_fingerprint: str
    review_id: str
    comment_id: str
    repo: str
    path: str
    basename: str
    language: str
    scope: str
    comment: str
    context: str
    context_start: int
    context_end: int
    symbol: str | None
    resolved: bool


class Store:
    def __init__(
        self,
        state_dir: Path,
        examples_dir: Path,
        progress: Callable[[str], None] | None = None,
    ):
        self.state_dir = state_dir
        self.examples_dir = examples_dir
        self.progress = progress or (lambda _message: None)
        state_dir.mkdir(parents=True, exist_ok=True)
        os.environ.setdefault("FASTEMBED_CACHE_PATH", str(state_dir / "models"))
        self.connection = dbapi.connect(str(state_dir / "index.chdb"))
        self.cursor = self.connection.cursor()
        self.cursor.execute("SET mutations_sync = 1")
        self._create_schema()

    def close(self) -> None:
        self.cursor.close()
        self.connection.close()

    def _create_schema(self) -> None:
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS memories (
                memory_id String, source_key String, source_fingerprint String,
                review_id String, comment_id String, repo String, path String,
                basename String, language String, scope String, comment String,
                context String, context_start UInt32, context_end UInt32,
                symbol Nullable(String), resolved Bool,
                embedding Array(Float32), indexed_at DateTime64(3, 'UTC')
            ) ENGINE = MergeTree ORDER BY memory_id
            """
        )

        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS feedback (
                result_ref String, memory_id String, signal Enum8('applied'=1,'relevant'=2,'irrelevant'=3),
                query_key String, created_at DateTime64(3, 'UTC')
            ) ENGINE = MergeTree ORDER BY (memory_id, created_at)
            """
        )
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS results (
                result_ref String, memory_id String, query_key String,
                payload String, created_at DateTime64(3, 'UTC')
            ) ENGINE = MergeTree ORDER BY result_ref
            """
        )
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS suppressions (
                memory_id String, created_at DateTime64(3, 'UTC')
            ) ENGINE = MergeTree ORDER BY memory_id
            """
        )
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS settings (
                key String, value String
            ) ENGINE = ReplacingMergeTree ORDER BY key
            """
        )

    def _fetchall(
        self, query: str, parameters: tuple[object, ...] = ()
    ) -> tuple[tuple[object, ...], ...]:
        self.cursor.execute(query, parameters)
        return self.cursor.fetchall()

    def _fetchone(
        self, query: str, parameters: tuple[object, ...] = ()
    ) -> tuple[object, ...] | None:
        self.cursor.execute(query, parameters)
        return self.cursor.fetchone()

    def sync(self) -> dict[str, int]:
        self.progress(f"Scanning {self.examples_dir}")
        discovered = self._discover()
        existing_rows = self._fetchall(
            "SELECT source_key, any(source_fingerprint) FROM memories GROUP BY source_key"
        )
        existing = {str(row[0]): str(row[1]) for row in existing_rows}
        changed = [item for item in discovered if existing.get(item[0]) != item[1]]
        removed = sorted(set(existing) - {item[0] for item in discovered})
        if not changed and not removed:
            self.progress(f"Index current ({len(discovered)} examples)")
            return {"indexed": 0, "removed": 0, "unchanged": len(discovered)}

        self.progress(
            f"Updating index ({len(changed)} changed, {len(removed)} removed, "
            f"{len(discovered) - len(changed)} unchanged)"
        )
        memories = [self._load_memory(path, fingerprint) for path, fingerprint in changed]
        embeddings = self._embed([memory.context for memory in memories if memory.scope != "file"])
        embedding_iter = iter(embeddings)
        changed_keys = [path for path, _ in changed]
        for source_key in [*changed_keys, *removed]:
            self.cursor.execute("ALTER TABLE memories DELETE WHERE source_key = ?", (source_key,))

        now = datetime.now(UTC)
        rows = []
        for memory in memories:
            embedding = [] if memory.scope == "file" else next(embedding_iter)
            rows.append((*asdict(memory).values(), json.dumps(embedding), now))
        if rows:
            self.cursor.executemany(
                """
                INSERT INTO memories VALUES (
                    ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,
                    JSONExtract(?, 'Array(Float32)'),?
                )
                """,
                rows,
            )
        self._set_setting("model", MODEL_NAME)
        self._set_setting("dimension", str(MODEL_DIMENSION))
        return {
            "indexed": len(changed),
            "removed": len(removed),
            "unchanged": len(discovered) - len(changed),
        }

    def _discover(self) -> list[tuple[str, str]]:
        if not self.examples_dir.is_dir():
            return []
        found = []
        for metadata_path in sorted(self.examples_dir.glob("*/metadata.json")):
            source_files = sorted(path for path in metadata_path.parent.iterdir() if path.name != "metadata.json")
            digest = hashlib.sha256(metadata_path.read_bytes())
            for source_file in source_files:
                if source_file.is_file():
                    digest.update(source_file.name.encode())
                    digest.update(source_file.read_bytes())
            found.append((str(metadata_path.parent), digest.hexdigest()))
        return found

    def _load_memory(self, source_key: str, fingerprint: str) -> Memory:
        directory = Path(source_key)
        metadata = json.loads((directory / "metadata.json").read_text())
        source_files = sorted(path for path in directory.iterdir() if path.name != "metadata.json" and path.is_file())
        source = ""
        if source_files:
            try:
                source = source_files[0].read_text()
            except UnicodeDecodeError:
                source = ""

        comment = metadata["comment"]
        file_data = metadata["file"]
        scope = str(comment.get("scope", "line")).lower()
        line_data = comment.get("lines") or {}
        start = int(line_data.get("start") or 1)
        end = int(line_data.get("end") or start)
        if scope == "file":
            context_text, context_start, context_end, symbol = "", 0, 0, None
        else:
            context = extract_context(source, str(file_data["path"]), start, end)
            context_text = context.text
            context_start = context.start_line
            context_end = context.end_line
            symbol = context.symbol
            for fallback in (comment.get("anchor"), comment.get("quote")):
                fallback_text = str(fallback or "").strip()
                if fallback_text and fallback_text not in context_text:
                    context_text = "\n".join(filter(None, (context_text, fallback_text)))
        review_id = str(metadata["review"]["id"])
        comment_id = str(comment["id"])
        return Memory(
            memory_id=f"{review_id}:{comment_id}",
            source_key=source_key,
            source_fingerprint=fingerprint,
            review_id=review_id,
            comment_id=comment_id,
            repo=str(metadata["review"].get("repository_remote_url") or ""),
            path=str(file_data["path"]),
            basename=str(file_data.get("basename") or Path(file_data["path"]).name),
            language=language_for(str(file_data["path"])),
            scope=scope,
            comment=str(comment["body"]),
            context=context_text,
            context_start=context_start,
            context_end=context_end,
            symbol=symbol,
            resolved=bool(comment.get("resolved")),
        )

    def _embed(self, texts: Sequence[str]) -> list[list[float]]:
        if not texts:
            return []
        from fastembed import TextEmbedding

        self.progress(
            f"Loading {MODEL_NAME}; first run downloads and caches the model"
        )
        model = TextEmbedding(model_name=MODEL_NAME, cache_dir=str(self.state_dir / "models"))
        self.progress(f"Embedding {len(texts)} code contexts")
        embeddings = []
        for index, embedding in enumerate(model.embed(list(texts)), start=1):
            embeddings.append(embedding.tolist())
            self.progress(f"Embedded {index}/{len(texts)} code contexts")
        return embeddings

    def vector_matches(self, embedding: list[float], limit: int = 20) -> list[dict[str, object]]:
        rows = self._fetchall(
            """
            SELECT m.*, cosineDistance(m.embedding, JSONExtract(?, 'Array(Float32)')) AS distance
            FROM memories AS m
            LEFT ANTI JOIN suppressions AS s ON m.memory_id = s.memory_id
            WHERE m.scope != 'file' AND length(m.embedding) > 0
            ORDER BY distance ASC LIMIT ?
            """,
            (json.dumps(embedding), limit),
        )
        columns = [description[0] for description in self.cursor.description]
        return [dict(zip(columns, row, strict=True)) for row in rows]

    def file_matches(self, path: str, language: str, repo: str) -> list[dict[str, object]]:
        rows = self._fetchall(
            """
            SELECT m.* FROM memories AS m
            LEFT ANTI JOIN suppressions AS s ON m.memory_id = s.memory_id
            WHERE m.scope = 'file' AND (m.path = ? OR m.basename = ? OR m.language = ? OR m.repo = ?)
            """,
            (path, Path(path).name, language, repo),
        )
        columns = [description[0] for description in self.cursor.description]
        return [dict(zip(columns, row, strict=True)) for row in rows]

    def embed_queries(self, texts: Sequence[str]) -> list[list[float]]:
        return self._embed(texts)

    def feedback_adjustment(self, memory_id: str) -> float:
        rows = self._fetchall(
            """
            SELECT signal, count() FROM feedback WHERE memory_id = ? GROUP BY signal
            """,
            (memory_id,),
        )
        counts = {str(signal): _int(count) for signal, count in rows}
        raw = counts.get("applied", 0) + counts.get("relevant", 0) - counts.get("irrelevant", 0)
        return max(-0.02, min(0.02, raw * 0.005))

    def record_results(self, results: Iterable[dict[str, object]]) -> None:
        now = datetime.now(UTC)
        rows = [
            (result["result_ref"], result["memory_id"], result["query_key"], json.dumps(result), now)
            for result in results
        ]
        if rows:
            self.cursor.executemany("INSERT INTO results VALUES (?,?,?,?,?)", rows)

    def add_feedback(self, result_ref: str, signal: str) -> None:
        row = self._fetchone(
            "SELECT memory_id, query_key FROM results WHERE result_ref = ? ORDER BY created_at DESC LIMIT 1",
            (result_ref,),
        )
        if row is None:
            raise ValueError(f"unknown result ref: {result_ref}")
        self.cursor.execute(
            "INSERT INTO feedback VALUES (?,?,?,?,?)",
            (result_ref, row[0], signal, row[1], datetime.now(UTC)),
        )

    def suppress(self, memory_id: str) -> None:
        exists = self._fetchone(
            "SELECT 1 FROM memories WHERE memory_id = ? LIMIT 1", (memory_id,)
        )
        if exists is None:
            raise ValueError(f"unknown memory: {memory_id}")
        self.cursor.execute(
            "INSERT INTO suppressions VALUES (?,?)", (memory_id, datetime.now(UTC))
        )

    def list_memories(self, include_suppressed: bool = False) -> list[dict[str, object]]:
        join = "LEFT JOIN" if include_suppressed else "LEFT ANTI JOIN"
        rows = self._fetchall(
            f"""
            SELECT m.memory_id, m.repo, m.path, m.scope, m.comment, m.resolved,
                   if(s.memory_id = '', false, true) AS suppressed
            FROM memories AS m {join} suppressions AS s ON m.memory_id = s.memory_id
            ORDER BY m.path, m.memory_id
            """
        )
        columns = [description[0] for description in self.cursor.description]
        return [dict(zip(columns, row, strict=True)) for row in rows]

    def status(self) -> dict[str, object]:
        memory_count = self._count("SELECT count() FROM memories")
        suppressed = self._count("SELECT uniq(memory_id) FROM suppressions")
        feedback = self._count("SELECT count() FROM feedback")
        return {
            "examples_dir": str(self.examples_dir),
            "state_dir": str(self.state_dir),
            "memories": memory_count,
            "suppressed": suppressed,
            "feedback": feedback,
            "model": MODEL_NAME,
            "dimension": MODEL_DIMENSION,
        }

    def _count(self, query: str) -> int:
        row = self._fetchone(query)
        if row is None:
            return 0
        return _int(row[0])

    def _set_setting(self, key: str, value: str) -> None:
        self.cursor.execute("INSERT INTO settings VALUES (?,?)", (key, value))


def rebuild_state(state_dir: Path) -> None:
    if state_dir.exists():
        shutil.rmtree(state_dir)


def _int(value: object) -> int:
    return int(cast(int | str, value))
