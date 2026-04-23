#!/bin/bash
# PreToolUse guard — enforces CLAUDE.md execution rules at the harness layer
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
BG=$(echo "$INPUT" | jq -r '.tool_input.run_in_background // false')

block() {
  jq -nc --arg r "$1" '{decision:"block", reason:$r}'
  exit 0
}

# 1. find / in background → unverifiable 0-byte output
if [[ "$BG" == "true" ]] && echo "$COMMAND" | grep -qE 'find[[:space:]]+(/|~|\$HOME)'; then
  block "Do not run 'find /' in background — output cannot be verified. Run foreground, or use the Monitor tool (CC v2.1.98+) for streamed events. See CLAUDE.md 后台命令结果验证."
fi

# 2. mdfind — Spotlight index is incomplete/stale, missed real files in OpenClaw cleanup
if echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_])mdfind([[:space:]]|$)'; then
  block "mdfind is forbidden (Spotlight index missed real files in OpenClaw cleanup 2026-04-14). Use 'find / -iname \"*pattern*\" 2>/dev/null' instead. See CLAUDE.md 搜索穷举."
fi

# 3. git push --force without --force-with-lease
if echo "$COMMAND" | grep -qE '\bgit[[:space:]]+push\b'; then
  if echo "$COMMAND" | grep -qE '(\-\-force\b|[[:space:]]-f\b)' && ! echo "$COMMAND" | grep -qE '\-\-force-with-lease\b'; then
    block "Bare 'git push --force' is forbidden — use --force-with-lease only. See CLAUDE.md Git 规范."
  fi
fi

# 4. --no-verify on git commit/push/merge/rebase — bypasses hooks
if echo "$COMMAND" | grep -qE '\bgit[[:space:]]+(commit|push|merge|rebase)\b.*\-\-no-verify\b'; then
  block "--no-verify is forbidden. Fix the underlying hook failure instead of bypassing it. See CLAUDE.md Git 规范."
fi

# 5. rm -rf on root / home / cwd / parent — must confirm with user
if echo "$COMMAND" | grep -qE '\brm[[:space:]]+(-[[:alpha:]]*r[[:alpha:]]*f?[[:alpha:]]*|-[[:alpha:]]*f[[:alpha:]]*r[[:alpha:]]*)[[:space:]]+(/|/\*|~|\$HOME|\.|\.\.)([[:space:]/]|$)'; then
  block "Dangerous rm -rf on root/home/cwd path — confirm with user before destructive deletes. See CLAUDE.md 执行规范."
fi

exit 0
