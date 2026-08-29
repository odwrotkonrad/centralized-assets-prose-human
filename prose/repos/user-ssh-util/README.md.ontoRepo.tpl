# user-ssh-util

Declarative SSH key lifecycle: declare, publish, rotate.

## Happy Path

Declare the keys you want in `$XDG_CONFIG_HOME/user-ssh-util/config.yml`:

```yml
rotation:
  - type: access
    period: 1 month
    scope: global
defaults:
  email: you@example.com
  algorithm: ecdsa-sha2-nistp521
keys:
  id_access:
    type: access
    publishTo: [gitlab, github]
```

Then reconcile:

```bash
user-ssh-util sync --dry-run
user-ssh-util sync
```

`sync` generates what is missing, publishes it where `publishTo` names, and rotates whatever is past its period. A declared key whose keypair is already in `~/.ssh` is adopted instead of generated, and one whose material a platform already holds is recorded under that platform's existing title, so nothing you made by hand is overwritten or published twice. Each due rotation asks first, naming what it will revoke:

```
rotate id_signing? the old key will be revoked from gitlab, github [y/N]
```

Answer once per key, or pass `--yes` to skip the questions. Without a terminal (cron, CI) an unanswered rotation is skipped rather than assumed.

Rotate a key before its period elapses by naming it, which counts as the confirmation:

```bash
user-ssh-util sync --force-rotate-keys=id_signing,id_access
```

The superseded key is revoked from every platform holding it, and so is a key you delete from config. That happens only after the replacement is published and proven to authenticate. To keep an old grant instead, name the platforms that may be touched with `--revoke-platforms=gitlab`, or opt out entirely with `revokePlatforms: []` in config.

Prove the declared keys still work, without changing anything:

```bash
user-ssh-util check
user-ssh-util check id_signing
```

An access key is proven by logging in to each platform it publishes to, a signing key by signing and verifying a payload: GitHub refuses SSH login to a signing key by design, so a login check would fail a healthy one. Exits non-zero if any check fails.

Platform calls shell out to `glab` and `gh`, so authenticate those first. A revoked key loses every platform grant, and its keypair moves out of `~/.ssh` into `backups/` rather than being deleted. A signing key keeps its `allowed_signers` line: entries are appended stamped `valid-after="YYYYMMDD"` and never removed, so commits the key already signed keep verifying. Nothing is ever destroyed, so an unwanted revoke is undone by moving the keypair back.

All targets: [assets/data/makefile.agents.md](assets/data/makefile.agents.md).

{{ renderMarkdown "assets/docs-agents/purpose.md" "strip-comments" "normalize-headings" }}
