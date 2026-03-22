# CWS-93: Backlog Hygiene, Label Cleanup, and Cycle Rebaseline

## Source

- Linear issue: `CWS-93`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-93>
- Captured from Linear at: `2026-03-22 04:00:00 EDT`

## Objective

Execute full backlog hygiene: consolidate labels (39→15), update issue metadata,
rewrite agent-context to CWS-44 schema, rename branch prefix, and harden repo-flow skill.

## Scope Snapshot

- In scope: Linear API mutations (labels, issues, projects, cycles), 4-PR Graphite stack
  (branch prefix rename, label taxonomy + agent-context rewrite, repo-flow hardening,
  planning doc rewrite).
- Out of scope: label deletion via Linear web UI (manual), cycle date correction
  (not available via MCP), CWS-83 repo split.

## Deterministic Acceptance Criteria

1. Label count reduced from 39 to 15 in Linear.
2. `agent-context.md` passes CWS-44 8-section schema validation.
3. `rg "codex/(cws|phase|[a-z]+-)"` returns zero matches in scripts and config.
4. `make qa-local` passes on committed tree.
5. 4-PR Graphite stack submitted and reviewed.

## Validation Commands

- `make qa-local`
- `rg "codex/(cws|phase|[a-z]+-)" --type sh --type yaml`
- `grep -c "^## " docs/agent-context.md` (expect 8)

## Evidence Pointers

- PRs: #54, #55, #56, #57
- Spec: `docs/superpowers/specs/2026-03-22-backlog-hygiene-design.md`
- Plan: `docs/superpowers/plans/2026-03-22-backlog-hygiene.md`
- Parent: CWS-81
- Branch (stack base): `cws/93-branch-prefix-rename`

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Do not maintain mutable status in task files; keep status changes in Linear only.
