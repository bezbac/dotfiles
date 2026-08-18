import argparse
import io
from pathlib import Path
from typing import cast

from crit_memory.cli import _check, _identity_score, build_parser


PATCH = """diff --git a/src/current.py b/src/current.py
--- a/src/current.py
+++ b/src/current.py
@@ -0,0 +1,2 @@
+def current():
+    return True
"""


def memory(number: int, *, scope: str = "line", distance: float = 0.1) -> dict[str, object]:
    return {
        "memory_id": f"review:comment-{number}",
        "repo": "repo",
        "path": "src/current.py",
        "basename": "current.py",
        "language": "python",
        "scope": scope,
        "comment": f"Comment {number}",
        "context": "def historical():\n    return False" if scope == "line" else "",
        "context_start": 1 if scope == "line" else 0,
        "context_end": 2 if scope == "line" else 0,
        "symbol": "historical" if scope == "line" else None,
        "resolved": False,
        "distance": distance,
    }


class FakeStore:
    def __init__(
        self,
        vector_memories: list[dict[str, object]] | None = None,
        file_memories: list[dict[str, object]] | None = None,
    ) -> None:
        self.vector_memories = vector_memories or []
        self.file_memories = file_memories or []
        self.recorded: list[dict[str, object]] = []

    def sync(self) -> dict[str, int]:
        return {"indexed": 0, "removed": 0, "unchanged": 1}

    def embed_queries(self, texts: list[str]) -> list[list[float]]:
        return [[1.0, 0.0] for _ in texts]

    def vector_matches(self, _embedding: list[float]) -> list[dict[str, object]]:
        return [item.copy() for item in self.vector_memories]

    def file_matches(
        self, _path: str, _language: str, _repo: str
    ) -> list[dict[str, object]]:
        return [item.copy() for item in self.file_memories]

    def feedback_adjustment(self, _memory_id: str) -> float:
        return 0.0

    def record_results(self, results: list[dict[str, object]]) -> None:
        self.recorded = results


def test_check_parses_paths_after_separator() -> None:
    args = build_parser().parse_args(["check", "--range", "main..HEAD", "--", "src/a.ts"])

    assert isinstance(args, argparse.Namespace)
    assert args.git_range == "main..HEAD"
    assert args.paths == ["src/a.ts"]


def test_file_identity_requires_real_identity_signal() -> None:
    memory: dict[str, object] = {
        "repo": "repo",
        "path": "src/a.ts",
        "basename": "a.ts",
        "language": "typescript",
        "scope": "file",
    }

    assert _identity_score(memory, "src/a.ts", "typescript", "repo") >= 0.67
    assert _identity_score(memory, "src/other.py", "python", "other") == 0.0


def test_stdin_patch_thresholds_deduplicates_and_caps_results(
    tmp_path: Path, monkeypatch
) -> None:
    candidates = [memory(number) for number in range(7)]
    candidates.append(memory(0))
    candidates.append(memory(99, distance=0.8))
    store = FakeStore(vector_memories=candidates)
    args = argparse.Namespace(diff="-", git_range=None, paths=[], threshold=0.67)
    monkeypatch.setattr("sys.stdin", io.StringIO(PATCH))
    monkeypatch.setattr("crit_memory.cli._git_root", lambda: tmp_path)
    monkeypatch.setattr("crit_memory.cli._git_remote", lambda _root: "repo")

    result = _check(store, args)  # type: ignore[arg-type]
    suggestions = cast(list[dict[str, object]], result["suggestions"])

    assert isinstance(suggestions, list)
    assert len(suggestions) == 5
    assert len({item["memory_id"] for item in suggestions}) == 5
    assert all(item["memory_id"] != "review:comment-99" for item in suggestions)
    assert all(len(str(item["result_ref"])) == 20 for item in suggestions)
    assert store.recorded == suggestions


def test_file_level_result_has_no_invented_context(tmp_path: Path, monkeypatch) -> None:
    file_memory = memory(1, scope="file")
    file_memory.pop("distance")
    store = FakeStore(file_memories=[file_memory])
    args = argparse.Namespace(diff="-", git_range=None, paths=[], threshold=0.67)
    monkeypatch.setattr("sys.stdin", io.StringIO(PATCH))
    monkeypatch.setattr("crit_memory.cli._git_root", lambda: tmp_path)
    monkeypatch.setattr("crit_memory.cli._git_remote", lambda _root: "repo")

    result = _check(store, args)  # type: ignore[arg-type]
    suggestions = cast(list[dict[str, object]], result["suggestions"])
    suggestion = suggestions[0]
    current = cast(dict[str, object], suggestion["current"])
    historical = cast(dict[str, object], suggestion["historical"])

    assert current["context"] == ""
    assert historical["context"] == ""
    assert historical["lines"] == [0, 0]
