# gajaesetting — GJC (Gajae Code) dotfiles

Portable **hybrid multi-vendor** setup for [@gajae-code/coding-agent](https://github.com/can1357/gajae-code) (`gjc`).

| Role | Model | Auth |
|------|--------|------|
| **default** | `grok-build/grok-composer-2.5-fast` | Grok OAuth |
| **executor** | `factchat-gateway/gpt-5.5:high` | Mindlogic gateway API key |
| **planner** | `openai-codex/gpt-5.5:high` | OpenAI Codex OAuth |
| **architect** | `google-antigravity/gemini-3.1-pro-low:medium` | Google Antigravity OAuth |
| **critic** | `factchat-gateway/claude-opus-4-8:high` | Mindlogic gateway API key |

`enabledModels` pins new sessions to **Grok** so Anthropic OAuth does not fall back to retired Sonnet (404).

## Quick install (macOS)

```bash
git clone https://github.com/GnuDaSsa/gajaesetting.git
cd gajaesetting
./install.sh
```

Then complete **OAuth on this machine** (tokens are not in git):

```bash
gjc auth-broker status   # uses ~/.local/bin/gjc wrapper
gjc auth-broker login grok-build
gjc auth-broker login openai-codex
gjc auth-broker login google-antigravity
# optional fallback:
# gjc auth-broker login google-gemini-cli
```

Gateway key (executor/critic only):

```bash
cp agent/.env.example ~/.gjc/agent/.env
# edit ~/.gjc/agent/.env → set MINDLOGIC_GATEWAY_API_KEY
```

Ensure `~/.local/bin` is **before** `~/.bun/bin` in `PATH` (see `snippets/zshrc-gjc.path`).

## Verify

```bash
./scripts/smoke-roles.sh
```

## Layout

```
agent/config.yml      → ~/.gjc/agent/config.yml
agent/models.yml      → ~/.gjc/agent/models.yml
agent/.env.example    → ~/.gjc/agent/.env (manual)
bin/gjc-wrapper       → ~/.local/bin/gjc
snippets/             → optional shell helpers
scripts/smoke-roles.sh
```

## Notes

- **Do not commit** `~/.gjc/agent/.env` or `agent.db` (OAuth refresh tokens).
- `gjc auth-broker login` must run in **Terminal**, not inside the GJC chat TUI (otherwise the CLI may treat it as a user prompt).
- Installed `gjc` 0.10.1: top-level `auth-broker` is routed by the wrapper to `@gajae-code/ai` `login`/`logout`/`status`.

## Rotate secrets

If a gateway API key was ever pasted in chat or logs, rotate it in the Mindlogic console and update `~/.gjc/agent/.env`.