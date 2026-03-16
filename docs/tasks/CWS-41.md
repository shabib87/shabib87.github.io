# CWS-41 Task File

## Source

- Linear issue: CWS-41
- Canonical tracker: Backlog Remediation Matrix — Master v2
- Generated: 2026-03-16

## Execution Contract

- Pickup Gate: `YES`
- Scope source: issue description contract-v2 in Linear
- Branch evidence: use issue branch naming contract

## Required Before Pickup

- Confirm all `blockedBy` dependencies resolved in Linear
- Confirm labels, assignee, delegate, and milestone are still current
- Confirm local workspace has no conflicting in-flight changes

## Verification Plan

- Run the issue-specific `Validation Commands` from Linear description
- Run `make qa-local` unless the issue is human-only

## Completion Notes

- Record completion summary in Linear issue comment
- Update `docs/agent-context.md` with sync timestamp and recently completed actions
