# AutoDo — Universal Automation Plugin for Claude Code

A Claude Code plugin that turns `/do <anything>` into a fully autonomous execution agent.

## What it does

Type `/do` followed by any instruction. The agent will:

1. Decompose the task into subtasks
2. Execute them in parallel using all available tools
3. Record results to memory for future context

## Components

| Component | File | Role |
|-----------|------|------|
| Skill | `commands/do.md` | `/do` slash command entry point |
| Hook | `hooks/post_tool.sh` | Logs every tool call |
| Hook | `hooks/stop.sh` | Summarizes session on exit |
| MCP | filesystem, playwright, github | Extended tool access |
| Memory | `task_log.md` | Persists task history across sessions |

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
