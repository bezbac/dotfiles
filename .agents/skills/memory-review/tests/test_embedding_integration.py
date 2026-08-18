import json
import os
from pathlib import Path
from typing import cast

import pytest

from crit_memory.store import MODEL_DIMENSION, Store


@pytest.mark.integration
@pytest.mark.skipif(
    os.environ.get("CRIT_MEMORY_RUN_MODEL_TEST") != "1",
    reason="set CRIT_MEMORY_RUN_MODEL_TEST=1 to download and run the real model",
)
def test_real_model_indexes_and_retrieves_memory(tmp_path: Path) -> None:
    examples = tmp_path / "examples"
    directory = examples / "review-comment"
    directory.mkdir(parents=True)
    metadata = {
        "review": {
            "id": "review",
            "repository_remote_url": "git@example.test:repo.git",
        },
        "file": {"path": "src/example.py", "basename": "example.py"},
        "comment": {
            "id": "comment",
            "body": "Validate the value before returning it.",
            "scope": "line",
            "lines": {"start": 2, "end": 2},
            "anchor": "return user_input",
            "quote": None,
            "resolved": False,
        },
    }
    (directory / "metadata.json").write_text(json.dumps(metadata))
    source = "def read_value(user_input):\n    return user_input\n"
    (directory / "example.py").write_text(source)

    state_dir = Path(
        os.environ.get("CRIT_MEMORY_MODEL_TEST_STATE", ".integration-state")
    )
    store = Store(state_dir, examples)
    try:
        assert store.sync()["indexed"] == 1
        query_vector = store.embed_queries([source])[0]
        matches = store.vector_matches(query_vector, limit=1)
    finally:
        store.close()

    assert len(query_vector) == MODEL_DIMENSION
    assert matches[0]["memory_id"] == "review:comment"
    distance = cast(float | int | str, matches[0]["distance"])
    assert float(distance) < 0.1
