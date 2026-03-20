# CWS-81 Task File

## Source

- Linear issue: `CWS-81`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-81/dev-linear-reorganization-and-cycle-normalization>
- Captured from Linear at: `2026-03-19 08:51:57 EDT`

## Objective

Implement the approved Linear workspace reorganization and weekly cycle normalization plan after
the workspace re-baseline is complete.

## Scope Snapshot

- In scope: create the approved initiatives.
- In scope: create `Blog Content Pipeline` as a new project.
- In scope: re-map the existing projects under the approved initiative structure.
- In scope: normalize current-cycle membership for the transition week and lay out the planned
  future cycle allocations.
- In scope: keep the existing label taxonomy intact.
- Out of scope: recreating existing labels.
- Out of scope: per-post project creation.
- Out of scope: unrelated feature implementation.

## Deterministic Acceptance Criteria

1. Approved initiatives and project mapping are applied in Linear.
2. Current-cycle scope reflects the approved transition-week plan.
3. Future weekly cycle layout is documented without guessing.
4. Any tooling limitation preventing exact cycle-date correction is explicitly recorded.

## Validation Commands

- `[HUMAN-REVIEW]` Verify initiatives, project mapping, and cycle allocations match the approved plan.
- `rg -n "Blog Content Pipeline|cycle layout|March 23-29, 2026|April 13-19, 2026" docs/planning/linear-reorg-2026-03.md docs/agent-context.md`

## Evidence Pointers (Optional)

- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Project: `[ORCHESTRATION] Agentic Workflow Design`
- Milestone: `M1 Contract Canonicalization`
- Dependency note: blocked by `CWS-80`

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Do not maintain mutable status in task files; keep status changes in Linear only.
