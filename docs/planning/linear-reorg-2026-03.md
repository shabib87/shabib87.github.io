# Linear Reorg And Cycle Rebaseline

Last updated: `2026-03-19 16:52:09 EDT`

## Purpose

This is the durable working log for the March 2026 Linear rebaseline and reorganization pass.
Linear remains the execution source of truth. This file records the approved operating model,
what has already been applied, the known tooling constraints, and the next planning steps.

## Confirmed Linear Changes Applied

- Created initiative `Content & Thought Leadership`.
- Created initiative `Agentic Delivery Platform`.
- Created project `Blog Content Pipeline`.
- Mapped `[EDITORIAL] Content Quality System` under `Content & Thought Leadership`.
- Mapped `Blog Content Pipeline` under `Content & Thought Leadership`.
- Mapped `[INFRA] Repo Process & Tooling` under `Agentic Delivery Platform`.
- Mapped `[ORCHESTRATION] Agentic Workflow Design` under `Agentic Delivery Platform`.
- Created meta issue `CWS-80` for workspace re-baseline and drift audit.
- Created meta issue `CWS-81` for Linear reorganization and cycle normalization.
- Linked `CWS-81` as blocked by `CWS-80`.
- Added the approved transition-week issues to the current Linear cycle object:
  `CWS-18`, `CWS-5`, `CWS-6`, `CWS-13`, `CWS-26`, `CWS-12`, `CWS-23`, `CWS-14`,
  `CWS-48`, `CWS-27`.
- Closed `CWS-17` after audit confirmed its substantive objective was already satisfied and the
  remaining `.gitkeep` requirement was stale.
- Repurposed `CWS-14` from net-new file creation to completion and normalization of the existing
  canonical voice profile.
- Repurposed `CWS-48` from net-new file creation to completion and normalization of the existing
  canonical rubric.

## Cycle-Date Constraint

- Linear current cycle object `#1` currently resolves to:
  `2026-03-19T04:00:00.000Z` through `2026-03-23T04:00:00.000Z`.
- Linear next cycle object `#2` currently resolves to:
  `2026-03-26T04:00:00.000Z` through `2026-04-02T04:00:00.000Z`.
- Those dates do not match the intended Monday-start operating cadence.
- The approved working interpretation remains:
  `March 16-22, 2026` as the transition week and `March 23-29, 2026` as the next week.
- Exact cycle-date correction is not available through the current Linear MCP toolset in this
  session. Treat the week-by-week layout below as the approved operating cadence until cycle
  settings are corrected in Linear through supported tooling.

## Operating Model

- Separate cycle scope from active WIP.
- Transition-week scope cap: up to `18` committed items.
- Starting `March 23, 2026`, weekly scope target: `10` committed items.
- Active WIP cap across all cycles: `5` items in `Todo` or `In Progress`.
- Agent-executable implementation cap inside active WIP: `3` concurrent items.
- Revisit throughput and cadence on `April 5, 2026`.
- Use initiatives, projects, milestones, and updates for forward planning.
- Use cycles only for weekly commitments.
- Use Notion as the upstream editorial inbox, not as the mutable execution source of truth.

## Dependency Backbone

- `CWS-18 -> CWS-30 -> CWS-37`
- `CWS-34 -> CWS-54 -> CWS-37`
- `CWS-18 -> CWS-5 -> CWS-12 -> CWS-43`
- `CWS-6 -> CWS-43`
- `CWS-13 -> CWS-43`
- `CWS-26 -> CWS-43`
- `CWS-17 -> CWS-15 -> CWS-11`
- `CWS-15 -> CWS-27 -> CWS-33`
- `CWS-15 -> CWS-27 -> CWS-42`
- `CWS-23 -> CWS-36`
- `CWS-23 -> CWS-31`
- `CWS-23 -> CWS-38`
- `CWS-14` and `CWS-48` unlock `CWS-24`, `CWS-51`, `CWS-47`, `CWS-40`, and `CWS-46`

