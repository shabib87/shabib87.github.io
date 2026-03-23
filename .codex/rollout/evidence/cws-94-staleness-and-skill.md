# CWS-94 PR 3: Staleness Mechanism + Repo-Flow Skill Update

## Changes

- Created `.claude/hooks/check-agent-context-staleness.sh` SessionStart hook (D7)
- Added post-merge staleness timestamp bump to `finalize-merge.sh` (D7)
- Rewrote `.agents/skills/repo-flow/SKILL.md` with task-only + stack + fallback docs (D9)
- Updated `.agents/skills/repo-flow/references/branch-pr-merge.md` (D9)
- Created task file `docs/tasks/CWS-94.md`

## Validation

- `make qa-local` passed
- SessionStart hook correctly parses staleness timestamp
- repo-flow skill frontmatter triggers on workflow scripts and git commands
