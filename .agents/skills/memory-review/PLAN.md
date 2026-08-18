# Crit Memory Plan

Build a small UV-installable `crit-memory` CLI that retrieves relevant past
Crit comments before an agent finishes code changes.

## Scope

- Read memories only from `~/.crit/examples/*/metadata.json` and the source
  snapshots beside them.
- Keep generated state under `~/.crit/memory-review/`.
- Re-index incrementally before every check; parsing and embeddings are cached.
- Generate embeddings locally in-process with FastEmbed. No daemon or API key.
- Store memories, vectors, checks, feedback, and suppressions in chDB.
- Support arbitrary text files with Tree-sitter symbol extraction where
  reliable and declaration-aware bounded windows for TypeScript/JavaScript.
- Treat file-level comments as file-level. Never invent hunks for them.
- Return JSON for agent consumption, omit weak matches, and cap output at five
  suggestions.

## CLI

```bash
crit-memory check
crit-memory check -- path/to/file.ts
crit-memory check --range main..HEAD
gh pr diff 123 | crit-memory check --diff -

crit-memory feedback <result-ref> <applied|relevant|irrelevant>
crit-memory memories
crit-memory suppress <memory-id>
crit-memory status
crit-memory rebuild
```

`check` uses staged, unstaged, and untracked working-tree changes by default.
It accepts explicit Git ranges, path filters, and arbitrary unified diffs on
stdin.

## Retrieval

For line comments, index the anchor and enclosing symbol, falling back to a
bounded line window. At check time, embed changed hunks or their enclosing
symbols and compare them with historical code contexts. Rerank weakly by
repository, path, basename, language, and contextually similar feedback.

File-level comments are matched only through genuine file identity signals.
Results include transparent score components, current context, historical
context, the exact review comment, and a stable feedback reference.

Feedback is primarily an audit trail. `applied` and `relevant` affect ranking
only as a tightly bounded tiebreaker. Suppression is stored as a tombstone and
never deletes Crit's source examples.

## Validation

- No-op sync performs no parsing or document embedding.
- Changed and removed examples update incrementally.
- Common-language symbol extraction falls back safely for arbitrary files.
- Working tree, path, range, stdin, and untracked-file input work.
- File-level comments have no fake hunks.
- Thresholding, deduplication, result cap, feedback, and suppression work.
- Real `~/.crit/examples` is used only for a read-only smoke test.

## Known Limits

- Skill invocation is best-effort.
- Memories contain criticized code, not accepted fixes.
- The coding agent interprets comments rather than learning exact rewrites.
- Retrieval quality and the initial threshold require observation in use.
- Natural-language `search` is intentionally excluded from the first version.
