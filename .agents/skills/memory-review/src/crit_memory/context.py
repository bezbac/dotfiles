from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


LANGUAGES = {
    ".js": "javascript",
    ".jsx": "javascript",
    ".ts": "typescript",
    ".tsx": "tsx",
    ".py": "python",
    ".rs": "rust",
}

SYMBOL_TYPES = {
    "function_declaration",
    "function_definition",
    "method_definition",
    "method_declaration",
    "class_declaration",
    "class_definition",
    "interface_declaration",
    "lexical_declaration",
    "impl_item",
    "function_item",
    "struct_item",
    "trait_item",
}


@dataclass(frozen=True)
class CodeContext:
    text: str
    start_line: int
    end_line: int
    symbol: str | None


def language_for(path: str) -> str:
    suffix = Path(path).suffix.lower()
    return LANGUAGES.get(suffix, suffix.removeprefix(".") or "text")


def extract_context(source: str, path: str, start_line: int, end_line: int) -> CodeContext:
    lines = source.splitlines()
    if not lines:
        return CodeContext("", 1, 1, None)

    start_line = max(1, min(start_line, len(lines)))
    end_line = max(start_line, min(end_line, len(lines)))
    tree_context = _tree_sitter_context(source, path, start_line, end_line)
    if tree_context is not None:
        return tree_context

    window_start = max(1, start_line - 6)
    window_end = min(len(lines), end_line + 6)
    symbol = None
    declaration = re.compile(
        r"(?:class|def|fn|function|interface|struct|trait|impl)\s+([\w$]+)"
    )
    for line in reversed(lines[window_start - 1 : start_line]):
        match = declaration.search(line)
        if match:
            symbol = match.group(1)
            break
    return CodeContext(
        "\n".join(lines[window_start - 1 : window_end]),
        window_start,
        window_end,
        symbol,
    )


def _tree_sitter_context(
    source: str, path: str, start_line: int, end_line: int
) -> CodeContext | None:
    language = language_for(path)
    # The language-pack TS/TSX bindings can deadlock while walking parent nodes.
    # Keep checks reliable and use the declaration-aware window fallback there.
    if language not in {"python", "rust"}:
        return None

    try:
        from tree_sitter_language_pack import get_parser

        tree = get_parser(language).parse(source.encode())
    except (ImportError, LookupError, ValueError):
        return None

    target_start = start_line - 1
    target_end = end_line - 1
    best: tuple[int, int, int, int] | None = None
    node = tree.root_node.named_descendant_for_point_range(
        (target_start, 0), (target_start, 0)
    )
    while node is not None:
        if node.type in SYMBOL_TYPES and node.end_point.row >= target_end:
            best = (
                node.start_byte,
                node.end_byte,
                node.start_point.row,
                node.end_point.row,
            )
            break
        node = node.parent

    if best is None:
        return None

    start_byte, end_byte, start_row, end_row = best
    text = source.encode()[start_byte:end_byte].decode(errors="replace")
    first_line = text.splitlines()[0] if text else ""
    symbol_match = re.search(r"(?:class|def|fn|function|interface|struct|trait|impl)\s+([\w$]+)", first_line)
    symbol = symbol_match.group(1) if symbol_match else first_line.strip()[:120] or None
    return CodeContext(text, start_row + 1, end_row + 1, symbol)
