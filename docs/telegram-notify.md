# Telegram notifications (GJC)

GJC’s **fully supported** mobile/remote path is Telegram (not Discord daemon).

## Prerequisites

1. Create a bot via [@BotFather](https://t.me/BotFather) → copy **bot token**.
2. Open a **private chat** with your bot and send `/start`.
3. (Recommended) BotFather → Bot Settings → **Threads** → enable **Threaded Mode** for private chats (forum topic per GJC session).

## One-time setup (Terminal — not inside GJC chat)

```bash
gjc notify setup
```

Follow prompts: paste bot token, pair your private `chat_id`.

Or set in `~/.gjc/agent/config.yml` (do **not** commit tokens):

```yaml
notifications:
  enabled: true
  telegram:
    botToken: "YOUR_BOT_TOKEN"
    chatId: "YOUR_PRIVATE_CHAT_ID"
```

## Daemon

After setup, GJC sessions auto-start/connect the managed Telegram daemon when notifications are enabled.

```bash
gjc notify status
gjc notify health
gjc notify test          # optional test message
gjc daemon               # operator control (reload/spawn) — see `gjc daemon --help`
```

## Verify with a live session

1. `gjc` (or `gjc --no-session` test won’t register endpoints the same way)
2. `gjc notify health` → endpoints should show live when session runs
3. Trigger an ask or idle — message should appear in Telegram (topic if threaded)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `notifications.enabled=false` | `gjc notify setup` or set `notifications.enabled: true` |
| `telegram.configured: no` | token + chatId both required |
| 409 / two pollers | only one `gjc daemon` per bot token; `gjc daemon reload` |
| Group chat ID | GJC requires **private** chat — use your user DM with the bot |
| No free-text reply | Enable Threaded Mode + use session topic |

## Hybrid model config

Telegram is independent of `modelRoles` / OAuth. Keep [agent/config.yml](../agent/config.yml) as-is; default is `grok-build/grok-4.5`.