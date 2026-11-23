#!/usr/bin/env bash
# Sends a short Telegram message when a custom subagent finishes or Claude waits for you.
# Register with "async": true. Always exits 0 — a failed notification must never affect the session.
#
# Bot token and chat id, first found wins:
#   macOS Keychain: security add-generic-password -s claude-telegram-bot -a "$USER" -w '<token>'
#                   security add-generic-password -s claude-telegram-chat -a "$USER" -w '<chat id>'
#   or env:         TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID  (env is visible to Claude's Bash tool; Keychain is not)
# TELEGRAM_NOTIFY_MODE: minimal (default) = agent, project, status; summary = + first 300 chars of the report;
#                       full = + up to 3000 chars. mobile-security-auditor is always minimal.
set -uo pipefail
command -v jq >/dev/null && command -v curl >/dev/null || exit 0

INPUT=$(cat)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT")
AGENT=$(jq -r '.agent_type // empty' <<<"$INPUT")
CWD=$(jq -r '.cwd // empty' <<<"$INPUT")
PROJECT=$(basename "${CWD:-?}")
MODE="${TELEGRAM_NOTIFY_MODE:-minimal}"

secret() { # keychain service, env fallback
  local v=""
  command -v security >/dev/null && v=$(security find-generic-password -s "$1" -w 2>/dev/null || true)
  echo "${v:-$2}"
}
TOKEN=$(secret claude-telegram-bot "${TELEGRAM_BOT_TOKEN:-}")
CHAT=$(secret claude-telegram-chat "${TELEGRAM_CHAT_ID:-}")
[ -n "$TOKEN" ] && [ -n "$CHAT" ] || exit 0

case "$EVENT" in
  SubagentStop)
    case "$AGENT" in ""|general-purpose|Explore|Plan|statusline-setup|output-style-setup) exit 0 ;; esac
    REPORT=$(jq -r '.last_assistant_message // empty' <<<"$INPUT")
    STATUS="✅ finished"
    grep -qiE '\b(failed|error|blocked|stopped)\b' <<<"$(head -c 2000 <<<"$REPORT")" && STATUS="⚠️ finished — check the report"
    TEXT="🤖 $AGENT · $PROJECT"$'\n'"$STATUS"
    [ "$AGENT" = "mobile-security-auditor" ] && MODE=minimal
    case "$MODE" in
      summary) TEXT="$TEXT"$'\n\n'"$(head -c 300 <<<"$REPORT")" ;;
      full)    TEXT="$TEXT"$'\n\n'"$(head -c 3000 <<<"$REPORT")" ;;
    esac
    ;;
  Notification)
    MSG=$(jq -r '.message // "Claude is waiting for you"' <<<"$INPUT")
    TEXT="⏳ $PROJECT"$'\n'"$(head -c 200 <<<"$MSG")"
    ;;
  *) exit 0 ;;
esac

curl -fsS --max-time 10 "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  --data-urlencode "chat_id=$CHAT" --data-urlencode "text=$TEXT" \
  --data-urlencode "disable_web_page_preview=true" >/dev/null 2>&1 || true
exit 0
