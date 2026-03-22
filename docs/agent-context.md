# Agent Context Ledger (Linear-Synced Cache)

This file is a bounded cache for agent continuity.

- Source of truth: Linear issues, projects, initiatives, and documents.
- Freshness SLA: 24 hours.
- Planning memory file: `docs/planning/linear-reorg-2026-03.md` (March 2026 rebaseline; may be
  superseded by a newer planning doc after the reorg is complete)
- Either platform (Codex or Claude Code) can update this ledger.
- If stale, do not trust this file until a new Linear sync pass is completed.

## Last Synced From Linear

- Synced at: `2026-03-22 12:00:00 EDT`
- Synced by: `Claude Code`
- Scope: `CWS-93 backlog hygiene, label cleanup, and cycle rebaseline`
- Linear anchors:
  - `Content & Thought Leadership`
  - `Agentic Delivery Platform`
  - `Blog Content Pipeline`
  - `CWS-93` (In Progress)

## Stale After

- `2026-03-23 12:00:00 EDT`
- Rule: if current time is later than this timestamp, run a new Linear sync before execution.

## Active Phase

- CWS-93 (backlog hygiene) is in progress.
- Phase 1 (Linear mutations) complete. Phase 2 (repo changes) in Graphite stack.
- CWS-80 (Done), CWS-82 (Done).

## Top Priorities

1. Complete CWS-93 backlog hygiene (this task)
2. CWS-81 normalization (parent)
3. Infrastructure chain: CWS-18 → CWS-5 → CWS-12

## Open Decisions

- CWS-14/48 voice profile interview: scheduling TBD
- CWS-83 repo split: deferred post-April 19, requires git history rewrite
- Cycle date correction: not available through current Linear MCP toolset

## Active Risks

- Editorial chain blocked until voice profile interview (CWS-14/48)
- Semgrep post-tool hook erroring (no SEMGREP_APP_TOKEN) — non-blocking but noisy

## Next Actions (snapshot — verify against Linear before executing)

1. Merge CWS-93 Graphite stack
2. Close CWS-44 (agent-context schema) after agent-context.md rewrite merges
3. Update CWS-81 remaining scope
4. Pick up CWS-18 (next infrastructure task)
5. Pick up CWS-5 (blocked by CWS-18)
6. Schedule CWS-14 voice profile interview session
7. Pick up CWS-13 (Vale config — unblocks CWS-25, CWS-32)
8. Pick up CWS-23 (unblocks CWS-36, CWS-31, CWS-38)
9. Correct Linear cycle dates through supported tooling
10. Pick up CWS-92 Docker sandbox setup

## Recent Completions

- CWS-80: Workspace rebaseline and drift audit (Done, merged)
- CWS-82: Dual-platform pivot — Claude Code as peer platform (Done, merged)
- CWS-7: Label taxonomy audit (Done, closed — cleanup executed in CWS-93)
- CWS-1, 2, 3, 4: Cancelled (Linear onboarding noise)
