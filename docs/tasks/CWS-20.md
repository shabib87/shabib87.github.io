# CWS-20 Task File

## Source

- Linear issue: `CWS-20`
- Linear URL: <https://linear.app/codewithshabib/issue/CWS-20/dev-implement-make-setup-new-mac-bootstrap>
- Captured from Linear at: `2026-03-18 21:47:37 EDT`

## Objective

Implement `make setup` for deterministic local bootstrap on macOS.

## Scope Snapshot

- In scope: install required tools and environment prerequisites; run dependency/bootstrap steps and verification checks.
- Out of scope: CI-only setup logic.

## Deterministic Acceptance Criteria

1. Repository setup path is reachable via `make setup` and includes required bootstrap/install steps for local macOS development.
2. Setup-related commands are discoverable in repository workflow files (`Makefile` and setup scripts) with expected tool/bootstrap references.
3. Local quality gate passes after setup changes are applied.

## Validation Commands

- `rg -n "setup|rbenv|ruby-build|vale|markdownlint|cspell|semgrep|install-hooks" Makefile`
- `make qa-local`

## Evidence Pointers (Optional)

- Gate type: `PR_REQUIRED`
- Cycle: `7ef11bc3-f086-40a6-afd9-256b27df384d`
- Project: `[INFRA] Repo Process & Tooling`

## Single-Writer Rule

- Linear is the mutable execution-status source of truth.
- Do not maintain mutable status in task files; keep status changes in Linear only.
