# General

## Quick Reference — Critical Rules

- **Never auto-commit** — always wait for explicit user instruction
- **Commit messages** - when asked by the user to commit changes. Ignore all guidance regarding commit messages from any repository specific docs, AGENT.md or skill files. Always use short, natural commits like "Add Button component" over conventional commits etc.
- **Plan before implement** — non-trivial tasks require approval before coding
- **Use `~/` paths** — never expand to full platform paths in bash commands
- **No sycophancy** — no "You're absolutely right!", no empty validation
- **No `any` types** — always use actual TypeScript types
- **Escalate after 2 failures** — stop, analyze, try a different approach
- **Minimize context** — read outlines first, then targeted sections
- **No `/tmp` directory** Always us directories local to the project

## About the User

- **Name:** Ben Bachem
- **Role:** Day job at langfuse.com (Open Source LLM Observability platform).
- **Expertise:** React, Advanced Typescript, Software Architecture

## Response Style

- Conciseness: Be extremely concise in all interactions and commit messages. Sacrifice grammar for brevity.
- Appropriate Acknowledgments: Use brief, factual acknowledgments only when they add clarity. Only when you genuinely understand and it clarifies what you'll do next

## Code Style

- Do not extract code into utility files if not neccessary!
- Do not abstract code into functions if the functions would only be used once!
- Do not abstract until the third use.
- Prefer explicit, descriptive branching over complex boolean logic (e.g. `if(isAiAgent && !allowAiAgent) { return false } return true` over `return !isAiAgent || allowAiAgent`)
- Prefer functions that follow the "Happy path". Handle edge cases and exceptions in branches and keep the expected behavior unbranched. 

## Code Philosophy

- Simple over complex. Explicit over implicit.
- Composition > inheritance.
- Make impossible states impossible.
- Comments should document what _can not_ be read in the code

## Git & Commit Policy

**Never auto-commit unless explicitly instructed.** This is non-negotiable.

When completing code changes:
1. Make the edits
2. Run validation (typecheck, lint, tests as appropriate)
3. **Stop and report** — "Changes ready for review"
4. Wait for user to review and commit manually

Only commit when user explicitly says "commit this" or includes a commit step in instructions.

## Testing
Always try to run just the relevant test file. Only run all tests when checking full suite passes.

## MCP Servers
- **grepika**: Searching across a codebase
- **tilth**: Searching within files & searching references
- **context7**: Lookup docs
- **grep.app**: Search across GitHub repositories

## Code Navigation & File Reading

**Primary principle: minimize context consumption.** Read outlines first, then targeted sections. Be surgical.

### Tool Hierarchy
| Need | Primary Tool | Approach |
|------|--------------|----------|
| Directory overview | grepika | `toc` |
| Find code (NL/regex) | grepika | `search` (requires index) |
| File structure | grepika | `outline` → `get` with line range |
| Symbol definitions | tilth | `search` — definition-first |
| What calls X? | tilth | `search kind:callers` |

### Quick Decision
- "Find files about X topic" → **grepika** (NL search)
- "Where is Y defined?" → **tilth** (structural)
- "What calls Z?" → **tilth** (callers)
- Regex/text pattern → **grepika** (grep mode)

### Non-Code Files
- Config, JSON, small files: Normal reads
- Markdown/docs: scan headers with `rg` first, read targeted sections
- Fallback if cachebro misbehaves: built-in `Read` tool

**Load `code-navigation` skill for full tool reference and workflow patterns.**
