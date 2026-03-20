# CWS-17 Task File

## Source

- Linear issue: `CWS-17`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-17/dev-create-docstasksgitkeep-for-per-task-file-system>
- Captured from Linear at: `2026-03-19 16:32:21 EDT`

## Objective

Establish the `docs/tasks/` baseline so every issue can have deterministic task file evidence.

## Scope Snapshot

- In scope: ensure the `docs/tasks/` directory is tracked and usable as the canonical per-task
  evidence location.
- In scope: confirm downstream issues can rely on `docs/tasks/CWS-NNN.md`.
- Out of scope: dispatch automation implementation.

## Deterministic Acceptance Criteria

1. The repo has a tracked `docs/tasks/` location for immutable task snapshots.
2. A template or equivalent baseline exists for deterministic task-file structure.
3. Downstream task-file issues can target `docs/tasks/CWS-NNN.md` without ambiguity.
4. Any stale `.gitkeep`-specific expectation is explicitly called out in audit evidence.

## Validation Commands

- `rg --files docs/tasks`
- `rg -n "docs/tasks/CWS-|docs/tasks/.gitkeep" AGENTS.md docs/master-plan.md docs/tasks/TEMPLATE.md`

## Evidence Pointers (Optional)

- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Project: `[INFRA] Repo Process & Tooling`
- Milestone: `M1 Governance Baseline`

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Do not maintain mutable status in task files; keep status changes in Linear only.
