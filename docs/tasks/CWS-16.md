# CWS-16 Task File (Backfilled)

## Source

- Linear issue: `CWS-16`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-16/dev-migrate-branch-naming-to-linear-first-convention>
- Backfilled: `2026-03-18`
- Status: `Done`

## Objective

Resolve branch-policy conflicts so normal execution uses `codex/cws-<id>-<slug>` while rollout governance keeps `codex/phase-<n>-<slug>` support.

## Scope Snapshot

- In scope: dual branch-pattern support across scripts, tests, and docs.
- Out of scope: rollout manifest/evidence model redesign and policy bypass paths.

## Deterministic Acceptance Criteria (Snapshot)

1. Normal task branch standard is `codex/cws-<id>-<slug>`.
2. Rollout validation accepts both compliant task and phase branch modes.
3. `create-pr` and `finalize-merge` do not fail solely because branch is `codex/cws-*`.

## Validation Commands (From Linear)

- `bash scripts/run-rollout-governance-tests.sh`
- `make codex-check`
- `make qa-local`

## Completion Evidence

- Completed at: `2026-03-17T05:24:08.717Z`
- Merged PR: <https://github.com/shabib87/shabib87.github.io/pull/30>
- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Project: `[INFRA] Repo Process & Tooling`
