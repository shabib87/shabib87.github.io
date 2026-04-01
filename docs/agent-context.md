# Agent Context Ledger (Linear-Synced Cache)

This file is a bounded cache for agent continuity.

- Source of truth: Linear issues, projects, initiatives, and documents.
- Freshness SLA: 24 hours.
- Planning memory file: `docs/planning/linear-reorg-2026-03.md` (March 2026 rebaseline; may be
  superseded by a newer planning doc after the reorg is complete)
- Either platform (Codex or Claude Code) can update this ledger.
- If stale, do not trust this file until a new Linear sync pass is completed.

## Last Synced From Linear

- Synced at: `2026-03-25 00:30:00 EDT`
- Synced by: `Claude Code`
- Scope: `CWS-96 DoD closeout + full Linear queue sync`
- Linear anchors:
  - `Content & Thought Leadership`
  - `Agentic Delivery Platform`
  - `Blog Content Pipeline`
  - `CWS-81` (Todo — Linear reorg, blocks CWS-97/100/101)
  - `CWS-96` (Done — session chronicle, merged PR #66)

## Stale After

- `2026-04-01 20:14:17 EDT`
- Rule: if current time is later than this timestamp, run a new Linear sync before execution.

## Active Phase

- CWS-81 (Linear reorganization, parent) remains Todo — check remaining sub-task scope.
- No active implementation work in progress.

## Top Priorities

1. CWS-81: Linear reorganization and cycle normalization (High, Todo, M1, in cycle — blocks CWS-97, CWS-100, CWS-101)
2. CWS-21: Define decomposition rules for single vs stacked PRs (High, Backlog, M1, in cycle — PICKUP_READY: NO)
3. CWS-98: Add planning-flow guardrail rule for Claude Code agents (High, Backlog, M2, agent-task)
4. CWS-99: Create planning-flow process skill for Claude.ai (High, Backlog, M2, human-task)
5. CWS-54: Configure Semgrep CE for security scanning (High, Backlog, M3, in cycle, agent-task)
6. CWS-70: Define PR packaging behavior for agent background tasks (High, Backlog, M2)
7. CWS-72: Define auth/secret requirements for agent cloud tasks (High, Backlog, M2)
8. CWS-100: Linear issue creation skill (High, Backlog, M2, human-task — blocked by CWS-81)
9. CWS-102: Create private skills repo with marketplace distribution (High, Backlog, M2, human-task)

## Open Decisions

- CWS-14/48 voice profile interview: scheduling TBD
- CWS-83 repo split: deferred post-April 19, requires git history rewrite
- Cycle date correction: not available through current Linear MCP toolset

## Active Risks

- Editorial chain blocked until voice profile interview (CWS-14/48)
- `com.apple.provenance` extended attribute on `.claude/settings.json` blocks pre-push hooks — workaround: recreate file outside sandbox or strip xattr manually
- Claude Code sandbox denies write to `.claude/skills/` and `.claude/settings.json` — git operations (rebase, checkout, cherry-pick) touching these paths must be run by the user outside sandbox

## Session Learnings (CWS-96)

- Repo-flow skill Procedure steps 5-9 (Linear state transitions, cycle linkage, traceability) are hard requirements, not optional housekeeping. Execute them as a sequential checklist.
- `make finalize-merge` handles the mechanical merge. Agent responsibilities around it (Linear Done, agent-context content sync) are defined in repo-flow Procedure and AGENTS.md DoD — not in the script. Don't reframe skipped agent steps as tooling gaps.
- Sandbox-protected paths (`.claude/`) cause git operation failures. When a multi-branch workflow (stacked PRs, rebases) touches these paths, prefer single-branch strategies to avoid cascading sandbox conflicts.

## Next Actions (snapshot — verify against Linear before executing)

1. Pick up CWS-81 (Linear reorg — High, Todo, M1, in cycle, agent-task, blocks 3 downstream issues)
2. Pick up CWS-98 (planning-flow guardrail — High, Backlog, M2, agent-task)
3. Pick up CWS-54 (Semgrep CE — High, Backlog, M3, in cycle, agent-task)
4. Pick up CWS-21 (decomposition rules — High, Backlog, M1, in cycle — check pickup gate after CWS-81)
5. Pick up CWS-67 (agent background execution contract — High, Backlog, M2, agent-task)
6. Pick up CWS-68 (bootstrap preflight — High, Backlog, M2, agent-task)
7. Pick up CWS-70 (PR packaging for cloud tasks — High, Backlog, M2, agent-task)
8. Pick up CWS-72 (auth/secret requirements — High, Backlog, M2, agent-task)
9. Schedule CWS-14 voice profile interview session
10. Pick up CWS-92 Docker sandbox setup

## Recent Completions

- CWS-96: Session chronicle & self-improvement loop (Done, merged — PR #66)
- CWS-89: Remove dead `.cursor/rules/` directory (Done, merged — PR #64)
- CWS-95: Remove remember plugin + curl fallback library, codify quality principles (Done, merged — PR #63)
- CWS-94: Harden PR scripts for stack, sandbox, and agent workflows (Done, merged — 3-PR stack)
- CWS-93: Backlog hygiene, label cleanup, and cycle rebaseline (Done, merged)
- CWS-80: Workspace rebaseline and drift audit (Done, merged)
- CWS-82: Dual-platform pivot — Claude Code as peer platform (Done, merged)
- CWS-7: Label taxonomy audit (Done, closed — cleanup executed in CWS-93)
- CWS-1, 2, 3, 4: Cancelled (Linear onboarding noise)
