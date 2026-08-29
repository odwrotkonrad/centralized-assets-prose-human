# Zsh

<!--[>] 🤖🤖 -->
## Deep Completion

Argument completion for files and dirs.

![Zsh deep completion](assets/images/zsh-deep-completion.png)

[recording](assets/recordings/zsh-deep-completion.gif)
<!--[<] 🤖🤖 -->

## Deep Completion Configuration

`_deep_files` zstyle settings (`profiles/shell/zsh/base/root/etc/zsh/zshrc.d/auto.d/00-base/40-completions.zsh`).

The engine fills the context's function field, so lookups are `:completion:_deep_files:<completer>:<command>:<argument>:<group>`. `:completion:_deep_files:*` scopes a style to every wrapped command, `:completion:_deep_files:*:cd:*` to one. Most specific pattern wins. Patterns without the function field (`:completion:*:cd:*`) still match.

Group names: `<scope>[-N][+M]`. `-N` anchors at the N-th ancestor of PWD, bare name = that anchor's children, `+M` adds M depth. Unknown names are skipped.

Groups:

| Group | Glob | Anchor |
| - | - | - |
| `pwd` | `*` | PWD |
| `pwd+1` | `*/*` | PWD |
| `pwd+2` | `*/*/*` | PWD |
| `pwd-1` | `../*` | parent |
| `pwd-1+1` | `../*/*` | parent |
| `pwd-2` | `../../*` | grandparent |
| `absolute` | `<base>/*` | typed `/` or `~` base |
| `absolute+1` | `<base>/*/*` | typed base |
| `stack` | bare `$dirstack` entries | directory stack |
| `stack+1` | `<stacked>/*` | each stacked dir |
| `stack+2` | `<stacked>/*/*` | each stacked dir |
| `named-dirs` | `hash -d` names | (none) |

Settings:

| Setting | Tag | Default | Meaning |
| - | - | - | - |
| `groups` | `:completion:_deep_files:...:` (empty tag) | `pwd`..`pwd+3`, `absolute`..`absolute+3`, `pwd-1`..`pwd-1+2`, `pwd-2` | which groups run, in display order |
| `file-types` | `:completion:_deep_files:...:` (empty tag) | `dirs files` | kinds the engine globs. Membership selects, order sets emission order within each group (`files dirs` = files first). Unknown values ignored |
| `max-hints` | `<group>` | 6, this config: `:completion:_deep_files:*:*` 6, `pwd`/`absolute`/`stack`/`named-dirs` -1, `pwd+1`/`absolute+1` 12 | group cap, shared by visible, hidden, demoted. -1 uncapped, 0 disables the group. Narrower tag patterns override the `*` default |
| `deprioritize-hints` | `<group>` | test | segment patterns sorted last, after hidden, within the group's `max-hints`. Case-insensitive substring of any path segment, `^` pins segment start, `$` pins segment end (`'^.git$'` exact) |

Lists: `groups`, `file-types`, `deprioritize-hints`. Scalar: `max-hints`. Per-group tags take wildcards, most specific pattern wins.

Routing: `absolute*` groups run only on a `/` or `~` prefix, `pwd*` groups otherwise. A bare `~name` prefix shows `named-dirs` only. `stack+M` globs only once a pattern is typed.

Examples:

```zsh
zstyle ':completion:_deep_files:*:' groups pwd pwd+1 stack named-dirs
zstyle ':completion:_deep_files:*:cd:*:' groups pwd pwd+1 stack
zstyle ':completion:_deep_files:*:cd:*:' file-types dirs
zstyle ':completion:_deep_files:*:ls:*:' file-types files dirs
zstyle ':completion:_deep_files:*:pwd+1' max-hints 3
zstyle ':completion:_deep_files:*:pwd*' max-hints 6
zstyle ':completion:_deep_files:*:vim:*:pwd-1' deprioritize-hints '^.git$' 'node_modules'
```

Every group except `named-dirs` and base `stack` emits an `-h` hidden twin (`pwd+1-h`) right after it, capped together with its visible group.
