#[what] Project's Makefile
SHELL := zsh

WRAPPERS := repo-prepare-dev-env
COMMANDS := render-templates repo-prepare-deps repo-ci-prepare-hooks

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Dev Environment [genai-include]
#[why] render precedes hooks: the docsgen pre-commit hook runs render-templates and fails on drift,
#   so a fresh clone whose generated files were never rendered would fail its first commit
#[what] make a fresh clone a working checkout: generated docs, dependencies, git hooks
repo-prepare-dev-env: render-templates repo-prepare-deps repo-ci-prepare-hooks
##[<] Dev Environment

##[>] Docs [genai-include]
#[what] render *.ontoRepo.tpl onto the repo (makefile.agents.md)
render-templates:
	@che render-templates
##[<] Docs

##[>] Setup [genai-include]
#[why] a declared toolchain may still lack the command: debian's ruby ships bundler only as
#   bundle3.1, so the launcher is installed when the unversioned name is missing
#[why] path set explicitly: .bundle/config carries it but is gitignored, so a fresh clone would
#   install system-wide and fail without root
#[what] install the toolchain this repo declares, then its dependencies, into the checkout
repo-prepare-deps:
	@che run --profiles=devEnv
	@command -v bundle >/dev/null || gem install --user-install --no-document bundler
	@bundle config set --local path vendor/bundle
	@bundle install

#[what] install lefthook git hooks
repo-ci-prepare-hooks:
	@lefthook install --force
##[<] Setup
