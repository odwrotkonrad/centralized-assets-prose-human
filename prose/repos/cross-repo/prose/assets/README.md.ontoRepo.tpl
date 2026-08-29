# Prose Assets

Rendered prose: purpose docs, README sources, AI payloads, shared fragments, license, doc templates.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Release

Every merge to main mints the next `vX.Y.Z` tag, patch by default (`ci/semver-bump.zsh`): adding prose is not a release event. A `semver: major|minor|patch` commit token lifts it. The tag pipeline triggers [automation](https://gitlab.com/konradodwrot/cross-repo/automation), which fans regen MRs out to affected downstreams.

Consumers pin this repo through `PROSE_ASSETS_REF` (`GRP_KO_VAR_PROSE_ASSETS_REF`). Conventions and specs live in [spec](https://gitlab.com/konradodwrot/cross-repo/prose/spec) (`PROSE_SPEC_REF`), shared CI scripts in [misc](https://gitlab.com/konradodwrot/cross-repo/misc) (`MISC_REF`).

## Layout

- `repos/<repo-path>/`: per-repo prose (`purpose.md`, `templates/3-audience/`, `readme/`, `docs/`, `ai/`), mirroring the GitLab group tree.
- `shared/`: fragments more than one repo consumes (`license/`).
- `templates/`: ontoRepo templates downstream repos source (`2-data/`).

## License

[MIT](LICENSE)
