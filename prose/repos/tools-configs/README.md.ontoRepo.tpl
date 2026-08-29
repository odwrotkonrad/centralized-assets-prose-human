{{- $front := frontmatter "assets/data/tools-inventory-index.yml" | data.YAML -}}
{{- $body := readBody "assets/data/tools-inventory-index.yml" -}}
## **Config**uration file**s**

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## {{ $front.title }}

{{ $front.description }}

```yaml
{{ $body }}```

{{ range $uri, $desc := $front.references -}}
- [{{ $uri }}]({{ $uri }}) - {{ $desc }}
{{ end }}
## Observability

### Claude Code

Dashboard for Claude Code usage, cost and token metrics.

![Claude Code dashboard](profiles/observability/grafana/assets/images/grafana-claude-code-dashboard-pt-1.png)

[recording](profiles/observability/grafana/assets/recordings/grafana-cc-dashboard.gif) · [more](profiles/observability/grafana/assets/images/grafana-claude-code-dashboard-pt-2.png)

### Host System

Dashboard for host CPU, memory, disk and network metrics.

![Host system dashboard](profiles/observability/grafana/assets/images/grafana-host-dashboard-pt-1.png)

[recording](profiles/observability/grafana/assets/recordings/grafana-host-dashboard.gif) · [more](profiles/observability/grafana/assets/images/grafana-host-dashboard-pt-2.png)

## Zsh **Deep** Completion

Argument completion for files & directories.

![Zsh deep completion](profiles/shell/zsh/assets/images/zsh-deep-completion.png)

[recording](profiles/shell/zsh/assets/recordings/zsh-deep-completion.gif)

## ☢️ Danger Zone - Loading Configs ☢️

Loading configuration directly modifies the OS, including system, non-user files. If you find anything of interest, prefer copying these pieces into your own config.

[Loading Configs](assets/docs-human/loading-configuration.md)
