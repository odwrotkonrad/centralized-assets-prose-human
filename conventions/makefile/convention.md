# Makefile Convention

## Sectioning (makefile docs autogeneration)

Targets group into `##[>] Section [genai-include]` ... `##[<] Section` blocks. `[genai-include]` marks a section for harvesting into the generated `assets/data/makefile.agents.md` (`templates/2-data/makefile-agents.md.ontoRepo.tpl` + che), included in `CLAUDE.md` and `AGENTS.md`.

- Every target: a `#[what]` one-liner above it.
- Env vars: `#[what]` + `#[vals]` above their `export`.

## Shell

- `SHELL := zsh`

## Targets

- `COMMANDS :=` lists command targets, `WRAPPERS :=` aggregate targets.
- `.PHONY: $(WRAPPERS) $(COMMANDS)`.
- Wrappers chain commands as prerequisite lists, no recipes: `run-sync: run-host-upsert-configs run-host-render-templates`.

## Example

Runnable version in `example/`: `Makefile` (env var, wrapper, commands), `che.yml`, `templates/2-data/makefile-agents.md.ontoRepo.tpl`, generated `assets/data/makefile.agents.md`.
