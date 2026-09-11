---
name: knowledge-review
description: "Self-critique code changes against applicable entries in the shared knowledge base. Use after making changes and before reporting completion."
---

# Knowledge review

Review changes against the knowledge entries in `~/dev/repos/bezbac/knowledge/patterns`.

## Workflow

1. Identify the repository and review target. Prefer the uncommitted diff when it is non-empty. If the worktree is clean on a feature branch, review the branch diff against its merge base with the default branch; do not conclude that there are no changes solely because the worktree is clean.
2. List the changed files from that target. Review the diff, not the entire codebase.
3. For each knowledge entry, initially read only its frontmatter and opening rule paragraph. Use explicit line ranges so a smart file reader cannot return the entire entry automatically.
4. Discard entries whose scope does not match:
   - `repositories`: an empty list applies to every repository; otherwise the current repository must match an entry.
   - `paths`: at least one changed file must match a repo-root-relative glob.
5. Record which entries apply and which changed files each one covers. Load each entry only once.
6. Compare the changed code with every applicable opening rule. Record a disposition for each applicable entry: violated, not violated, or ambiguous.
7. Read the rest of an entry only when the diff appears to violate its rule or applicability is ambiguous. Use its rationale, examples, and boundaries to confirm or reject the finding.
8. Fix confirmed violations when editing is allowed, then review the resulting diff once more. In review-only or plan mode, report them instead.

## Required output

Always include a compact review record, even when there are no findings:

- The reviewed diff target.
- The applicable knowledge entries. Group entries when they have the same disposition.
- Every confirmed finding with its changed file and knowledge-entry citation.
- An explicit statement when no applicable entry is violated.

Do not replace this record with a bare statement such as “no violations found.”

## Constraints

- Do not read full entries speculatively.
- Do not review unchanged code unless necessary to understand a changed line.
- Do not introduce generic review criteria that are absent from the applicable knowledge entries.
- Do not report a finding until the complete entry, including its boundaries, has confirmed it.
- Cite the changed file and the knowledge entry for every finding.
- If no applicable rule is violated, state that concisely.