## Cycle Layout

### March 16-22, 2026

- Meta: `CWS-80`, `CWS-81`
- Keep already-cycled open work:
  `CWS-17`, `CWS-15`, `CWS-11`, `CWS-34`, `CWS-53`, `CWS-54`
- Add now:
  `CWS-18`, `CWS-5`, `CWS-6`, `CWS-13`, `CWS-26`, `CWS-12`, `CWS-23`, `CWS-14`,
  `CWS-48`, `CWS-27`
- Audit-close or rescope candidates if repo truth already satisfies most criteria:
  `CWS-17`, `CWS-14`, `CWS-48`

### March 23-29, 2026

- `CWS-30`, `CWS-37`, `CWS-43`, `CWS-33`, `CWS-42`,
  `CWS-36`, `CWS-31`, `CWS-24`, `CWS-51`, `CWS-47`

### March 30-April 5, 2026

- `CWS-40`, `CWS-46`, `CWS-19`, `CWS-8`, `CWS-21`,
  `CWS-52`, `CWS-9`, `CWS-57`, `CWS-58`, `CWS-63`

### April 6-12, 2026

- `CWS-29`, `CWS-38`, `CWS-55`, `CWS-60`, `CWS-67`,
  `CWS-68`, `CWS-71`, `CWS-28`, `CWS-35`, `CWS-59`

### April 13-19, 2026

- `CWS-61`, `CWS-62`, plus spillover from earlier cycles
- Keep `CWS-66` as umbrella or parent tracking work, not normal execution throughput
- Keep `CWS-70` and `CWS-72` uncycled until owner decisions remove ambiguity

## External Skill Policy

- Selectively vendor high-fit skills after the reorg baseline is complete.
- First wave to adapt:
  planning, code review, systematic debugging, verification-before-completion, pre-mortem,
  outcome-roadmap, summarize-meeting, and test-scenarios.
- Do not import session-governing wrappers unchanged.
- Re-express imported skills as repo-native skills that follow `AGENTS.md`, Plan Mode,
  Linear-first pickup, and Graphite flow.

## Rebaseline Findings

- The repo was missing the dedicated planning memory file at pickup. This file backfills that
  gap and becomes the long-running local planning record.
- The repo was also missing `docs/tasks/CWS-80.md` and `docs/tasks/CWS-81.md` at pickup.
- Task-file semantics were clarified during `CWS-80`: `docs/tasks/CWS-<id>.md` is a pickup or
  start-of-work artifact, not a backlog-audit artifact.
- Temporary audit-created task snapshots for untouched issues `CWS-14` and `CWS-48` were removed
  after that clarification.
- `docs/tasks/CWS-17.md` was retained because the issue was audit-closed with no rework needed.
- Untouched cycle-linked backlog items may intentionally remain without local task snapshots until
  they are actually picked up for execution.
- `docs/agent-context.md` had stale NEXT-10 execution guidance and required reset to the current
  planning phase.
- `_drafts/` still exists in the repo while `.gitignore` still excludes `_drafts/`; this remains
  an editorial-policy contradiction to resolve separately.
- `CWS-14` and `CWS-48` were stale as net-new creation tasks. They now remain open as completion
  and normalization tasks for existing canonical artifacts.
- Future week allocations are approved as the operating plan, but exact date-true cycle mapping
  cannot be enforced until Linear cycle settings are corrected through supported tooling.

## Next Steps

1. Continue `CWS-80` by auditing the remaining transition-cycle issues for dependency drift, stale
   wording, and repo-versus-Linear mismatches without creating untouched task files.
2. Record any additional repo-versus-Linear evidence gaps or rescope notes discovered during that
   pass in `CWS-80`.
3. Decide whether future cycle assignments stay documented only or are applied after cycle
   settings are corrected in Linear.
4. After `CWS-80` evidence is complete, continue `CWS-81` normalization and start weekly update
   hygiene on the new initiatives and projects.
