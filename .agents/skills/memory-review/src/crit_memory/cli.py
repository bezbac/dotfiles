from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import TYPE_CHECKING, Sequence, cast

from .diffs import changed_contexts, git_diff

if TYPE_CHECKING:
    from .store import Store


DEFAULT_THRESHOLD = 0.67


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="crit-memory")
    parser.add_argument(
        "--state-dir", type=Path, default=Path("~/.crit/memory-review").expanduser(), help=argparse.SUPPRESS
    )
    parser.add_argument(
        "--examples-dir", type=Path, default=Path("~/.crit/examples").expanduser(), help=argparse.SUPPRESS
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    check = subparsers.add_parser("check")
    check.add_argument("--range", dest="git_range")
    check.add_argument("--diff", metavar="FILE")
    check.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD)
    check.add_argument("paths", nargs="*")

    feedback = subparsers.add_parser("feedback")
    feedback.add_argument("result_ref")
    feedback.add_argument("signal", choices=["applied", "relevant", "irrelevant"])

    memories = subparsers.add_parser("memories")
    memories.add_argument("--include-suppressed", action="store_true")

    suppress = subparsers.add_parser("suppress")
    suppress.add_argument("memory_id")

    subparsers.add_parser("status")
    subparsers.add_parser("rebuild")
    return parser


def main(argv: Sequence[str] | None = None) -> None:
    args = build_parser().parse_args(argv)
    try:
        result = run(args)
    except (RuntimeError, ValueError, OSError, json.JSONDecodeError) as error:
        print(json.dumps({"error": str(error)}), file=sys.stderr)
        raise SystemExit(1) from error
    print(json.dumps(result, indent=2, default=str))


def run(args: argparse.Namespace) -> object:
    from .store import Store, rebuild_state

    if args.command == "rebuild":
        rebuild_state(args.state_dir)

    store = Store(args.state_dir, args.examples_dir, progress=_progress)
    try:
        if args.command == "rebuild":
            sync = store.sync()
            return {"rebuilt": True, "sync": sync, **store.status()}
        if args.command == "status":
            return store.status()
        if args.command == "memories":
            return {"memories": store.list_memories(args.include_suppressed)}
        if args.command == "suppress":
            store.suppress(args.memory_id)
            return {"suppressed": args.memory_id}
        if args.command == "feedback":
            store.add_feedback(args.result_ref, args.signal)
            return {"result_ref": args.result_ref, "signal": args.signal}
        if args.command == "check":
            return _check(store, args)
        raise RuntimeError(f"unsupported command: {args.command}")
    finally:
        store.close()


def _check(store: "Store", args: argparse.Namespace) -> dict[str, object]:
    sync = store.sync()
    root = _git_root()
    if args.diff:
        patch = sys.stdin.read() if args.diff == "-" else Path(args.diff).read_text()
    else:
        patch = git_diff(args.git_range, args.paths)
    contexts = changed_contexts(patch, root)
    if not contexts:
        return {"sync": sync, "suggestions": []}

    repo = _git_remote(root)
    vectors = store.embed_queries([context.context.text for context in contexts])
    candidates: dict[str, dict[str, object]] = {}
    for changed, vector in zip(contexts, vectors, strict=True):
        query_key = hashlib.sha256(
            f"{changed.path}\0{changed.context.text}".encode()
        ).hexdigest()[:16]
        for memory in store.vector_matches(vector):
            similarity = 1.0 - _float(memory.pop("distance"))
            identity = _identity_score(memory, changed.path, changed.language, repo)
            feedback = store.feedback_adjustment(str(memory["memory_id"]))
            score = similarity * 0.90 + identity + feedback
            if score < args.threshold:
                continue
            result = _result(memory, changed.path, changed.context.text, query_key, score, similarity, identity, feedback)
            previous = candidates.get(str(memory["memory_id"]))
            if previous is None or _float(result["score"]) > _float(previous["score"]):
                candidates[str(memory["memory_id"])] = result

        for memory in store.file_matches(changed.path, changed.language, repo):
            identity = _identity_score(memory, changed.path, changed.language, repo)
            feedback = store.feedback_adjustment(str(memory["memory_id"]))
            score = identity + feedback
            if score < args.threshold:
                continue
            result = _result(memory, changed.path, "", query_key, score, None, identity, feedback)
            previous = candidates.get(str(memory["memory_id"]))
            if previous is None or _float(result["score"]) > _float(previous["score"]):
                candidates[str(memory["memory_id"])] = result

    suggestions = sorted(candidates.values(), key=lambda item: _float(item["score"]), reverse=True)[:5]
    for index, suggestion in enumerate(suggestions):
        ref_material = f"{suggestion['memory_id']}\0{suggestion['query_key']}\0{index}"
        suggestion["result_ref"] = hashlib.sha256(ref_material.encode()).hexdigest()[:20]
    store.record_results(suggestions)
    return {"sync": sync, "suggestions": suggestions}


def _result(
    memory: dict[str, object],
    current_path: str,
    current_context: str,
    query_key: str,
    score: float,
    similarity: float | None,
    identity: float,
    feedback: float,
) -> dict[str, object]:
    return {
        "memory_id": memory["memory_id"],
        "result_ref": "",
        "query_key": query_key,
        "score": round(score, 4),
        "score_components": {
            "semantic_similarity": None if similarity is None else round(similarity, 4),
            "identity": round(identity, 4),
            "feedback": round(feedback, 4),
        },
        "current": {"path": current_path, "context": current_context},
        "historical": {
            "repo": memory["repo"],
            "path": memory["path"],
            "scope": memory["scope"],
            "lines": [memory["context_start"], memory["context_end"]],
            "symbol": memory["symbol"],
            "context": memory["context"],
        },
        "comment": memory["comment"],
        "resolved": bool(memory["resolved"]),
    }


def _identity_score(memory: dict[str, object], path: str, language: str, repo: str) -> float:
    score = 0.0
    if memory["repo"] and memory["repo"] == repo:
        score += 0.05
    if memory["path"] == path:
        score += 0.72 if memory["scope"] == "file" else 0.04
    elif memory["basename"] == Path(path).name:
        score += 0.67 if memory["scope"] == "file" else 0.025
    if memory["language"] == language:
        score += 0.02
    return min(score, 0.79)


def _float(value: object) -> float:
    return float(cast(float | int | str, value))


def _progress(message: str) -> None:
    print(f"[crit-memory] {message}", file=sys.stderr, flush=True)


def _git_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], check=False, capture_output=True, text=True
    )
    if result.returncode != 0:
        return Path.cwd()
    return Path(result.stdout.strip())


def _git_remote(root: Path) -> str:
    result = subprocess.run(
        ["git", "config", "--get", "remote.origin.url"],
        cwd=root,
        check=False,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


if __name__ == "__main__":
    main()
