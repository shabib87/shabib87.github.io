# Linear Reorg And Cycle Rebaseline Plan

## Summary

- Treat the live Linear cycle dates as misaligned with your intended cadence. The working plan uses `March 16-22, 2026` as the current cycle and `March 23-29, 2026` as the next cycle.
- First perform a planning re-baseline, then reorganize the workspace, then normalize cycle membership and states, then resume execution.
- Keep Linear as the execution source of truth, use Notion as the upstream editorial inbox, and use one ongoing `Blog Content Pipeline` project with per-post parent issues rather than one project per post.
- Create a separate planning memory file at `docs/planning/linear-reorg-2026-03.md` when execution starts. Keep [docs/agent-context.md](/Users/shabibhossain/Projects/CodeWithShabib/shabib87.github.io/docs/agent-context.md) as a bounded sync ledger only.

## Operating Model

- Separate `cycle scope` from `active WIP`.
- Current transition cycle scope: up to `18` committed items total because throughput is temporarily high and some items are audit-close or admin work.
- Starting `March 23, 2026`, weekly cycle scope target: `10` committed items.
- Active WIP cap across all cycles: `5` items in `Todo` or `In Progress` at a time, with at most `3` agent-executable implementation issues concurrently.
- Revisit throughput and WIP after the 2-week baseline on `April 5, 2026`.
- If Linear allows safe correction of the active cycle dates, re-anchor the team to Monday-start weekly cycles. If not, leave historical system dates alone, document `March 16-22` as the transition week in the planning log, and start formal Monday cadence from `March 23, 2026`.

## Required New Meta Work

- Add one explicit issue for `Workspace Re-baseline And Drift Audit`.
- Add one explicit issue for `Linear Reorganization And Cycle Normalization`.
- Do these before any further backlog reshuffling. The current backlog does not cleanly own the reorg itself.

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

- `March 16-22, 2026`
- Meta: `Workspace Re-baseline And Drift Audit`, `Linear Reorganization And Cycle Normalization`
- Keep already-cycled open work: `CWS-17`, `CWS-15`, `CWS-11`, `CWS-34`, `CWS-53`, `CWS-54`
- Add now: `CWS-18`, `CWS-5`, `CWS-6`, `CWS-13`, `CWS-26`, `CWS-12`, `CWS-23`, `CWS-14`, `CWS-48`, `CWS-27`
- Special handling: `CWS-17`, `CWS-14`, and `CWS-48` must be audit-close or rescope candidates if repo truth already satisfies most acceptance criteria

- `March 23-29, 2026`
- `CWS-30`, `CWS-37`, `CWS-43`, `CWS-33`, `CWS-42`, `CWS-36`, `CWS-31`, `CWS-24`, `CWS-51`, `CWS-47`

- `March 30-April 5, 2026`
- `CWS-40`, `CWS-46`, `CWS-19`, `CWS-8`, `CWS-21`, `CWS-52`, `CWS-9`, `CWS-57`, `CWS-58`, `CWS-63`

- `April 6-12, 2026`
- `CWS-29`, `CWS-38`, `CWS-55`, `CWS-60`, `CWS-67`, `CWS-68`, `CWS-71`, `CWS-28`, `CWS-35`, `CWS-59`

- `April 13-19, 2026`
- `CWS-61`, `CWS-62`, and any spillover from earlier cycles
- Keep `CWS-66` as the umbrella rollup rather than a normal execution slot unless you decide to use it as a parent tracking issue
- Keep `CWS-70` and `CWS-72` uncycled until owner decisions remove their current ambiguity

## Reorganization Shape

- Create `Content & Thought Leadership` initiative.
- Put `[EDITORIAL] Content Quality System` and new `Blog Content Pipeline` under it.
- Create `Agentic Delivery Platform` initiative.
- Put `[INFRA] Repo Process & Tooling` and `[ORCHESTRATION] Agentic Workflow Design` under it.
- Keep the existing label taxonomy. Do not recreate labels already present.
- Use project timeline, milestones, dependencies, and updates for forward planning; use cycles only for weekly commitments.
- Publish weekly project or initiative updates with health status. Pulse is monitoring only, not canonical planning.

## Skill Import Policy

- Yes, benefit from external skills by selectively vendoring them after the reorg baseline.
- First-wave imports to adapt: planning, code review, systematic debugging, verification-before-completion, pre-mortem, outcome-roadmap, summarize-meeting, and test-scenarios.
- Do not import session-governing wrappers unchanged. Re-express them as repo-native skills that obey [AGENTS.md](/Users/shabibhossain/Projects/CodeWithShabib/shabib87.github.io/AGENTS.md), Plan Mode, Linear-first pickup, and Graphite flow.

## Assumptions

- Current week remains a temporary high-throughput exception.
- Starting `March 23, 2026`, weekly pace slows to about `10` committed items.
- Human-gated items should be front-loaded only when they unlock downstream agent work.
- The reorg is tracked explicitly rather than done as off-the-books admin work.
