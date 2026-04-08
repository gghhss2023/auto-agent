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
| Skill | `commands/do.md` | `/do` slash command entry point |
| Hooks | `hooks/post_tool.sh`, `hooks/stop.sh` | Log tool calls / summarize session on exit |
| MCP | filesystem, playwright, github | Extended tool access |
| Memory | `task_log.md` | Persists task history across sessions |
| Config | `settings.json` | Registers hooks and MCP servers |
| Instructions | `CLAUDE.md` | Global agent behavior rules |
| Docs | `README.md` | Setup guide and usage reference |

## Installation

### 1. Copy files

```bash
mkdir -p ~/.claude/commands ~/.claude/hooks

cp do.md ~/.claude/commands/
cp post_tool.sh ~/.claude/hooks/
cp stop.sh ~/.claude/hooks/

chmod +x ~/.claude/hooks/post_tool.sh
chmod +x ~/.claude/hooks/stop.sh
```

### 2. Register hooks in `~/.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/post_tool.sh" }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/stop.sh" }]
      }
    ]
  }
}
```

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
