# CWS-22 Task File

## Source

- Linear issue: `CWS-22`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-22/dev-implement-make-ci-setup-github-actions-runner-bootstrap>
- Captured from Linear at: `2026-03-18 23:14:35 EDT`

## Objective

Implement `make ci-setup` for deterministic GitHub Actions bootstrap.

## Scope Snapshot

- In scope: add CI setup target for Ubuntu runners; integrate target into current CI workflows.
- Out of scope: macOS bootstrap logic.

## Deterministic Acceptance Criteria

1. `make ci-setup` exists and provides non-interactive CI bootstrap behavior for Ubuntu workflows.
2. CI workflow definitions reference `make ci-setup` where runner bootstrap is required.
3. Local validation gate passes after CI-setup changes are applied.

## Validation Commands

- `rg -n "ci-setup|ubuntu|vale|markdownlint|cspell|semgrep" Makefile .github/workflows/*.yml`
- `make qa-local`

## Evidence Pointers (Optional)

- Gate type: `PR_REQUIRED`
- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Project: `[INFRA] Repo Process & Tooling`

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Do not maintain mutable status in task files; keep status changes in Linear only.
