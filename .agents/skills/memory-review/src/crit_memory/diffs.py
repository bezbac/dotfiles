from __future__ import annotations

import subprocess
from dataclasses import dataclass
from pathlib import Path

from .context import CodeContext, extract_context


@dataclass(frozen=True)
class ChangedContext:
    path: str
    language: str
    context: CodeContext


def git_diff(git_range: str | None, paths: list[str]) -> str:
    command = ["git", "diff", "--no-ext-diff", "--unified=6"]
    if git_range:
        command.append(git_range)
    else:
        command.append("HEAD")
    if paths:
        command.extend(["--", *paths])
    result = subprocess.run(command, check=False, capture_output=True, text=True)
    if result.returncode not in {0, 1}:
        raise RuntimeError(result.stderr.strip() or "git diff failed")

    patch = result.stdout
    if git_range:
        return patch

    untracked = subprocess.run(
        ["git", "ls-files", "--others", "--exclude-standard", "--", *paths],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    for path in untracked:
        file_path = Path(path)
        if not file_path.is_file():
            continue
        try:
            content = file_path.read_text()
        except UnicodeDecodeError:
            continue
        patch += _new_file_patch(path, content)
    return patch


def changed_contexts(patch: str, root: Path) -> list[ChangedContext]:
    contexts: list[ChangedContext] = []
    current_path: str | None = None
    current_source: str | None = None
    lines = patch.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        if line.startswith("+++ "):
            raw_path = line[4:].split("\t", 1)[0]
            current_path = raw_path[2:] if raw_path.startswith("b/") else raw_path
            if current_path == "/dev/null":
                current_path = None
            current_source = _read_optional(root / current_path) if current_path else None
            index += 1
            continue
        if not line.startswith("@@ ") or current_path is None:
            index += 1
            continue

        header = line.split("@@", 2)[1].strip()
        new_range = header.split()[1].removeprefix("+")
        start_text, _, count_text = new_range.partition(",")
        start = int(start_text)
        count = int(count_text or "1")
        hunk_lines: list[str] = []
        index += 1
        while index < len(lines) and not lines[index].startswith(("@@ ", "diff --git ")):
            hunk_line = lines[index]
            if hunk_line.startswith(("+", "-", " ")) and not hunk_line.startswith(("+++", "---")):
                hunk_lines.append(hunk_line[1:])
            index += 1

        fallback = "\n".join(hunk_lines).strip()
        if current_source is not None and count > 0:
            context = extract_context(current_source, current_path, start, start + count - 1)
        else:
            context = CodeContext(fallback, max(1, start), max(1, start + count - 1), None)
        if context.text.strip():
            from .context import language_for

            contexts.append(ChangedContext(current_path, language_for(current_path), context))
    return contexts


def _read_optional(path: Path) -> str | None:
    try:
        return path.read_text()
    except (FileNotFoundError, IsADirectoryError, UnicodeDecodeError):
        return None


def _new_file_patch(path: str, content: str) -> str:
    lines = content.splitlines()
    body = "\n".join(f"+{line}" for line in lines)
    return (
        f"diff --git a/{path} b/{path}\n"
        f"new file mode 100644\n--- /dev/null\n+++ b/{path}\n"
        f"@@ -0,0 +1,{len(lines)} @@\n{body}\n"
    )
