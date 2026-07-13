#!/bin/sh
set -e
run() {
  role="$1"
  model="$2"
  echo "== $role ($model)"
  gjc -p --no-session --no-tools --model "$model" "Reply with exactly one line: OK-$role"
}
run default grok-build/grok-composer-2.5-fast
run executor factchat-gateway/gpt-5.5:high
run planner openai-codex/gpt-5.5:high
run architect google-antigravity/gemini-3.1-pro-low:medium
run critic factchat-gateway/claude-opus-4-8:high
echo "All role smokes finished OK."