# CI Variables Convention

<!-- [>] 🤖🤖 -->

Every CI/CD variable GitLab injects carries a prefix naming the scope that
defines it:

- `GRP_<MNEMONIC>_VAR_`: defined on a group, readable by every repo under it.
  The mnemonic names the group.
- `REPO_VAR_`: defined on one project. The repo goes unnamed: the variable is
  visible only inside it.

Group mnemonics:

| group | mnemonic | prefix |
|---|---|---|
| `konradodwrot` | `KO` | `GRP_KO_VAR_` |

A subgroup defining its first variable adds a row here, in the same MR.

The prefix says where a value comes from and where to change it. An unprefixed
name is defined by the pipeline itself.

Non-secret variables are declared in `cross-repo/infra/ci-variables`, secrets
and identity variables in `cross-repo/infra/base`, beside the resource that
owns the value. Never clicked into the UI. A key in GitLab and in neither repo
is drift: import or delete it.

## Identity Variables Name Their Protection

A variable carrying a credential states its protection in the prefix, because
which of a pair a pipeline gets depends on the branch it runs on, and a name
that hides that reads as one variable behaving inconsistently:

```
REPO_PROTECTED_VAR_BOT_GITLAB_TOKEN
REPO_UNPROTECTED_VAR_BOT_GITLAB_TOKEN
GRP_KO_PROTECTED_VAR_BOT_GITLAB_TOKEN
REPO_PROTECTED_VAR_GOOGLE_CREDENTIALS
```

`BOT` marks a GitLab group or repo access token, and only that. A credential
that is not a GitLab token carries no `BOT`.

A protected variable expands empty off a protected branch. That is the point:
a read-only unprotected identity serves MR pipelines, its protected twin serves
main. Pairing them under one bare name in the remap keeps the pipeline reading
one name while GitLab decides which value it gets.

Non-secret variables keep the plain `GRP_<MNEMONIC>_VAR_` / `REPO_VAR_` form:
there is no pair, so there is nothing to distinguish.

## In The Dependency Graph

A CI variable crosses repo boundaries, so it is an artifact. The repo that
owns the value declares it downstream as `ci-var/<name>`, type `ci-variable`.
Every repo reading it names that producer upstream:

```yaml
# cross-repo/infra/ci-variables/.repo/downstream.yml
downstream:
  - {name: ci-var/ci-images-ref, type: ci-variable}

# a consumer's .repo/upstream.yml
upstream:
  - cross-repo/infra/ci-variables/ci-var/ci-images-ref
```

The declaration answers, without grep: who reads this, what breaks if it
changes. Automation's aggregation enforces the pair: an upstream naming a
variable nobody produces fails the build.

Name the artifact for the value, not the variable: `ci-var/artifact-registry`
covers `GRP_KO_VAR_ARTIFACT_REGISTRY` and its two proxy variables, produced and
consumed as one. One artifact per value that moves independently, not per
GitLab key. A renamed prefix renames no artifact.

## Remapping At The Boundary

A prefixed name is read once. Each pipeline assigns every injected variable it
consumes to the bare name, at the boundary. Past it, jobs, scripts, Makefiles
and tools read the bare name only.

```yaml
variables:
  ARTIFACT_REGISTRY: $GRP_KO_VAR_ARTIFACT_REGISTRY
  CI_IMAGES_REF: $GRP_KO_VAR_CI_IMAGES_REF
  CHE_PACKAGES_REF: $GRP_KO_VAR_CHE_PACKAGES_REF
  CI_IMAGE: $ARTIFACT_REGISTRY/ci-linux:$CI_IMAGES_REF
```

One value, two variables:

- the **prefixed** one, declared by the repo owning the value, injected by
  GitLab. The value's home, the only one anything writes.
- the **bare** one, assigned from it in the pipeline. What the repo's code
  reads, and the name a tool expects (`glab` reads `GITLAB_TOKEN`, Terraform
  `TF_VAR_*`, che `CHE_PACKAGES_REF`).

One line per variable, the supplying scope visible where the value enters. A
script reading `$GRP_KO_VAR_...` directly is a defect: it runs only under
GitLab, and a local run cannot feed it from `.env`.

Where the line goes depends on how far the bare name may reach:

