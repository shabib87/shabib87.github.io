# Linear Reorg And Cycle Rebaseline

Last updated: `2026-03-22 12:00:00 EDT`

## Purpose

This is the durable working log for the March 2026 Linear rebaseline and reorganization pass.
Linear remains the execution source of truth. This file records the approved operating model,
what has already been applied, the known tooling constraints, and the next planning steps.

## Confirmed Baseline

- Initiative `Content & Thought Leadership` owns `[EDITORIAL] Content Quality System` and
  `Blog Content Pipeline`.
- Initiative `Agentic Delivery Platform` owns `[INFRA] Repo Process & Tooling` and
  `[ORCHESTRATION] Agentic Workflow Design`.
- `Blog Content Pipeline` is the single ongoing blog execution project.
- Notion is the upstream note and research inbox. Linear is the execution source of truth.
- Dual-platform pivot (`CWS-82`, Done) added Claude Code as peer platform alongside Codex.
- `CWS-17` closed after audit confirmed its substantive objective was already satisfied.
- `CWS-14` and `CWS-48` repurposed to complete and normalize existing canonical editorial
  artifacts rather than create from scratch.

## Applied Changes (CWS-93 Backlog Hygiene)

Executed 2026-03-22 as part of CWS-93:

- **Label cleanup**: 39 labels reduced to 15 approved labels. 6 absorbed into parent epics
  (`epic:dor-dod` → `epic:dx-setup`, `epic:adr` → `epic:dx-setup`,
  `epic:publish-draft` → `epic:editorial-qa`, `epic:git-hooks` → `epic:ci-pipeline`,
  `epic:security` → `epic:safety`, `epic:triggers` → `epic:reasoning`). 24 labels to delete
  via Linear web UI.
- **Branch convention**: `codex/cws-<id>-<slug>` renamed to `cws/<id>-<slug>` across 14 files.
- **Agent-context.md**: Rewritten to CWS-44 8-section schema.
- **Label taxonomy**: Added to AGENTS.md as canonical reference.
- **Repo-flow skill**: Hardened with Gotchas, MUST NOT rules, validation loop, cross-skill refs.
- **Issue updates**: ~20 issues updated (priorities, milestones, descriptions, relations).
- **CWS-7**: Closed (label taxonomy audit done).
- **CWS-1-4**: Verified cancelled (Linear onboarding noise).

## Cycle-Date Constraint

- Linear cycle objects do not match the intended Monday-start operating cadence.
- Exact cycle-date correction is not available through the current Linear MCP toolset.
- Treat week-by-week layout below as approved operating cadence until cycle settings are
  corrected through supported tooling.

## Operating Model

- Soft cycles: spillover is expected, WIP cap provides discipline.
- Active WIP cap across all cycles: `5` items in `Todo` or `In Progress`.
- Agent-executable implementation cap inside active WIP: `3` concurrent items.
- Use initiatives, projects, milestones, and updates for forward planning.
- Use cycles only for weekly commitments.
- Use Notion as the upstream editorial inbox, not as the mutable execution source of truth.

## Dependency Backbone

- `CWS-18` → `CWS-30` → `CWS-37`
- `CWS-34` → `CWS-54` → `CWS-37`
- `CWS-18` → `CWS-5` → `CWS-12` → `CWS-43`
- `CWS-6` → `CWS-43`
- `CWS-13` → `CWS-25`, `CWS-32` (Vale config prerequisite)
- `CWS-26` → `CWS-43`
- `CWS-23` → `CWS-36`, `CWS-31`, `CWS-38`
- `CWS-14`, `CWS-48` → `CWS-24`, `CWS-51`, `CWS-47`, `CWS-40`, `CWS-46`
- `CWS-63` blocked by `CWS-55`

## Cycle Layout

### March 16-22, 2026 (transition week — mostly done)

- Done: `CWS-80`, `CWS-82`, `CWS-7`, `CWS-1-4` (cancelled)
- In progress: `CWS-93` (backlog hygiene), `CWS-81` (parent normalization)
- Carried: `CWS-17` (closed), `CWS-15`, `CWS-11`, `CWS-34`, `CWS-53`, `CWS-54`

### March 23-29, 2026

- Infrastructure chain: `CWS-18`, `CWS-5`, `CWS-12`
- Workflow: `CWS-23`, `CWS-13`, `CWS-6`, `CWS-26`
- Editorial prep: `CWS-14`, `CWS-48` (voice profile interview required)
- New issues: `CWS-88`, `CWS-89`, `CWS-91` (M2 Tooling Foundation)

### March 30-April 5, 2026

- Dependent work: `CWS-30`, `CWS-37`, `CWS-43`, `CWS-36`, `CWS-31`
- Editorial (if unblocked): `CWS-24`, `CWS-51`, `CWS-47`
- Safety: `CWS-90`, `CWS-92` (Docker sandbox)

### April 6-12, 2026

- `CWS-38`, `CWS-55`, `CWS-33`, `CWS-42`
- Skills: `CWS-29`, `CWS-39`, `CWS-58` (renamed platform-agnostic)
- Dual-platform: `CWS-66-72` (renamed platform-agnostic, milestone-assigned)

### April 13-19, 2026

- `CWS-61`, `CWS-62`, plus spillover
- Deferred: `CWS-83-87` (repo split family, Low priority, requires git history rewrite)
- Keep `CWS-70`, `CWS-72` uncycled until owner decisions remove ambiguity

## Lessons Learned

- **CWS-82 stack merge (2026-03-20)**: Merging stacked PRs with ad hoc `gh pr merge` then
  `gt sync --force` deleted child branches and closed their PRs, losing unmerged changes.
  Root cause: (1) used raw `gh pr merge` instead of `make finalize-merge`, bypassing validation
  gates; (2) ran `gt sync --force` to reconcile, which treats orphaned branches as stale.
  **Resolution**: Encoded in repo-flow SKILL.md Gotchas and MUST NOT rules. Use `gt merge` or
  Graphite web for full-stack merges. If partially merged, retarget children manually — never
  `gt sync --force`.

## Blocked Chains

- **Editorial**: `CWS-14`/`CWS-48` voice profile interview blocks `CWS-24`, `CWS-40`,
  `CWS-46`, `CWS-47`, `CWS-51`. User must schedule interview session.
- **Repo split**: `CWS-83` family (83-87) deferred to Low priority, post-April 19. Requires
  git history rewrite to remove infra work from public commit history.

## External Skill Policy

- Selectively vendor high-fit skills after the reorg baseline is complete.
- First wave to adapt: planning, code review, systematic debugging,
  verification-before-completion, pre-mortem, outcome-roadmap, summarize-meeting, test-scenarios.
- Re-express imported skills as repo-native skills that follow `AGENTS.md`, Plan Mode,
  Linear-first pickup, and Graphite flow.

## Next Steps

1. Merge CWS-93 Graphite stack and close CWS-44.
2. Update CWS-81 remaining scope after CWS-93 merges.
3. Pick up CWS-18 (next infrastructure task in the chain).
4. Schedule CWS-14 voice profile interview to unblock editorial chain.
5. Correct Linear cycle dates through supported tooling when available.
6. Delete 24 labels via Linear web UI (not available through MCP).
7. Update `agent-task` label description via Linear web UI.
8. Remove 3 project target dates via Linear web UI.
