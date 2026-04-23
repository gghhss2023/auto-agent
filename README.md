# Auto Agent — Claude Code 通用自动化插件

**EN:** A Claude Code plugin that turns `/do <anything>` into a fully autonomous execution agent — it decomposes tasks, executes them in parallel, and remembers results across sessions.

**中文：** 一个 Claude Code 插件，输入 `/do <任意指令>` 即可启动自主执行代理 —— 自动拆解任务、并行执行、跨会话记忆结果。

## What it does

Type `/do` followed by any instruction. The agent will:

1. Decompose the task into subtasks
2. Execute them in parallel using all available tools
3. Record results to memory for future context

## Components

| Component | File | Role |
|-----------|------|------|
| Skill | `do.md` | `/do` slash command entry point |
| Pre-tool guard | `pre_tool_guard.sh` | Blocks 5 risky Bash patterns (find-in-bg, mdfind, git --force, --no-verify, rm -rf on root/home) |
| Session start | `session_start.sh` | Auto-injects `feedback_*.md` memory files at every session start |
| Post-tool log | `post_tool.sh` | Logs tool calls to `~/.claude/hooks/tool_log.jsonl` |
| Stop summary | `stop.sh` | Appends session summary to memory on exit |
| Config template | `settings.json.example` | Registers all 4 hooks; copy and adapt |
| Instructions | `CLAUDE.md` | Global agent behavior rules |
| Docs | `README.md` | Setup guide and usage reference |

## Installation

### 1. Copy files

```bash
mkdir -p ~/.claude/commands ~/.claude/hooks ~/.claude/memory

# Slash command
cp do.md ~/.claude/commands/

# Hooks
cp *.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# Global instructions
cp CLAUDE.md ~/.claude/
```

### 2. Register hooks in `~/.claude/settings.json`

Merge the contents of `settings.json.example` into your existing `~/.claude/settings.json`. Four hooks are registered:

- **SessionStart** → `session_start.sh` (injects feedback rules)
- **PreToolUse** (Bash) → `pre_tool_guard.sh` (blocks risky commands)
- **PostToolUse** → `post_tool.sh` (logs tool calls)
- **Stop** → `stop.sh` (session summary)

### 3. Add MCP servers

```bash
# Filesystem
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem ~

# Playwright (browser automation)
claude mcp add playwright -- npx -y @playwright/mcp@latest

# GitHub (requires token)
claude mcp add github -e GITHUB_TOKEN=<your_token> -- npx -y @modelcontextprotocol/server-github
```

### 4. Restart Claude Code

## Hooks in detail

### `pre_tool_guard.sh` — PreToolUse guard

Blocks 5 dangerous Bash patterns before execution, returning `{"decision":"block"}`:

| # | Pattern blocked | Why |
|---|-----------------|-----|
| 1 | `find /` / `find ~` with `run_in_background:true` | 0-byte output file can't be verified; use Monitor tool instead |
| 2 | `mdfind` | Spotlight index is stale/incomplete; use `find / -iname` |
| 3 | `git push --force` without `--force-with-lease` | Unsafe; use lease variant |
| 4 | `git (commit\|push\|merge\|rebase) --no-verify` | Bypasses hooks |
| 5 | `rm -rf` on `/`, `~`, `$HOME`, `.`, `..` | Confirm with user first |

### `session_start.sh` — SessionStart feedback injection

Scans `$CLAUDE_MEMORY_DIR` (or `~/.claude/memory/`, or auto-discovered `~/.claude/projects/*/memory/`) for any `feedback_*.md` files and injects their bodies (skipping YAML frontmatter) into every session start. This means lessons learned from past corrections are always in-context — no need to rely on Claude reading memory files proactively.

**Recommended feedback files:**
- `feedback_communication_style.md` — how Claude should communicate
- `feedback_verify_not_claim.md` — verify before asserting
- `feedback_one_shot.md` — fix all issues in one pass
- `feedback_search_and_destroy.md` — macOS cleanup checklist
- `feedback_use_edit_not_write.md` — prefer Edit over Write for existing files

File format:

```markdown
---
name: Short title
description: One-line summary
type: feedback
---

Rule statement.

**Why:** Reason / past incident.

**How to apply:** When this kicks in.
```

## Usage

```
/do search today's AI news and save to desktop
/do organize ~/Downloads by file type
/do check latest PRs in my repos and summarize
/do find all TODO comments in ~/projects and create a report
```

## Architecture

```
/do <instruction>
    │
    ▼
do.md (Skill) — reads Memory for context
    │
    ▼
Task decomposition → parallel Agent execution
    │
    ├── Files: Read/Write/Edit/Glob/Grep
    ├── Terminal: Bash
    ├── Web: WebSearch/WebFetch
    ├── Browser: Playwright MCP
    ├── GitHub: gh CLI + GitHub MCP
    └── Skills: /review /loop /schedule /codex
    │
    ▼
PostToolUse Hook — logs each tool call
    │
    ▼
Results → task_log.md (Memory)
    │
    ▼
Stop Hook — session summary
```

## Requirements

- Claude Code v2.0+
- Node.js 18+
- GitHub CLI (`gh`) for GitHub operations