- group variables the whole pipeline wants: the top-level `variables:` block.
- project secrets: the job that uses them, never top-level.
- values that change a tool's behaviour under test: the jobs that want them. A
  suite asserting a tool's default must not inherit a variable overriding that
  default. `GRP_KO_VAR_CHE_BACKUP_AUTO_CREATE` is group-scoped for this reason:
  one place sets it, each repo picks which jobs see it as
  `CHE_BACKUP_AUTO_CREATE`.

Never define the bare name in GitLab. Two GitLab-defined variables holding one
value drift the moment somebody edits the wrong one, and neither records which
is authoritative. The assignment is derivation in a reviewed file, not a second
source of truth.

## `.env.tpl`

Every repo whose pipeline remaps a variable tracks `.env.tpl` at its root (the
shared git ignore re-includes it under the `**/.*` rule). A gomplate template
che renders to `.env` (gitignored, `mergeUpsert`), the only env template a repo
has: no `templates/1-env/`, no `.env.example`, no second seed. Its first line
pulls in the tracked upstream lockfile, then one line per remaining bare name
the pipeline derives, each fetching its value the way a host can:

```sh
{{ localFile ".repo/upstream.env" | alwaysUpdate }}
ARTIFACT_REGISTRY={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_ARTIFACT_REGISTRY" }}
GITLAB_TOKEN={{ secret "op://ProgrammaticAccess/gitlab/access_token" }}
MK_DRY_RUN=
```

Every upstream ref comes from `.repo/upstream.env`, never from a `glab` call:
one marked include covers the whole block, so adding an upstream edits the
lockfile and nothing else, and a fresh clone renders with no token at all. What
is left is repo-local: a non-ref GitLab variable through `glab`, a secret
through `op`, a local-only knob as a plain or empty value.

Under `mergeUpsert` a `shell` or `secret` value overwrites the existing key on
every render, a plain value keeps it: `| keepIfExisting` or `| alwaysUpdate`
overrides per line, and marking a multi-line block marks every `KEY=VALUE` line
in it. The two lists match: a variable added to one is added to the other in the
same change. Spec: `repos/shared/spec/unvetted_ai/dev-env/env-template.story.md`.

## Naming

After the prefix, the name says what the value is, not who reads it:
`GRP_KO_VAR_ARTIFACT_REGISTRY`, not `GRP_KO_VAR_DOCKER_LOGIN_TARGET`. The bare
name is the prefixed name minus its prefix, unless a tool dictates another
spelling (`TF_VAR_github_token: $REPO_PROTECTED_VAR_BOT_GITHUB_TOKEN`).

Both halves of an identity pair carry one bare name: the protection lives in
the prefix precisely so the pipeline can remap either to the same name and let
GitLab decide which value arrives. `BOT` is part of the prefix, not the value's
name, so it drops with the rest of it:

```yaml
GITLAB_TOKEN: $REPO_UNPROTECTED_VAR_BOT_GITLAB_TOKEN   # MR jobs
GITLAB_TOKEN: $REPO_PROTECTED_VAR_BOT_GITLAB_TOKEN     # main and tag jobs
```

Versions end in `_REF`. Each released producer publishes its own:
`GRP_KO_VAR_PROSE_ASSETS_REF` (`cross-repo/prose/assets`),
`GRP_KO_VAR_PROSE_SPEC_REF` (`cross-repo/prose/spec`), `GRP_KO_VAR_MISC_REF`
(`cross-repo/misc`), `GRP_KO_VAR_CHE_PACKAGES_REF`, `GRP_KO_VAR_CI_IMAGES_REF`.
A consumer pins each upstream independently: a spec edit never moves the assets
pin.

## What Is Not A CI Variable

A value neither secret nor environment-specific belongs in the file that uses
it. A CI variable is for what cannot be committed (a token) or what one place
must own for everyone (a registry host, a pinned version). Everything else is
configuration, reviewed in an MR.

Variables a trigger job passes downstream (`forward.yaml_variables`) are
pipeline-defined: no prefix, no declaration in either infra repo.

## Example

Runnable version in `example/`: a `.gitlab-ci.yml` remapping every injected
variable at the boundary, the Terraform declaring them, the matching
`.env.tpl`.

<!-- [<] 🤖🤖 -->
