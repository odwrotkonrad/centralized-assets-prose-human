# centralized/assets/generic

Generic repo assets every workspace repo consumes.

{{ renderMarkdown "assets/docs-agents/purpose.md" "strip-comments" "normalize-headings" }}

## Consumer Contract

Two targets in the consumer `Makefile`: `che-install`, `generic-setup`. Everything else comes from `shared/generic/make/generic.mk`, rendered by `generic-setup`.

```make
-include shared/generic/make/generic.mk

che-install:
	@curl -fsSL https://konradodwrot.gitlab.io/go-modules/che-install.sh | sh -s -- --skip-if-present-is-newer

generic-setup:
	@$${BIN_CHE:-che} render-templates --profiles=generic/setup

shared/generic/make/generic.mk: generic-setup
```

`.che/che.yml` lists `{source: shared/generic/che, optional: true}` under `include.sources` and defines `genericSetup`, a ref to this repo's `consumer-repo-config` `setup` profile with `variables: {repo: <path>}`.
