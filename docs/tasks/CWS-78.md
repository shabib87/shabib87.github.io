# CWS-78 Task File

## Source

- Linear issue: `CWS-78`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-78/dev-clarify-graphite-vs-github-merge-paths-in-finalize-flow-and-harden>
- Generated: `2026-03-18`
- Status: `In Progress`

## Objective

Clarify stacked versus single-PR merge behavior so `scripts/finalize-merge.sh` is explicit about when Graphite stack merge should be used.

## Scope Snapshot

- In scope: finalize-merge messaging and prompt hardening, stacked-PR guardrail notes, tests, and workflow prompt alignment.
- Out of scope: replacing merge execution with `gt merge` in this task.

## Deterministic Acceptance Criteria

1. `scripts/finalize-merge.sh` prompt references the PR base branch target and clearly identifies single-PR merge semantics.
2. Stacked-base PRs print an explicit note directing full-stack merges to Graphite stack merge (`gt merge` or Graphite web).
3. `scripts/tests/finalize_merge_workflow_test.rb` covers the new messaging/guardrails.

## Validation Commands

- `ruby scripts/tests/finalize_merge_workflow_test.rb`
- `make qa-local`

## Completion Evidence

- Branch: `codex/cws-78-graphite-merge-flow-clarity`
- Project: `[INFRA] Repo Process & Tooling`
