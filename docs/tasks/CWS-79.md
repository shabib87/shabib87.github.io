# CWS-79 Task File

## Source

- Linear issue: `CWS-79`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-79/dev-harden-docstasks-as-immutable-context-snapshots-and-remove-status>
- Captured from Linear at: `2026-03-18 19:10:08 EDT`
- Status (Informational): `In Progress`

## Objective

Harden `docs/tasks` usage as immutable context snapshots and remove dual-status drift pressure.

## Scope Snapshot

- In scope: policy/docs/test updates that establish single-writer status ownership in Linear.
- Out of scope: new dispatch automation (`codex-dispatch.yml`) or new Linear API integration.

## Deterministic Acceptance Criteria

1. `AGENTS.md` no longer treats local task-file status updates as a merge gate.
2. A canonical `docs/tasks` template exists and codifies status as informational.
3. Repo-flow guidance and master-plan wording align to single-writer status ownership.
4. Workflow tests pass and confirm no task-status merge gate behavior.

## Validation Commands

- `ruby scripts/tests/create_pr_workflow_test.rb`
- `ruby scripts/tests/finalize_merge_workflow_test.rb`
- `make qa-local`

## Evidence Pointers (Optional)

- Branch: `codex/cws-79-task-context-single-writer`
- Project: `[INFRA] Repo Process & Tooling`
- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Local task-file `Status` is informational only and is not merge-gating.
