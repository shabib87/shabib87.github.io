# CWS-10 Task File

## Source

- Linear issue: `CWS-10`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-10/dev-rewrite-agentsmd-with-full-agent-contract-model>
- Captured from Linear at: `2026-03-18 20:40:00 EDT`

## Objective

Rewrite `AGENTS.md` to enforce the master-plan agent contract model and operational boundaries.

## Scope Snapshot

- In scope: agent identity model, explicit `MUST NOT` guardrails, DoR/DoD references, task-file
  convention, queue-resolution policy (Linear-first + drift reporting), and consistency with
  canonical docs.
- Out of scope: implementing new workflow automation, middleware, state-machine orchestration,
  checkpointing, or runtime tool sandboxing.

## Deterministic Acceptance Criteria

1. `AGENTS.md` references required agent roles and boundary model.
2. `MUST NOT` guardrails are explicit and enforceable.
3. DoR/DoD and task-file workflow references are explicit.
4. `AGENTS.md` is internally consistent with `docs/master-plan.md` and `docs/sop.md`.
5. `AGENTS.md` requires next-task resolution from Linear first, then local corroboration
   (`docs/tasks/*`, `docs/agent-context.md`), and drift reporting before execution.

## Validation Commands

- `rg -n "MUST NOT|DoR|DoD|Linear-first|drift|Two-Phase|loop|clarification|boundary|docs/tasks/CWS-" AGENTS.md`
- `make qa-local`

## Evidence Pointers (Optional)

- Project: `[ORCHESTRATION] Agentic Workflow Design`
- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Drift note comment: `2026-03-18` (`CWS-41` and `CWS-45` already completed)

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Do not maintain mutable status in task files; keep status changes in Linear only.
