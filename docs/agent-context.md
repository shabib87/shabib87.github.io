# Agent Context Ledger (Linear-Synced Cache)

This file is a bounded cache for agent continuity.

- Source of truth: Linear issues, projects, initiatives, and documents.
- Freshness SLA: 24 hours.
- Planning memory file: `docs/planning/linear-reorg-2026-03.md`
- Either platform (Codex or Claude Code) can update this ledger.
- If stale, do not trust this file until a new Linear sync pass is completed.

## Last Synced From Linear

- Synced at: `2026-03-19 16:52:09 EDT`
- Synced by: `Claude Code`
- Scope: `CWS-80/CWS-81 March 2026 workspace rebaseline and Linear reorganization`
- Linear anchors:
  - `Content & Thought Leadership`
  - `Agentic Delivery Platform`
  - `Blog Content Pipeline`
  - `CWS-80`
  - `CWS-81`

## Stale After

- `2026-03-20 16:52:09 EDT`
- Rule: if current time is later than this timestamp, run a new Linear sync before execution.

## Active Phase

- Planning rebaseline is active.
- Do not use the old NEXT-10 execution queue as the current planning source.
- Resume normal feature pickup only after `CWS-80` evidence is complete and `CWS-81` decisions are
  fully documented.

## Confirmed Baseline

- `Content & Thought Leadership` owns `[EDITORIAL] Content Quality System` and
  `Blog Content Pipeline`.
- `Agentic Delivery Platform` owns `[INFRA] Repo Process & Tooling` and
  `[ORCHESTRATION] Agentic Workflow Design`.
- `Blog Content Pipeline` is the single ongoing blog execution project.
- Notion is the upstream note and research inbox. Linear is the execution source of truth.
- Meta work exists for workspace drift audit and reorganization normalization in `CWS-80` and
  `CWS-81`.
- `CWS-17` is closed after audit confirmed its substantive objective was already satisfied.
- `CWS-14` and `CWS-48` remain open but were repurposed to complete and normalize existing
  canonical editorial artifacts rather than create them from scratch.
- Task-file semantics were clarified: local `docs/tasks/CWS-<id>.md` files should exist at
  pickup or start-of-work, not for untouched backlog audit only.
- Cycle-linked backlog items may therefore intentionally lack local task snapshots until they are
  actually started.
- The current Linear cycle objects do not match the intended Monday-start cadence.
- Treat `March 16-22, 2026` as the transition week in planning memory until cycle settings are
  corrected through supported tooling.

## Active Risks

- Repo and Linear still diverge on some planning evidence and editorial policy details,
  especially `_drafts/` tracking policy.
- Future weekly allocations are approved as a working plan but not yet date-true Linear cycle
  truth.
- Any agent resuming from this file must read `docs/planning/linear-reorg-2026-03.md` before
  continuing backlog normalization.

## Lessons Learned

- CWS-82 stack merge (2026-03-20): merging stacked PRs with ad hoc `gh pr merge` then
  `gt sync --force` deleted child branches and closed their PRs, losing unmerged changes.
  Two failures: (1) used raw `gh pr merge` instead of `make finalize-merge`, bypassing rollout
  plan validation gates; (2) ran `gt sync --force` to reconcile the stack, which treats orphaned
  branches as stale and deletes them. `make finalize-merge` warns about stacks and directs to
  `gt merge`, but it merges one PR at a time and does not manage Graphite metadata or retarget
  children. For Graphite stacks, use `gt merge` or Graphite web for full-stack merges. If a
  stack is already partially merged outside Graphite, retarget children manually
  (`gh pr edit --base main`) — never `gt sync --force`.

## Next Local Actions

- Finish `CWS-80` blocker-first in this order:
  `CWS-18`, `CWS-15`, `CWS-34`, `CWS-23`, then the dependent or supporting issues
  `CWS-5`, `CWS-12`, `CWS-27`, `CWS-54`, `CWS-6`, `CWS-13`, `CWS-26`, `CWS-53` as needed.
- During that audit, only record dependency drift, stale wording, repo-versus-Linear mismatch,
  and rescope notes. Do not create untouched task files.
- After `CWS-80` evidence is complete, move `CWS-81` into active execution and use it to
  normalize the current transition-cycle scope and document future weeks as the working cadence
  until Linear cycle settings are corrected.
- After `CWS-81` normalization is stable, start weekly initiative or project update hygiene with
  health status for the new planning structure.
- Keep the planning memory file current as the long-running local record.
