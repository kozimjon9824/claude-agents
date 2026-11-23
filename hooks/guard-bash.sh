#!/usr/bin/env bash
# PreToolUse guard for Bash and WebFetch. Denies or asks before risky actions, whatever agent runs them.
# Deterministic backstop for the rules in the agents' prompts. Never blocks on its own failure.
#
# Production hosts: comma-separated in $CLAUDE_PROD_HOSTS, and/or one per line in
# <project>/.claude/prod-hosts (lines starting with # are ignored).
set -uo pipefail
command -v jq >/dev/null || exit 0

INPUT=$(cat)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT")
CWD=$(jq -r '.cwd // empty' <<<"$INPUT")
case "$TOOL" in
  Bash)     SUBJECT=$(jq -r '.tool_input.command // empty' <<<"$INPUT") ;;
  WebFetch) SUBJECT=$(jq -r '.tool_input.url // empty' <<<"$INPUT") ;;
  *)        exit 0 ;;
esac
[ -n "$SUBJECT" ] || exit 0

decide() { # $1 = deny|ask, $2 = reason
  jq -n --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d, permissionDecisionReason: $r}}'
  exit 0
}

# 1. Production hosts
HOSTS="${CLAUDE_PROD_HOSTS:-}"
for f in "${CLAUDE_PROJECT_DIR:-}/.claude/prod-hosts" "$CWD/.claude/prod-hosts"; do
  [ -f "$f" ] && HOSTS="$HOSTS,$(grep -v '^[[:space:]]*#' "$f" | tr '\n' ',')"
done
IFS=',' read -r -a HOST_LIST <<<"$HOSTS"
for h in "${HOST_LIST[@]}"; do
  h=$(echo "$h" | xargs)
  [ -n "$h" ] || continue
  if grep -qiF -- "$h" <<<"$SUBJECT"; then
    decide deny "Blocked by guard: '$h' is a production host. Agents work against dev/staging only."
  fi
done

[ "$TOOL" = "Bash" ] || exit 0
CMD="$SUBJECT"
LOWER=$(tr '[:upper:]' '[:lower:]' <<<"$CMD")

# 2. Git: no force push, no direct push to shared branches
if grep -Eq '(^|[;&|[:space:]])git[[:space:]]+push\b' <<<"$CMD"; then
  if grep -Eq -- '(--force([^-]|$)|--force-with-lease|[[:space:]]-[a-zA-Z]*f\b|\+[^[:space:]]+)' <<<"$CMD"; then
    decide deny "Blocked by guard: force push is not allowed for agents. Ask the user to do it if really needed."
  fi
  if grep -Eq '[[:space:]:](main|master|develop|release[^[:space:]]*)([[:space:]]|$)' <<<"$CMD"; then
    decide deny "Blocked by guard: agents never push to main/master/develop/release. Push the feature branch and open an MR."
  fi
  decide ask "Guard: pushing changes the shared remote — confirm this push."
fi
if grep -Eq 'git[[:space:]]+(reset[[:space:]]+--hard|clean[[:space:]]+-[a-zA-Z]*f|checkout[[:space:]]+--[[:space:]]+\.|branch[[:space:]]+-D)' <<<"$CMD"; then
  decide ask "Guard: this git command discards work and cannot be undone — confirm."
fi

# 3. Databases (only when a database client is invoked): destructive SQL denied, writes need confirmation
if grep -Eq '(^|[^a-z0-9_-])(psql|pgcli|mysql|mariadb|mycli|sqlite3|sqlcmd|mongosh|clickhouse-client|redis-cli)([^a-z0-9_-]|$)' <<<"$LOWER"; then
  if grep -Eq '(drop[[:space:]]+(table|database|schema)|truncate[[:space:]]|alter[[:space:]]+table[^;]*[[:space:]]drop[[:space:]]|flushall|flushdb|dropdatabase\()' <<<"$LOWER"; then
    decide deny "Blocked by guard: destructive database command (DROP/TRUNCATE/FLUSH) is not allowed for agents."
  fi
  if grep -Eq '(delete[[:space:]]+from|update[[:space:]]+[a-z_".]+[[:space:]]+set|insert[[:space:]]+into|deletemany|updatemany|insertone|[[:space:]]del[[:space:]]|[[:space:]]set[[:space:]])' <<<"$LOWER"; then
    decide ask "Guard: this command writes to a database — confirm it targets a dev/local database and test data."
  fi
fi

# 4. Secrets and wide deletes
if grep -Eq '(security[[:space:]]+(find|dump)-(generic|internet)-password|security[[:space:]]+dump-keychain)' <<<"$CMD"; then
  decide deny "Blocked by guard: agents don't read the macOS Keychain."
fi
if grep -Eq '(^|[;&|[:space:]])rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\$HOME|\.\.?/?)([[:space:]]|$)' <<<"$CMD"; then
  decide deny "Blocked by guard: recursive delete of a root, home or parent directory."
fi

exit 0
