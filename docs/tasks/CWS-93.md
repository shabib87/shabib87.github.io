# CWS-93: Backlog Hygiene, Label Cleanup, and Cycle Rebaseline

- Linear: <https://linear.app/codewithshabib/issue/CWS-93>
- Parent: CWS-81
- Branch: `cws/93-branch-prefix-rename` (stack base)
- Spec: `docs/superpowers/specs/2026-03-22-backlog-hygiene-design.md`
- Plan: `docs/superpowers/plans/2026-03-22-backlog-hygiene.md`

## Scope

Phase 1: Linear mutations (label cleanup 39 to 15, issue updates, project date removal,
cycle rewrite).

Phase 2: Graphite stack of 4 PRs (branch prefix rename, AGENTS.md label taxonomy plus
agent-context rewrite, repo-flow hardening, planning doc rewrite).

## Evidence

- `make qa-local` passed on committed tree
- CWS-44 8-section validation passed (8 section headers in agent-context.md)
- Branch prefix grep returned zero matches for `codex/(cws|phase|[a-z]+-)`
- Label count reduced from 39 to 15 (24 pending deletion via Linear web UI)
