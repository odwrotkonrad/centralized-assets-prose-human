# configs

The AI toolchain as che profiles.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Layout

- `profiles/base/` — the agent prose payload (`~/.config/ai-agents/docs`), the LLM-backed git wrappers (`git-*-upsert.zsh`, `llm-*-suggest.zsh`, `lib/llm-lib.zsh`) and `/etc/custom/llm.yml`.
- `profiles/claude/` — claude rules, skills, output styles, `settings.json`, ccstatusline.
- `profiles/codex/` — codex configuration.
- `profiles/ollama/` — ollama, host only.
- `che.yml` — publishes `ai/base/macos`, `ai/host/macos` and `ai/virt/linux`.

## Profiles

`ai/base/macos` is the shared macos payload (base, claude, codex). `ai/host/macos` adds ollama and runs only off-virt. `ai/virt/linux` is the linux/virt payload.

## License

MIT — see [LICENSE](LICENSE).
