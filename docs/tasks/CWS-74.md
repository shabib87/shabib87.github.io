# CWS-74 Task File

## Source

- Linear issue: `CWS-74`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-74/dev-enforce-task-file-agent-context-freshness-and-cws-title>
- Generated: `2026-03-18`
- Status: `Done`

## Objective

Enforce task-file presence, agent-context freshness, and issue-token traceability in `create-pr`.

## Scope Snapshot

- In scope: hard gates in `scripts/create-pr.sh` and matching tests.
- Out of scope: phase-branch migration.

## Deterministic Acceptance Criteria

1. Task branches fail PR creation when required `docs/tasks/CWS-<id>.md` is missing.
2. Stale `docs/agent-context.md` fails PR creation.
3. Inferred title must include matching issue token.

## Validation Commands

- `ruby scripts/tests/create_pr_workflow_test.rb`
- `make qa-local`

## Completion Evidence

- Completed at: `2026-03-18T18:15:39.028Z`
- Merged PR: <https://github.com/shabib87/shabib87.github.io/pull/37>
- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Project: `[INFRA] Repo Process & Tooling`
