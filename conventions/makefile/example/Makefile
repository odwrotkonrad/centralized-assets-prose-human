#[what] Project's Makefile
SHELL := zsh

WRAPPERS := check
COMMANDS := test build render-templates

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] print commands instead of running them
#[vals] true|false
export MK_DRY_RUN
##[<] Environment Variables

##[>] Wrappers [genai-include]
#[what] run tests then build
check: test build
##[<] Wrappers

##[>] Go [genai-include]
#[what] run all tests
test:
	go test ./...

#[what] build the binary into ./dist
build:
	go build -o dist/ .
##[<] Go

##[>] Docs [genai-include]
#[what] render *.ontoRepo.tpl onto the repo (makefile.agents.md)
render-templates:
	@che render-templates
##[<] Docs
