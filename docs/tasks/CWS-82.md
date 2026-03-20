# CWS-82 Task File

## Source

- Linear issue: `CWS-82`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-82/dual-platform-pivot-codex-claude-code>
- Captured from Linear at: `2026-03-20 00:29:33 EDT`

## Objective

Add Claude Code as a peer execution platform alongside Codex for redundancy and evaluation.
Full parity — either tool can handle any workflow.

## Scope Snapshot

- In scope: create `CLAUDE.md`, update `AGENTS.md`, `docs/sop.md`, `docs/master-plan.md`,
  `docs/agent-context.md` for dual-platform support.
- In scope: remove `delegate: Codex` from all Linear backlog issues.
- In scope: establish `.agents/roles/` as the shared agent role location (path decision only).
- Out of scope: creating actual role files (CWS-23).
- Out of scope: Codex config changes.

## Deterministic Acceptance Criteria

1. `CLAUDE.md` exists at repo root, under 2000 tokens, references valid paths.
2. `AGENTS.md` has platform applicability section and no inappropriate Codex-specific assumptions.
3. `docs/master-plan.md` references Claude Code in >= 5 locations.
4. `docs/sop.md` title no longer says "Codex" exclusively.
5. All file paths mentioned in `CLAUDE.md` exist or are clearly marked as future work.
6. Linear issues have no delegate field.
7. `make qa-local` passes.
8. No broken cross-references between docs.

## Validation Commands

- `rg -c "Claude Code" docs/master-plan.md` — expect >= 5
- `head -1 docs/sop.md` — expect no exclusive "Codex" reference
- `test -f CLAUDE.md` — expect exists
- `rg "Platform Applicability" AGENTS.md` — expect match

## Evidence Pointers

- Project: `[ORCHESTRATION] Agentic Workflow Design`
- Milestone: `M1 Contract Canonicalization`

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Do not maintain mutable status in task files; keep status changes in Linear only.
