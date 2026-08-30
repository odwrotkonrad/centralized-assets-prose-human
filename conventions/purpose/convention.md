# Purpose Convention

Every repo's purpose doc is authored in `cross-repo/prose/assets` at `repos/<repo-path>/purpose.md` and rendered into the repo as `assets/docs-agents/purpose.md` (gitignored, rendered on demand at the pinned `PROSE_ASSETS_REF`). Three headings, in order:

1. What it is: concise repo description, keyword-dense.
2. Why it exists: the need, the creator's intent.
3. Goals: what it achieves, high level.

## Example

Skeleton in `example/`: `assets/docs-agents/purpose.md` with the three headings, `@`-included by `AGENTS.md` and `CLAUDE.md`, inlined in `README.md`.

## Placement

Top of `AGENTS.md`, `CLAUDE.md`, `README.md`:

- Agent files: `@assets/docs-agents/purpose.md` include.
- `README.md`: template include or inline.
