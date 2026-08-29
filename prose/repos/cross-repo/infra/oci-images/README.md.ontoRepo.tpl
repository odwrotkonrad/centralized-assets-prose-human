# oci-images

Shared OCI container images for the `konradodwrot` repos.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Images

Each image builds in one buildx job as a multi-arch manifest: amd64 native,
arm64 qemu-emulated (binfmt). Tags: `:vX.Y.Z` immutable, pinned by consumers
(published by the tag pipeline), `:latest` moving, `:$CI_COMMIT_SHORT_SHA`
immutable, `:latest-arm64` an alias of the same manifest. Non-draft MR
pipelines build cache-only, tag/main pipelines push.

### ci-linux

`$ARTIFACT_REGISTRY/ci-linux:latest`

`FROM debian:bookworm-slim` plus the shared CI toolchain, so jobs skip the
per-pipeline `apt-get` + `go install` + `curl` bootstrap:

| Tool | Purpose |
| ---- | ------- |
| go, clang, make, git | core build toolchain (CGO for che/tree-sitter) |
| che | dotfile loader, renders repo + host templates |
| lefthook | git hooks (pre-commit docs check) |
| yq | YAML query |
| zig | linux cross-compile backend (goreleaser) |
| goreleaser | go release builds |
| terraform | IaC, plugin cache pre-seeded |
| glab | GitLab CLI |
| op | 1Password CLI (terraform onepassword provider shells out to it) |

### ci-linux-dind

`$ARTIFACT_REGISTRY/ci-linux-dind:latest`

ci-linux plus the static docker CLI (no daemon: jobs use the `docker:dind`
service). A second target of the same Dockerfile, built after the base so its
registry cache is warm.

## Consume

```yaml
variables:
  CI_IMAGE: $ARTIFACT_REGISTRY/ci-linux:vX.Y.Z

validate-pre-commit-all:
  image: $CI_IMAGE
  script:
    - make repo-ci-precommit-all
```

## Versions

Tool pins live in `ci/tool-versions.env`: bump there. The build `COPY`s it in
and sources it per `RUN` in `ci/ci-linux/Dockerfile`. Host provisioning lives
separately, in `configs/ci/zsh/scripts/installs/00-ci-deps.zsh`.

## Build

CI builds both images on every non-draft MR (cache-only), `main`, and tag
pipeline. `main` auto-creates the next `vX.Y.Z` release, and its tag pipeline
publishes the pinned tag, then sends `cross-repo/automation` a
`release.published` event once both images are pushed. See `.gitlab-ci.yml`.

## License

MIT: see [LICENSE](LICENSE).
