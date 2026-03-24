# CWS-95: Remove remember plugin — redundant with built-in auto memory

- **Linear:** [CWS-95](https://linear.app/codewithshabib/issue/CWS-95)
- **Branch:** `cws/95-remove-remember-plugin`
- **Priority:** Low
- **Type:** cleanup

## Context

The `remember@claude-plugins-official` third-party plugin was installed to provide cross-session
memory but is redundant with Claude Code's built-in auto memory system (`~/.claude/projects/.../memory/`)
and the project's `docs/agent-context.md` staleness-enforced context ledger.

Evidence of non-use: `.remember/remember.md` is 0 bytes after multiple sessions.

## Scope

1. Delete `.claude/remember/config.json` (tracked)
2. Remove `.remember/` gitignore entry (directory is untracked, will be deleted locally)
3. Remove `Skill(remember)` from `.claude/settings.local.json` allowlist
4. Plugin uninstall (`/plugin uninstall`) is a manual step — user must run interactively

## Out of Scope

- Actual plugin uninstall command (requires interactive CLI)
- Changes to built-in auto memory configuration
