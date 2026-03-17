# Rollout Governance Checklist

Use this checklist for any rollout plan driven by
`.codex/rollout/active-plan.yaml`.

## Plan Contract

- [ ] `active-plan.yaml` exists and is valid (`version: 1`, `plan_id`, `mode: sequential`).
- [ ] `task_branch_pattern` allows task branches (`^codex/cws-\d+-...`).
- [ ] `phase_branch_pattern` remains phase-based (`^codex/phase-(\d+)-...`).
- [ ] `required_checks` includes `build`, `semgrep`, `rollout-governance`.
- [ ] size caps are non-content only:
  - `limits.max_changed_files_non_content`
  - `limits.max_changed_lines_non_content`
  - `limits.ignore_paths_for_size_caps` includes `_posts/**`, `_pages/**`, `_drafts/**`.

## Dynamic Phase Tracker

Phases are dynamic (`1..N`) and discovered from:
`.codex/rollout/plans/<plan-id>/phase-<n>.txt`.

| Phase | PR | Status | Evidence |
| --- | --- | --- | --- |
| 1 | | | `.codex/rollout/evidence/<plan-id>/phase-1.md` |
| 2 | | | `.codex/rollout/evidence/<plan-id>/phase-2.md` |
| n | | | `.codex/rollout/evidence/<plan-id>/phase-<n>.md` |

## Per-Phase Acceptance

- [ ] scope stayed phase-only (`phase-<n>.txt`).
- [ ] `make codex-check` passed.
- [ ] `make qa-local` passed.
- [ ] phase evidence file contains both `RED` and `GREEN`.
- [ ] PR base is `main` and lower phases are already merged.

## Long-Post Safe Rules

- `_posts/**`, `_pages/**`, `_drafts/**` are excluded from size caps only.
- Those paths are still enforced by phase scope manifests.
- Broad content wildcards in manifests are blocked (for example `_posts/*`).

## Socratic Review (Required Each PR)

1. What is the highest-impact failure this phase could introduce?
2. Which cheapest deterministic check catches it?
3. Which assumption was verified from repo truth or official docs?
4. What was intentionally deferred and why is deferment low risk?
5. What evidence proves ownership did not drift?
