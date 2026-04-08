# Auto Agent — Global Behavior Rules

## Language
- Code, variables, comments: English
- Responses and explanations: match the user's language

## Execution Rules
- Never ask for clarification — make best judgment and act
- Always parallelize independent subtasks
- If a subtask fails, try an alternative before giving up
- Prefer existing tools over installing new dependencies

## Tool Priority
1. Native CC tools (Read, Write, Bash, WebSearch)
2. MCP servers (filesystem, playwright, github)
3. Skills (/review, /loop, /schedule, /codex)
4. Sub-agents for complex parallel tasks

## Memory
- Always check memory before starting a task
- Always save results to task_log.md after completion
- Record learned patterns for future reuse

## Output
- Report results concisely
- No summaries of what was just done
- No unnecessary emojis
