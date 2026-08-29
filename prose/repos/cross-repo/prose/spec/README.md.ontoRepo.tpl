# Prose Spec

Conventions and behavior specs every workspace repo obeys.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Release

Every merge to main mints the next `vX.Y.Z` tag, patch by default, lifted by a `semver: major|minor|patch` commit token. The tag pipeline triggers [automation](https://gitlab.com/konradodwrot/cross-repo/automation), which bumps the pin in [configs](https://gitlab.com/konradodwrot/tools-configs) as a regen MR. Nothing here renders into a repo: specs are read in place, and `configs` `llm/base` renders `conventions/conventions.md` once onto the host, at `PROSE_SPEC_REF` (`GRP_KO_VAR_PROSE_SPEC_REF`).

Rendered prose (purpose docs, templates, AI payloads, license) lives in [assets](https://gitlab.com/konradodwrot/cross-repo/prose/assets), shared CI scripts in [misc](https://gitlab.com/konradodwrot/cross-repo/misc).

## Layout

- `conventions/`: repo conventions, each a `<name>/convention.md` plus a runnable `example/`. `conventions.md` summarizes them, one line each.
- `repos/<repo-path>/spec/`: per-repo behavior specs, mirroring the GitLab group tree. `repos/shared/spec/`: behavior every repo shares.

## License

[MIT](LICENSE)
