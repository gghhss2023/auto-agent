#!/bin/bash
# SessionStart hook — inject critical feedback rules so Claude doesn't repeat past corrections
# MEM_DIR resolution order:
#   1. $CLAUDE_MEMORY_DIR env var
#   2. $HOME/.claude/memory (recommended portable location)
#   3. Auto-discover first $HOME/.claude/projects/*/memory dir
MEM_DIR="${CLAUDE_MEMORY_DIR:-$HOME/.claude/memory}"
if [ ! -d "$MEM_DIR" ]; then
  MEM_DIR=$(ls -d "$HOME"/.claude/projects/*/memory 2>/dev/null | head -1)
fi
[ -d "$MEM_DIR" ] || exit 0

cat <<'HEADER'
=== Critical user feedback (auto-injected at session start) ===
You have already been corrected on these. Do NOT repeat the mistakes.
Full text in feedback_*.md files; concise rules below.

HEADER

# Inject every feedback_*.md found (no hard-coded list — user can add/remove freely)
for f in "$MEM_DIR"/feedback_*.md; do
  [ -f "$f" ] || continue
  echo "--- $(basename "$f") ---"
  # Skip YAML frontmatter (between first two '---' lines), collapse blank lines, cap at 25 lines
  awk 'BEGIN{c=0} /^---$/{c++;next} c>=2' "$f" | sed '/^$/N;/^\n$/D' | head -25
  echo
done

echo "=== End feedback injection ==="
