from crit_memory.context import extract_context, language_for


def test_extracts_python_symbol() -> None:
    source = """def outer():
    value = 1
    return value

other = 2
"""

    context = extract_context(source, "example.py", 2, 2)

    assert context.symbol == "outer"
    assert context.start_line == 1
    assert context.end_line >= 3
    assert "return value" in context.text


def test_unknown_language_uses_bounded_window() -> None:
    source = "\n".join(f"line {number}" for number in range(1, 31))

    context = extract_context(source, "notes.unknown", 15, 16)

    assert context.start_line == 9
    assert context.end_line == 22
    assert context.symbol is None
    assert language_for("Makefile") == "text"
