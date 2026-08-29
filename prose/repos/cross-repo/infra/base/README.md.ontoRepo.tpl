# base

The GCP org foundation, every machine identity, every secret, the GitLab tree, the terraform state buckets and the artifact registries, as Terraform.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Applied locally, never by CI

Every mutation runs under your own admin identity, from your machine. The
pipeline authenticates as `base-publisher`, which holds
`roles/storage.objectViewer` on the state bucket and nothing else, and does one
thing: publish the applied outputs as a release artifact.

The rule is enforced by permissions, not discipline. A `plan` or `apply` job
added here fails on the state lock, because writing the lock needs object
write. That failure is the guardrail working.

| principal | on `konradodwrot-base-tfstate` |
|---|---|
| you (admin) | write: plans and applies, locally, only |
| `base-publisher` | custom role, object get/list: read only |
| every other CI identity | nothing |

## Drift detection is a local habit

No CI plan job means no automatic drift report. Run `make plan` before cutting
a release.

## Six submodules, one state

- **`tf/org/`** — folders, project services, the budget and its notification
  channel, the three project shells (`main`, `ci`, `sandbox-auth`), and the
  1Password vaults identities are scoped to.
- **`tf/iam/`** — every machine identity and the custom role it holds: a
  protected/unprotected applier pair per CI-applied repo, `base-publisher`, the
  cluster service accounts and their workload identity bindings, the GitLab
  group and project tokens, the sandbox identity, the release-signing GPG key.
- **`tf/secrets/`** — every secret in the group, routed by audience: 1Password
  for personal use, Secret Manager for automation, masked CI variables for CI.
  Nothing anywhere else creates a secret.
- **`tf/git-repositories/`** — the GitLab tree: groups, projects, protections,
  GitHub mirrors. The containers identities are scoped to, so they sit beside
  the identities.
- **`tf/tfstate-buckets/`** — one bucket per CI-applied repo, granting that
  repo's protected applier object write-read and its unprotected applier
  read-only, on that bucket alone.
- **`tf/artifact-registry/`** — every registry: `ci`, the three `remote-*`
  pull-through caches, and the generic repository holding this repo's own
  release artifact.

Terraform's graph orders them. One apply.

## Custom roles everywhere

Every identity holds a custom role with an explicit permission list, bound at
the narrowest resource: no predefined role, no `*.admin`. Each list is derived
from the predefined role it replaces (`gcloud iam roles describe roles/<name>`)
and then cut down.

The proof a list is complete is a full `make plan` under the identity that
holds it.

## State bucket bootstrap (one-time)

A bucket cannot hold the state that creates it, so base's own is made by CLI
with your admin identity:

```sh
gcloud storage buckets create gs://konradodwrot-base-tfstate \
  --project=main-493613 --location=EU --uniform-bucket-level-access
gcloud storage buckets update gs://konradodwrot-base-tfstate --versioning
```

Both commands, not just the first: `tf/tfstate-buckets/` sets versioning on
every bucket it creates, and this one is made by hand, so it has to be turned on
by hand too. Without it the state holding every identity in the group is the one
state with no previous generation to recover.

Every other state bucket is created by `tf/tfstate-buckets/`.
`konradodwrot-ci-variables-tfstate` predates this repo and is adopted with an
`import` block rather than created.

## The GitHub org deploy-key policy

Push mirrors authenticate with a deploy key per repository, which an
organization can forbid outright. `tf/org/github-org-policy.tf` sets that
policy through a `null_resource` running `gh`, rather than a provider resource:
`github_organization_settings` does not expose the field, and adopting it to
reach one setting would put 26 others under terraform at their provider
defaults, rewriting settings nobody asked it to manage.

The provisioner reads the live value first and writes only when it differs, so
a re-apply is a no-op rather than a pointless PATCH, and it re-reads afterwards
so an API that accepts a field it ignores fails loudly.

The setting is org-wide: GitHub offers no per-repository override. It permits a
deploy key on every repository in the org, still narrower than what it
replaces, a personal access token embedded in each mirror url and able to reach
everything that token can.

Each bucket carries two bindings, matching its repo's identity pair:

| identity | on its own bucket |
|---|---|
| protected (write-read) | custom role: object get, list, create, delete |
| unprotected (read-only) | custom role: object get, list |

Neither reaches another repo's bucket.

## Rotating a secret

```sh
terraform taint <resource>
make apply     # rewrites the consumer's CI variable in place
make release   # secrets_hash moved, so this mints a tag and publishes
```

Consumers pick the new value up on their next pipeline: the CI variable changed
under them, so no pin bump is involved. The tag exists so the rotation is
recorded and `emit-events` can announce it.

## The published artifact

A semver release publishes a package to the generic artifact registry
repository, holding one `base.auto.tfvars`:

```
europe-docker.pkg.dev/<proj>/ci-generic/base-outputs:v0.1.0
  -> base.auto.tfvars
     gcp_org_id, main_project_id, ci_project_id,
     sandbox_auth_project_id, sandbox_folder_id, dev_folder_name,
     artifact_registry hostnames (x4),
     runner_sa_email, ci_job_sa_email, node_sa_email,
     secrets_hash
```

Non-secret identifiers only. Keys and tokens stay in Secret Manager and
1Password and reach consumers as masked CI variables.

`secrets_hash` is the one secret-derived value: a hash over every secret, never
a secret itself. It exists so a rotation shows up as a changed output, which is
what makes `make release` mint a tag for it.

Consumers render it via che `renderTemplates` at a pinned `BASE_REF`, a group
variable published by `cross-repo/infra/ci-variables`. Bucket names need no
output: they follow `konradodwrot-<repo>-tfstate`, so each consumer's backend
block names its own.

Cut a tag after a local apply changes an output. `cross-repo/automation` fans
out the pin MRs.

## Moving a resource in from another root

Import here first, then forget there. Never the reverse, never a destroy.

```sh
# 1. import block with the real id, in this repo
terraform -chdir=tf plan          # until import-only, zero change
terraform -chdir=tf apply         # resource now in both states

# 2. removed block in the old root
#    removed { from = … lifecycle { destroy = false } }
#    plan must show forget, never destroy
```

Check every plan before applying:

```sh
terraform show -json tf/plan.tfplan | jq '[.resource_changes[] | select(.change.actions | index("delete"))]'
```

`[]` is the only acceptable result.

## License

[MIT](LICENSE)
