#!/bin/bash
# Stop hook — summarizes session tool usage

LOG_FILE="$HOME/.claude/hooks/tool_log.jsonl"
SUMMARY_FILE="$HOME/.claude/projects/-Users-macosx/memory/session_summary.md"

if [ ! -f "$LOG_FILE" ]; then
  exit 0
fi

COUNT=$(wc -l < "$LOG_FILE")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "## Session ended $TIMESTAMP — $COUNT tool calls" >> "$SUMMARY_FILE"

# Clear log for next session
> "$LOG_FILE"
