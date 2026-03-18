# CWS-77 Task File

## Source

- Linear issue: `CWS-77`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-77/dev-make-finalize-merge-stack-friendly-and-codify-startcloseout>
- Generated: `2026-03-18`
- Status: `Done`

## Objective

Make stack closeout merge flow Graphite-friendly by allowing rollout stack PR base branches in `scripts/finalize-merge.sh`.

## Scope Snapshot

- In scope: finalize-merge base validation update, merge-checklist output update, lifecycle policy documentation, and tests.
- Out of scope: replacing merge execution with Graphite merge commands or changing rollout branch patterns.

## Deterministic Acceptance Criteria

1. `scripts/finalize-merge.sh` accepts PR bases that are either `main` or rollout stack branches.
2. `scripts/tests/*` covers the new finalize-merge base behavior.
3. `AGENTS.md` and `docs/agent-context.md` explicitly codify start-of-work and review-closeout expectations.

## Validation Commands

- `ruby scripts/tests/create_pr_workflow_test.rb`
- `ruby scripts/tests/finalize_merge_workflow_test.rb`
- `make qa-local`

## Completion Evidence

- Completed at: `2026-03-18T18:28:26.307Z`
- Merged PR: <https://github.com/shabib87/shabib87.github.io/pull/40>
- Branch: `codex/cws-77-finalize-merge-stack-friendly`
- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Project: `[INFRA] Repo Process & Tooling`
