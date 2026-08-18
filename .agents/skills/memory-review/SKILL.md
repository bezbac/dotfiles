---
name: memory-review
description: Check current code changes against past review comments before finishing implementation. Use after editing code and before the final response, or when asked to recall recurring review feedback.
---

# Memory Review

Run this after implementation and focused validation, before reporting completion:

```bash
crit-memory check
```

The command checks staged, unstaged, and untracked changes, and emits up to five JSON suggestions. Treat each result as evidence, not an instruction: the stored source is the criticized version, while `comment` explains the concern. Inspect the current code and apply a suggestion only when it is relevant.

After considering a result, record the outcome:

```bash
crit-memory feedback <result-ref> applied
crit-memory feedback <result-ref> relevant
crit-memory feedback <result-ref> irrelevant
```

Use `applied` only when the suggestion materially changed the code. Use `relevant` when it was useful but required no edit. Use `irrelevant` for a weak match.

For a Git range or external patch:

```bash
crit-memory check --range main..HEAD
gh pr diff 123 | crit-memory check --diff -
```

Do not edit files under `~/.crit/examples`; they are read-only source data.
