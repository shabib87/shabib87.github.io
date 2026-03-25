# CWS-96: Session chronicle & self-improvement loop

- **Linear:** [CWS-96](https://linear.app/codewithshabib/issue/CWS-96)
- **Branch:** `cws/96-session-chronicle`
- **Priority:** Urgent
- **Type:** infra

## Context

Claude Code sessions are ephemeral — learnings evaporate between sessions. The memory system
is reactive rather than proactive. Mistakes repeat because feedback memories aren't reliably
enforced.

## Scope

1. SessionStart hook (`chronicle-init.sh`) — creates chronicle file, injects context reminder
2. SessionEnd hook (`chronicle-end.sh`) — machine-generated summary safety net
3. `/session-retro` skill — deep retrospective with memory update proposals
4. AGENTS.md `## Session Chronicle` section — contract for event logging
5. Hook configuration in `.claude/settings.json`

## Acceptance Criteria

- SessionStart hook creates `~/.claude/projects/<project-dir>/chronicle/YYYY-MM-DD-<branch>.md`
  with correct frontmatter on startup, resume, compact, and clear events
- SessionEnd hook appends machine summary when `## Summary` section is empty
- `/session-retro` appears in Claude Code skill menu
- AGENTS.md documents the 8 event taxonomy tags
- `make qa-local` passes
