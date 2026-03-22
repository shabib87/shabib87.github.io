# Agent Contract: Repository Execution Policy

This file is the execution contract for this repository.

- If any repo document conflicts with this file, follow `AGENTS.md` for execution and open a
  follow-up issue to reconcile docs.
- Keep this file concise and durable. Put reusable workflow detail in repo-local skills under
  `.agents/skills/` and canonical policy depth in `docs/master-plan.md` and `docs/sop.md`.

## Queue Resolution Policy (Linear-first)

Before starting implementation, resolve task pickup in this order:

1. Linear first: confirm issue state, dependencies, acceptance criteria, and gate type.
   - Before any repo edits, set the Linear issue state to `In Progress`.
   - Before any repo edits, ensure the issue is linked to the active execution cycle.
   - If either action fails, stop execution and report the blocker.
2. Local second: corroborate with `docs/tasks/CWS-<id>.md` and `docs/agent-context.md`.
3. If Linear and local context diverge, report drift in the Linear issue before execution.

No implementation starts until pickup drift is documented.

Agent-context memory rule:

- Read `docs/agent-context.md` at task start.
- Update `docs/agent-context.md` whenever there is meaningful new context: drift discoveries,
  execution decisions, risk changes, ordering changes, validation findings, or handoff notes.
- Keep updates concise and factual. Do not duplicate mutable issue status from Linear.
- If no meaningful context changed, do not churn the ledger.

## Agent Identity And Boundary Model

Identity and orchestration are defined in the canonical docs. This file enforces operational
boundaries using explicit `MUST NOT` rules.

Role boundaries:

- `team-lead` (orchestrator): plans, delegates, synthesizes.
- `developer` and execution roles: implement scoped changes.
- `researcher` and `fact-checker`: read-only lanes.
- `publisher-release`: packaging and release flow.

Global boundary rules:

- Agents MUST NOT modify files outside assigned scope.
- Agents MUST NOT bypass required local gates (`make qa-local`) before packaging.
- Agents MUST NOT merge or approve PRs.
- Read-only roles MUST NOT modify repository files.
- Execution roles MUST NOT modify published editorial body content unless task scope explicitly
  permits it.
- Agents MUST NOT write implementation before a failing test exists when the task is testable.

## Two-Phase Orchestration Guardrail

Use a Two-Phase model:

1. Plan phase: produce an execution plan with scope, lanes, and validation gates.
2. Execute phase: run only after the plan is approved/confirmed in task context.

Orchestrators MUST NOT collapse planning and execution into one uncontrolled pass for multi-step
work.

## Clarification Protocol

Before execution, perform structured clarification checks:

- Scope clarification: ask if boundary is unclear.
- Approach clarification: ask when more than one valid approach has material tradeoffs.
- Risk clarification: ask before changing high-impact policy, workflow, or release behavior.
- Missing-input clarification: ask when required identifiers or files are absent.

Ask one clarification at a time. Do not ask routine questions already answered by this file,
repo skills, or task context.

## Loop And Stuck-Agent Safety

- If the same action with the same inputs fails 3 times, stop retrying.
- If the same script fails twice consecutively, stop and report failure evidence.
- Report what was attempted, what failed, and the recommended next step.

Agents MUST NOT continue blind retries after the stop threshold.

## DoR And DoD Contract

DoR gate before pickup:

- Linear issue is ready for agent execution and dependencies are resolved.
- Scope and acceptance criteria are deterministic.
- Required context exists, including `docs/tasks/CWS-<id>.md` for task branches.

DoD gate before closeout:

- Acceptance criteria are satisfied.
- Required validation commands pass.
- PR and Linear traceability are complete for `PR_REQUIRED` work.
- Review/self-review and rebase-only integration gates are satisfied.

Reference canonical definitions in `docs/master-plan.md` and `docs/sop.md`.

## Task-File Convention

