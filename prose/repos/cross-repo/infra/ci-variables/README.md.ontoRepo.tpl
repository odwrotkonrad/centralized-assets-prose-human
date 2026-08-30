# ci-variables

Every **non-secret** CI variable in the `konradodwrot` group. Secrets, tokens,
SA keys and identities stay in `cross-repo/infra/iac`.

## Two scopes, two owners

| variable | scope | owner | holds |
|---|---|---|---|
| `GRP_KO_VAR_<KEY>` | group | the producer | the version it last published |
| `REPO_VAR_<KEY>` | project | that consumer | the version that consumer holds |

`<KEY>` is the artifact's `version-env-var` verbatim, the bare name from the
graph. Each scope's prefix is applied by its module and stored nowhere else, so
renaming a variable is a one-line edit in the artifact's definition.

Project values win by GitLab precedence, which is what lets one consumer sit
deliberately behind latest.

## Layout

```
templates/consumer-vars.tfvars.tpl   hand-edited, rendered by automation
modules/consumer-vars/               project scope, one instance per consumer
modules/producer-vars/               group scope, one instance total
modules/static-vars/                 group scope, the values nothing generates
live/root.hcl                        backend, provider, common inputs
live/producers/                      the group variables
live/consumers/<repo-path>/          one unit per consumer repo
live/static/                         pins and flags a human edits
```

`static/` holds the group variables no release produces: the che and
che-packages schema pins, the ci-linux image pin, and the `ENABLE_DARWIN_CI`
and `CHE_BACKUP_AUTO_CREATE` flags. Their values live in
`modules/static-vars/main.tf` as variable defaults, not in a tfvars file:
everything under `live/` that automation generates is overwritten on the next
generation, and these change only when a human decides they do.

One unit per consumer repo means a regenerated file for `notes` plans and
applies alone: it cannot surprise `go-modules`, and a broken generation for one
repo does not block every other repo's apply.

## The tfvars are generated

`generated.auto.tfvars` files are written by `cross-repo/automation` and
committed. **Never hand-edit them.** automation holds the aggregated graph, so
it is the one component that knows each consumer's version.

The template they render from lives here, beside the module that consumes them,
so the shape and its consumer are edited together.

## Adding an artifact

Both modules declare every known variable as an optional input, so a new
artifact needs an input and a resource added to `modules/consumer-vars/` and
`modules/producer-vars/`. That is a hand edit here, and deliberately so:
terraform then rejects a generated tfvars naming a variable that does not
exist, and a typo fails at plan instead of silently creating a variable nothing
reads.

## Prerequisites

Needs `terragrunt`, pinned in `oci-images/ci/tool-versions.env` and installed
in `ci-linux`. Its own terraform state, separate backend, same pattern as iac's
GCS bucket.

All targets: [assets/data/makefile.agents.md](assets/data/makefile.agents.md).

{{ renderMarkdown "assets/docs-agents/purpose.md" "strip-comments" "normalize-headings" }}
