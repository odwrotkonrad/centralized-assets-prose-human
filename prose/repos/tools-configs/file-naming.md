# File Naming

kebab-case all files.

Executables by kind:

- script: bare descriptive name (`export-dir-sizes`, `git-sync-onto-main`)
- function: `fn-<name>` (`fn-log-msg`, `fn-is-os`), a bare name overrides a command (`rm`)
- launchd: `d-<space>-<name>`, space = `root` (LaunchDaemons) · `user` (LaunchAgents)
- command override: bare name (`rm`, `prometheus`)
