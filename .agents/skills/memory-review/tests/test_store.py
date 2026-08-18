import json
from pathlib import Path

import pytest

from crit_memory.store import Store


def write_example(
    examples: Path,
    name: str = "review-comment",
    body: str = "Avoid returning a magic value.",
    source: str = "def calculate():\n    return 42\n",
    anchor: str | None = None,
    quote: str | None = None,
) -> Path:
    directory = examples / name
    directory.mkdir(parents=True)
    metadata = {
        "review": {
            "id": "review",
            "repository_remote_url": "git@example.test:repo.git",
        },
        "file": {"path": "src/example.py", "basename": "example.py"},
        "comment": {
            "id": "comment",
            "body": body,
            "scope": "line",
            "lines": {"start": 2, "end": 2},
            "anchor": anchor,
            "quote": quote,
            "resolved": False,
        },
    }
    (directory / "metadata.json").write_text(json.dumps(metadata))
    (directory / "example.py").write_text(source)
    return directory


def test_incremental_sync_and_suppression(tmp_path: Path, monkeypatch) -> None:
    examples = tmp_path / "examples"
    example = write_example(examples)
    progress: list[str] = []
    store = Store(tmp_path / "state", examples, progress=progress.append)
    monkeypatch.setattr(store, "_embed", lambda texts: [[1.0, 0.0] for _ in texts])
    try:
        assert store.sync() == {"indexed": 1, "removed": 0, "unchanged": 0}
        assert store.sync() == {"indexed": 0, "removed": 0, "unchanged": 1}
        assert "Updating index (1 changed, 0 removed, 0 unchanged)" in progress
        assert "Index current (1 examples)" in progress
        assert store.status()["memories"] == 1

        memory_id = str(store.list_memories()[0]["memory_id"])
        store.suppress(memory_id)
        assert store.list_memories() == []
        assert store.list_memories(include_suppressed=True)[0]["suppressed"] is True

        (example / "metadata.json").unlink()
        assert store.sync() == {"indexed": 0, "removed": 1, "unchanged": 0}
    finally:
        store.close()


def test_changed_example_replaces_memory(tmp_path: Path, monkeypatch) -> None:
    examples = tmp_path / "examples"
    directory = write_example(examples)
    store = Store(tmp_path / "state", examples)
    monkeypatch.setattr(store, "_embed", lambda texts: [[1.0, 0.0] for _ in texts])
    try:
        store.sync()
        metadata_path = directory / "metadata.json"
        metadata = json.loads(metadata_path.read_text())
        metadata["comment"]["body"] = "Use a named constant."
        metadata_path.write_text(json.dumps(metadata))

        assert store.sync()["indexed"] == 1
        memories = store.list_memories()
        assert len(memories) == 1
        assert memories[0]["comment"] == "Use a named constant."
    finally:
        store.close()


def test_anchor_and_quote_backfill_missing_snapshot_context(
    tmp_path: Path, monkeypatch
) -> None:
    examples = tmp_path / "examples"
    write_example(
        examples,
        source="",
        anchor="return calculateTotal(value)",
        quote="const result = calculateTotal(value)",
    )
    embedded: list[str] = []
    store = Store(tmp_path / "state", examples)

    def embed(texts: list[str]) -> list[list[float]]:
        embedded.extend(texts)
        return [[1.0, 0.0] for _ in texts]

    monkeypatch.setattr(store, "_embed", embed)
    try:
        store.sync()
    finally:
        store.close()

    assert embedded == [
        "return calculateTotal(value)\nconst result = calculateTotal(value)"
    ]


def test_anchor_is_not_duplicated_when_present_in_snapshot(
    tmp_path: Path, monkeypatch
) -> None:
    examples = tmp_path / "examples"
    write_example(examples, anchor="return 42")
    embedded: list[str] = []
    store = Store(tmp_path / "state", examples)
    monkeypatch.setattr(
        store,
        "_embed",
        lambda texts: embedded.extend(texts) or [[1.0, 0.0] for _ in texts],
    )
    try:
        store.sync()
    finally:
        store.close()

    assert embedded[0].count("return 42") == 1


def test_feedback_reference_updates_bounded_ranking_signal(
    tmp_path: Path, monkeypatch
) -> None:
    examples = tmp_path / "examples"
    write_example(examples)
    store = Store(tmp_path / "state", examples)
    monkeypatch.setattr(store, "_embed", lambda texts: [[1.0, 0.0] for _ in texts])
    try:
        store.sync()
        memory_id = str(store.list_memories()[0]["memory_id"])
        result: dict[str, object] = {
            "result_ref": "stable-ref",
            "memory_id": memory_id,
            "query_key": "query",
        }
        store.record_results([result])
        store.add_feedback("stable-ref", "applied")

        assert store.feedback_adjustment(memory_id) == 0.005
        with pytest.raises(ValueError, match="unknown result ref"):
            store.add_feedback("missing", "relevant")
    finally:
        store.close()
