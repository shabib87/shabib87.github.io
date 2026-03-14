# Multi-Agent Rollout Checklist

Use this checklist to track the rollout across incremental PRs.

## Phase Status

- [x] Phase 1: QA Foundation + Tracker
- [x] Phase 2: Control Plane + Ownership Lock
- [x] Phase 3: Prompt Migration (Non-Medium)
- [x] Phase 4: Docs + Policy Alignment
- [x] Phase 5: Dedicated Medium Decommission
- [ ] Phase 6: Canary + Stabilization

## Current Evidence Snapshot

- `make codex-check`: pass
- `make qa-local`: pass

## Per-Phase Acceptance Template

- PR link:
- Scope stayed phase-only:
- `make codex-check`:
- `make qa-local`:
- Socratic notes recorded:
- Red-team findings addressed:

## Ownership Lock Evidence

- [x] `team-lead` instructions explicitly forbid default prose drafting/editing.
- [x] `publisher-release` instructions explicitly forbid article body drafting.
- [x] `writer` instructions explicitly own drafting/restructuring.
- [x] `editor` instructions explicitly own editorial refinement and voice polish.

## Medium Decommission Evidence

Required grep command:

```bash
rg --hidden -n "medium-porter|medium-to-blog|@.codex/prompts/medium-to-blog.md|\\$medium-porter" . \
  -g '!.codex/docs/multi-agent-rollout-checklist.md' \
  -g '!scripts/run-codex-checks.sh' \
  -g '!.codex/rollout/phases/*'
```

- [x] command returns zero active references
- [x] deleted files are absent from the tree
- [x] docs and prompts no longer route to retired import workflows

## Canary Evidence

| Canary | Objective | Result | Notes |
| --- | --- | --- | --- |
| Site workflow | Orchestrator delegates audit -> implementation -> QA | pending | requires execution in real task thread |
| Editorial workflow | Writer + editor ownership lock holds end-to-end | pending | requires execution in real task thread |

## Socratic Review (Required Each PR)

1. What is the highest-impact failure this phase could introduce?
2. Which cheapest deterministic check catches it?
3. Which assumption was verified from repo truth or official docs?
4. What was intentionally deferred and why is deferment low risk?
5. What evidence proves ownership did not drift?
