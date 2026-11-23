#!/usr/bin/env bash
# PostToolUse for Edit|Write|MultiEdit: formats an edited .dart file and reports analyzer *errors* back to Claude.
# Set CLAUDE_HOOK_ANALYZE=0 to only format. Uses $CLAUDE_DART (e.g. "fvm dart") if set.
set -uo pipefail
command -v jq >/dev/null || exit 0

FILE=$(jq -r '.tool_input.file_path // empty')
case "$FILE" in
  *.g.dart|*.freezed.dart|*.mocks.dart|*.gr.dart|*.config.dart) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac
[ -f "$FILE" ] || exit 0

read -r -a DART <<<"${CLAUDE_DART:-dart}"
command -v "${DART[0]}" >/dev/null || exit 0

"${DART[@]}" format --output=write "$FILE" >/dev/null 2>&1 || true

[ "${CLAUDE_HOOK_ANALYZE:-1}" = "0" ] && exit 0
OUT=$(cd "$(dirname "$FILE")" && timeout 60 "${DART[@]}" analyze "$FILE" 2>&1) || true
ERRORS=$(grep -E '^[[:space:]]*error[[:space:]]+-' <<<"$OUT" | head -20)
if [ -n "$ERRORS" ]; then
  {
    echo "dart analyze found errors in $(basename "$FILE") after your edit (the file was also formatted with dart format, re-read it before the next edit):"
    echo "$ERRORS"
  } >&2
  exit 2   # PostToolUse: shows stderr to Claude; the edit itself stays
fi
exit 0
