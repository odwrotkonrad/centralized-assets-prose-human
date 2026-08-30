# CI Convention

Lefthook runs pre-commit hooks. CI re-runs them over the branch diff and fails on drift. Scope per context: `cross-repo/prose/spec` `repos/shared/spec/unvetted_ai/ci/precommit.story.md`.

## Lefthook

- Repo `lefthook.yml` extends `~/.config/lefthook/lefthook.yml` (user-level hooks: ssh auth, conventional commit prefix, linters).
- The one repo job is `docsgen`: `make render-templates`, then `git diff --exit-code`. A commit fails if regeneration touched a tracked file. Renders fetch the pinned prose sources, so committing needs network to gitlab.com.
- A local commit runs hooks over staged files only: `lefthook run pre-commit`, no `--all-files`.

## CI

- Jobs call Makefile targets (`make repo-ci-precommit-diff`, `make repo-ci-precommit-all`, `make test`, `make validate`), never raw commands.
- MR and default-branch pipelines only (`workflow.rules` on `merge_request_event` and `$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH`).
- `validate` stage, MRs only:
  - `validate-pre-commit-diff`: `make repo-ci-precommit-diff` (hooks over the branch-to-target diff), then `git diff --exit-code HEAD`. Blocking.
  - `validate-pre-commit-all`: `make repo-ci-precommit-all` (hooks over every file). `when: manual`, `allow_failure: true`.
- No pre-commit job on the default branch: its content already passed as an MR.
- CI lacks the user-level config. A stub makes `extends` resolve.

## Images

Every image a job pulls comes from Artifact Registry in `konradodwrot-ci`, over private Google access. Nothing names a public registry: a GKE job pod reaching `gitlab.com` for a pull token is the failure this removes.

Four group variables, owned by `cross-repo/infra/iac`, set on `konradodwrot`:

- `ARTIFACT_REGISTRY`: where `cross-repo/infra/oci-images` publishes `ci-linux` and `ci-linux-dind`.
- `ARTIFACT_REGISTRY_PROXY_GITLAB`, `ARTIFACT_REGISTRY_PROXY_DOCKERHUB`: pull-through caches for `registry.gitlab.com` and Docker Hub.
- `CI_IMAGES_REF`: the pinned `ci-linux` version, raised by an oci-images release.

Each is injected as `GRP_KO_VAR_<NAME>` and remapped to the bare name in the top-level `variables:` block (ci-variables convention). A repo writes `image: $ARTIFACT_REGISTRY/ci-linux:$CI_IMAGES_REF`, a third-party image `$ARTIFACT_REGISTRY_PROXY_DOCKERHUB/library/ruby:3.4` (official Docker Hub images carry `library/`). Never a floating tag: a pull-through cache serves it stale, and a rerun of an old pipeline should run the image it ran originally.

A `services:` entry needs an explicit alias once the image is a registry path, since GitLab otherwise derives the hostname from the image name:

```yaml
services:
  - name: $ARTIFACT_REGISTRY_PROXY_DOCKERHUB/library/docker:dind
    alias: docker
```

A Dockerfile `FROM` is a **separate pull** from the job's `image:`: the build daemon resolves it from the file, so repointing `image:` leaves every cache-cold build fetching from the public registry. Parameterise the base, keep the public default so a local build needs no cloud credentials, pass the proxy from CI:

```dockerfile
ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}
```

```yaml
- docker buildx build --build-arg "BASE_IMAGE=$ARTIFACT_REGISTRY_PROXY_DOCKERHUB/library/debian:bookworm-slim" ...
```

Same for anything else the build pulls: **the job's `image:` and a pull inside the job use different identities.** The kubelet fetches the job image as the node service account. A `docker pull` or `docker build` in the script runs as the job pod's own account, through Workload Identity. Read on a registry for the node account says nothing about the build: the job image resolves, the build is denied, and a credentials bug turns out to be an IAM one.

Grant the job identity read on every repository a build may pull from. Scope write to what it publishes.

**Registry auth lives in the runner, never in a pipeline.** The `docker:dind` daemon holds no credential: the docker CLI in the job container sends one per request, read from `~/.docker/config.json`. The runner's `pre_build_script` (`cross-repo/infra/iac`, `ci-cluster/ar-docker-auth-pre-build.sh`) writes that file before every job with the pod's metadata token, as it writes the go proxy `.netrc`. No `.gitlab-ci.yml` or CI script runs `docker login` or fetches a token. The token lives about an hour from job start.

A tool image a script `docker run`s is pulled explicitly first: the implicit pull behind `docker run` carries no credential.

```yaml
- docker pull $ARTIFACT_REGISTRY_PROXY_DOCKERHUB/tonistiigi/binfmt
- docker run --privileged --rm $ARTIFACT_REGISTRY_PROXY_DOCKERHUB/tonistiigi/binfmt --install arm64
```

An image a job builds goes to `$ARTIFACT_REGISTRY` (`--push`, `--cache-to`), to a job artifact (`--output type=docker,dest=<file>.tar`), or stays in the daemon. Never `registry.gitlab.com`, never Docker Hub. Every project has `container_registry_access_level = "disabled"`.

Spec: `cross-repo/prose/spec` `repos/shared/spec/unvetted_ai/ci/oci-images-registry.story.md`, requirements beside it.

## Example

Runnable version in `example/`: `lefthook.yml`, `.gitlab-ci.yml`, `Makefile`.
