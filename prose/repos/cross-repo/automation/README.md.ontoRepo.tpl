# Automation

Cross-repo automation: prose propagation, dependency graph, regen MRs, local sync.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Dependency graph

Each repo declares its own surface in `.repo/cross-repo-interface.yml`: `upstream:` consumed `<repo>/<artifact>` vertices (repo-level consumption: pipeline, worktree), `edges:` a map of upstream vertex to the list of this repo's artifacts it lands in (`go-modules/lib: [che]`), then `downstream:` produced artifacts (`name` + `type`). `bin/automation aggregate` fetches every declaration (raw GitLab API, no clones), merges them over `deps/seed-interfaces.yml` (bootstrap entries for repos not declaring yet), and renders `deps/deps-graph.yml`: generated, committed for readability, drift-checked in CI, never hand-edited. A consumed artifact nobody produces, or an edge into an artifact the repo does not produce, fails aggregation.

## Workspace assembly

`workspace/` is the che profile assembling the local workspace (moved here from configs' `gitlab/projects`): `scripts/10-clone.zsh` clones/syncs every project of each `$GITLAB_GROUPS` group into `$WORKSPACE_DIR`, `scripts/20-index.zsh` generates each subgroup's repo-index and rendered `AGENTS.md`/`CLAUDE.md` (all non-checked-out outputs), `tree/` carries the parent Makefiles and the VS Code workspace file linked onto the host. Profile names stay `gitlab/projects` / `gitlab/projects-parent-links` so host wiring repoints without renames.

## Events

Every sender reaches this repo through `centralized/assets/generic`'s `EmitEvents` CI template, forwarding one JSON `AUTOMATION_EVENT` (`type`, `source`, `details`). `dispatch-event` runs `bin/automation dispatch`, a Ruby dispatcher picking a handler by `type` and emitting the regen child pipeline (`lib/automation/`, minitest under `test/`, `make test`):

- `artifact.released` (`details: artifact, version, prev`): one `vars-write` raising the artifact's producer variable in ci-variables, consumer pins kept at `max(held, declared)`.
- `ci-variable.updated` (`details: variables: [{key, from, to}]`, sent by ci-variables' main apply from its producers diff): one lockfile MR (`.repo/upstream.env`, che renders the rest) per consumer of the moved artifact, a rebuild for consumers whose own artifact depends on it, record-only otherwise.

Nothing about producers, variables or iac is hardcoded: the graph's `ci-var/*` edges decide what a release pins and what a variable regenerates.

An unknown `type` fails the dispatch. `bin/automation graph affected|produces|consumes <vertex>` answers the graph queries.

## CLI

`bin/automation`, Ruby stdlib only, pure planning in `lib/automation/` covered by `make test`, IO in the runners:

- `aggregate [--local <workspace>] [--out <yml>] [--check]`: build `deps/deps-graph.yml` from interfaces (offline from a workspace, `--check` drift gate).
- `regen --repo <repo> --tag <tag> --producer <name> [--prev <tag>] [--workdir <dir>] [--dry-run]`: per-downstream regen: move the producer's pin, `make render-templates`, branch, MR, auto-merge when the bump is at most minor. `--dry-run --workdir <checkout>` prints the plan.
- `sweep [--dry-run]`: land `[automation]` MRs that missed their auto-merge window (arm running, merge green, leave red).
- `dispatch`, `graph`: see Events.

Tracked files change via the MR flow only. A local checkout refreshes its gitignored outputs with `make repo-render-env`, which reads each pin from its group variable.

## License

[MIT](LICENSE)
