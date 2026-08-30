# example

Example repo for the templates convention.

@assets/docs-agents/purpose.md

## License

```
{{ remoteFile (printf "git::gitlab.com/konradodwrot/cross-repo/prose/assets@%s//shared/license/LICENSE" (env.Getenv "PROSE_ASSETS_REF")) }}
```

@assets/data/makefile.agents.md

## Directory Tree

@assets/data/repo-structure.md
