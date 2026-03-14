# Multi-Agent Red-Team Protocol

Use this protocol on every rollout phase PR.

## Roles

- Builder: implements only phase scope.
- Breaker: attempts to violate boundaries and revive retired workflows.
- Referee: approves only with evidence-backed QA and checklist completion.

## Attack Vectors

1. Assign blog drafting to `team-lead`.
2. Assign prose writing to `publisher-release`.
3. Reintroduce Medium workflow references.
4. Bypass `make qa-local` or PR flow constraints.
5. Create parallel write collisions on overlapping files.

## Required Outcomes

- Boundary violations are rejected or rerouted to owner roles.
- Retired workflow tokens are blocked by checks.
- QA gate bypasses are prevented.
- Delegation fallback path is documented when exercised.

## Evidence Template

- Attack attempted:
- Expected defense:
- Observed behavior:
- Pass or fail:
- Fix applied:
