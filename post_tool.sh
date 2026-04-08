#!/bin/bash
# PostToolUse hook — logs tool calls for AutoDo memory

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="$HOME/.claude/hooks/tool_log.jsonl"

# Drain stdin without storing (avoids blocking)
cat > /dev/null

# Append log entry
echo "{\"ts\":\"$TIMESTAMP\",\"tool\":\"$TOOL_NAME\"}" >> "$LOG_FILE"