- Task branches use `cws/<id>-<slug>`.
- `docs/tasks/CWS-<id>.md` is required before PR creation.
- Task files are immutable context snapshots.
- Do not store mutable status fields in task files; Linear is the single mutable status owner.

## Workflow And Validation Gates

Use repository entry points instead of ad hoc command sequences:

- `make qa-local` is the required local release gate.
- `make create-pr TYPE=...` standardizes PR metadata packaging.
- `make finalize-merge PR=...` standardizes rebase-only integration closeout.

Graphite and GitHub CLI policy:

- Use `gt` for stack lifecycle (`create`, `modify`, `restack`, `sync`, `submit`).
- Use `gh` for GitHub object operations (checks, labels, comments, PR metadata updates).
- `make finalize-merge PR=...` merges a single PR via `gh pr merge --rebase --delete-branch`. It
  validates rollout plan gates, CI checks, and self-review. For PRs stacked on non-trunk bases, it
  warns that only the current PR is merged and directs to `gt merge` or Graphite web for full-stack
  merges. It does not manage Graphite metadata or retarget child PRs.
- For Graphite stacks, prefer `gt merge` or Graphite web "Merge stack" to merge the full stack in
  one operation. This keeps Graphite metadata consistent and retargets children correctly.
- If you use `make finalize-merge` on one PR in a stack, do NOT run `gt sync --force` to reconcile
  the remaining children. `gt sync --force` deletes branches it considers stale and closes their
  PRs. Instead, manually rebase child branches onto the new main or retarget their PRs via `gh`.
- Agents MUST NOT use ad hoc `gh pr merge` outside `make finalize-merge`. The script provides
  validation gates that raw `gh` bypasses.

Test-first policy:

- For testable changes, write or update a failing test first, then implement, then refactor.
- If a change is not meaningfully testable, record a concise rationale in task evidence or PR notes.

## Instruction-Based Boundary Caveat

Agent boundary control is instruction-based, not hard sandbox partitioning per role.

- `MUST NOT` boundaries reduce risk but are not a platform-enforced ACL.
- Mitigate with scoped tasks, validation gates, self-audit, and PR review discipline.

## Review Policy

For PR reviews, prioritize high-impact findings:

- correctness regressions
- security risks
- workflow breakage
- missing tests for meaningful behavioral risk

If there are no significant issues, state: `No high-impact findings.`

## Official Docs And Skills Policy

- Use Context7 or first-party docs for version-sensitive behavior.
- Use repo-local skills first when task shape matches a skill.
- Keep `AGENTS.md` small; place repeatable procedures in skills and references.

## Platform Applicability

This contract applies to all agent execution platforms used with this repository, including
OpenAI Codex and Anthropic Claude Code. Platform-specific mechanics are documented in:

- Codex: `.codex/` directory, `docs/sop.md`
- Claude Code: `CLAUDE.md`

The rules in this file override any platform-specific defaults.

## Label Taxonomy

Approved labels (15). Do not create new labels without human approval.

| Label | Purpose |
| ----- | ------- |
| `Spec` | Has written specification |
| `Ready` | Pickup-ready, no blockers |
| `agent-task` | Work to be executed by an AI agent |
| `human-task` | Human executes |
| `Infra` | Infrastructure/tooling domain |
| `Workflow` | Process/workflow domain |
| `epic:dx-setup` | DX setup epic |
| `epic:editorial-qa` | Editorial quality epic |
| `epic:ci-pipeline` | CI pipeline epic |
| `epic:safety` | Safety and security epic |
| `epic:skills` | Skill authoring epic |
| `epic:reasoning` | Reasoning skills epic |
| `epic:slack` | Slack integration epic |
| `epic:dispatch` | Dispatch workflow epic |
| `epic:agents-config` | Agent config epic |

## Bash Security Baseline

Shell scripts must:

- use `set -euo pipefail`
- avoid `eval`
- avoid `curl | bash` patterns
- validate inputs early and fail closed on missing required state
