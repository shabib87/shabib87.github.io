# Rollout Red-Team Protocol

Use this protocol on every rollout phase PR.

## Roles

- Builder: implements only current phase scope.
- Breaker: attempts boundary violations and policy bypasses.
- Referee: approves only with checklist and evidence alignment.

## Mandatory Attacks

1. Phase-skip attempt:
   open or merge `phase-n` before `phase-(n-1)`.
2. Invalid-branch attempt:
   open a PR from a branch that matches neither `task_branch_pattern` nor
   `phase_branch_pattern`.
3. Oversized non-content diff attempt:
   exceed `max_changed_lines_non_content`.
4. Broad content-manifest attempt:
   use `_posts/*`, `_pages/*`, or `_drafts/*` in a phase manifest.
5. Scope bypass attempt:
   modify any file not declared in `phase-<n>.txt`.

## Required Outcomes

- Sequencing enforcement blocks phase skipping.
- Branch-pattern enforcement blocks invalid PR branches outside task and phase
  patterns.
- Size-cap enforcement blocks oversized non-content diffs.
- Manifest lint blocks broad content wildcards.
- Scope enforcement blocks out-of-manifest file changes.

## Evidence Template

- Attack attempted:
- Expected defense:
- Observed behavior:
- Pass or fail:
- Fix applied:
