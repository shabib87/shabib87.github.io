# CWS-95: Remove redundant plugin and curl fallback

- **Linear:** [CWS-95](https://linear.app/codewithshabib/issue/CWS-95)
- **Branch:** `cws/95-remove-remember-plugin`
- **Priority:** Low
- **Type:** cleanup

## Context

Two pieces of infrastructure are redundant and add complexity for zero benefit:

1. **Remember plugin** (`remember@claude-plugins-official`) — installed but never used
   (`.remember/remember.md` stayed 0 bytes). Built-in auto memory + `docs/agent-context.md`
   already provide cross-session continuity.

2. **`scripts/lib/github-api.sh`** curl fallback library — was a workaround for `gh` CLI TLS
   issues in the Claude Code sandbox. Now that `gh` auth is fixed, the 332-line curl fallback
   with Ruby JSON parsing is unnecessary complexity.

## Scope

### Remember plugin

1. Delete `.claude/remember/config.json` (tracked)
2. Remove `.remember/` gitignore entry
3. Remove `Skill(remember)` from `.claude/settings.local.json` allowlist

### github-api.sh removal

1. Delete `scripts/lib/github-api.sh`
2. Refactor `scripts/create-pr.sh` — direct `gh` CLI calls
3. Refactor `scripts/finalize-merge.sh` — direct `gh` CLI calls
4. Update test assertions in both workflow test files
5. Update `.agents/skills/repo-flow/SKILL.md` — remove fallback section
6. Update `.agents/skills/repo-flow/references/branch-pr-merge.md`

### Not touched (historical/immutable)

- `docs/superpowers/plans/2026-03-22-script-hardening.md`
- `docs/superpowers/specs/2026-03-22-script-hardening-design.md`
- `.codex/rollout/evidence/cws-94-fallback-and-flags.md`

## Out of Scope

- Plugin uninstall command (requires interactive CLI)
- Changes to built-in auto memory configuration
