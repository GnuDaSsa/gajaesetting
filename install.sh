#!/bin/sh
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
AGENT_DIR="${GJC_AGENT_DIR:-$HOME/.gjc/agent}"
LOCAL_BIN="${HOME}/.local/bin"

mkdir -p "$AGENT_DIR" "$LOCAL_BIN"

cp "$ROOT/agent/config.yml" "$AGENT_DIR/config.yml"
cp "$ROOT/agent/models.yml" "$AGENT_DIR/models.yml"

if [ ! -f "$AGENT_DIR/.env" ]; then
  cp "$ROOT/agent/.env.example" "$AGENT_DIR/.env"
  echo "Created $AGENT_DIR/.env from example — set MINDLOGIC_GATEWAY_API_KEY"
else
  echo "Kept existing $AGENT_DIR/.env"
fi

cp "$ROOT/bin/gjc-wrapper" "$LOCAL_BIN/gjc"
chmod +x "$LOCAL_BIN/gjc"

echo "Installed:"
echo "  $AGENT_DIR/config.yml"
echo "  $AGENT_DIR/models.yml"
echo "  $LOCAL_BIN/gjc (auth-broker shim)"
echo ""
echo "Next: ensure ~/.local/bin is early in PATH, then:"
echo "  gjc auth-broker login grok-build"
echo "  gjc auth-broker login openai-codex"
echo "  gjc auth-broker login google-antigravity"
echo "  ./scripts/smoke-roles.sh"