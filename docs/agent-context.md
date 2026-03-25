# Agent Context Ledger (Linear-Synced Cache)

This file is a bounded cache for agent continuity.

- Source of truth: Linear issues, projects, initiatives, and documents.
- Freshness SLA: 24 hours.
- Planning memory file: `docs/planning/linear-reorg-2026-03.md` (March 2026 rebaseline; may be
  superseded by a newer planning doc after the reorg is complete)
- Either platform (Codex or Claude Code) can update this ledger.
- If stale, do not trust this file until a new Linear sync pass is completed.

## Last Synced From Linear

- Synced at: `2026-03-24 22:40:00 EDT`
- Synced by: `Claude Code`
- Scope: `CWS-96 PR submission`
- Linear anchors:
  - `Content & Thought Leadership`
  - `Agentic Delivery Platform`
  - `Blog Content Pipeline`
  - `CWS-81` (Todo — parent of CWS-93, CWS-94)
  - `CWS-96` (In Progress — session chronicle)

## Stale After

- `2026-03-25 22:40:00 EDT`
- Rule: if current time is later than this timestamp, run a new Linear sync before execution.

## Active Phase

- CWS-96 (session chronicle & self-improvement loop) In Progress — PR #66, single PR (flattened from 4-PR stack).
- CWS-89 (remove dead `.cursor/rules/` directory) merged — PR #64.
- CWS-95 (remove remember plugin + curl fallback) merged — PR #63.
- CWS-94 (script hardening) merged via `gt merge` — 3-PR Graphite stack.
- CWS-93 (backlog hygiene) Done.
- CWS-81 (Linear reorganization, parent) remains Todo — check remaining sub-task scope.
- CWS-80 (Done), CWS-82 (Done).

## Top Priorities

1. CWS-81: Linear reorganization and cycle normalization (High, Todo, M1 — parent task, check remaining scope)
2. CWS-21: Define decomposition rules for single vs stacked PRs (High, Backlog, M1)
3. CWS-70: Define PR packaging behavior for agent background tasks (High, Backlog, M2)
4. CWS-72: Define auth/secret requirements for agent cloud tasks (High, Backlog, M2)
5. CWS-54: Configure Semgrep CE for security scanning (High, Backlog, M3, in current cycle)

## Open Decisions

- CWS-14/48 voice profile interview: scheduling TBD
- CWS-83 repo split: deferred post-April 19, requires git history rewrite
- Cycle date correction: not available through current Linear MCP toolset

## Active Risks

- Editorial chain blocked until voice profile interview (CWS-14/48)
- `com.apple.provenance` extended attribute on `.claude/settings.json` blocks pre-push hooks — workaround: recreate file outside sandbox or strip xattr manually

## Next Actions (snapshot — verify against Linear before executing)

1. Check CWS-81 remaining scope — both sub-tasks (CWS-93, CWS-94) are done; may be closeable
2. Pick up CWS-21 (decomposition rules — M1, High, agent-task)
3. Pick up CWS-70 (PR packaging for cloud tasks — M2, High)
4. Pick up CWS-72 (auth/secret requirements — M2, High)
5. Pick up CWS-54 (Semgrep CE — M3, High, in current cycle)
6. Pick up CWS-19 (ADR infrastructure — M2, Medium, Ready)
7. Pick up CWS-30 (pre-commit hook — M2, Medium)
8. Pick up CWS-47 (drafts-to-posts publish workflow — M2, Medium)
9. Schedule CWS-14 voice profile interview session
10. Pick up CWS-92 Docker sandbox setup

## Recent Completions

- CWS-89: Remove dead `.cursor/rules/` directory (Done, merged — PR #64)
- CWS-95: Remove remember plugin + curl fallback library, codify quality principles (Done, merged — PR #63)
- CWS-94: Harden PR scripts for stack, sandbox, and agent workflows (Done, merged — 3-PR stack)
- CWS-93: Backlog hygiene, label cleanup, and cycle rebaseline (Done, merged)
- CWS-80: Workspace rebaseline and drift audit (Done, merged)
- CWS-82: Dual-platform pivot — Claude Code as peer platform (Done, merged)
- CWS-7: Label taxonomy audit (Done, closed — cleanup executed in CWS-93)
- CWS-1, 2, 3, 4: Cancelled (Linear onboarding noise)
