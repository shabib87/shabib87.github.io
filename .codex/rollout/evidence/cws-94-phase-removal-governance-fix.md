# CWS-94 PR 1: Phase Removal + Governance Fix + Rename

## Changes

- Added `exempt_branch_patterns` to `active-plan.yaml` (D1)
- Updated `validate-rollout-governance.rb` to skip branch validation for exempt patterns (D1)
- Added 3 exempt pattern tests to `rollout_governance_test.rb` (D1)
- Removed all `phase_branch_pattern` logic from `create-pr.sh` (D2)
- Removed all `phase_branch_pattern` logic from `finalize-merge.sh` (D2)
- Renamed `run-codex-checks.sh` → `run-workflow-checks.sh` (D8)
- Fixed backtick interpolation with `IO.popen` in `run-workflow-checks.sh` (D10)
- Updated Makefile target `codex-check` → `workflow-check` (D8)
- Updated all downstream references (CI, scripts, docs) (D8)
- Bumped `actions/checkout` from `@v4` to `@v6` across all workflows (D11)
- Removed phase branch pattern from `.github/pull_request_template.md`

## Validation

- `make qa-local` passed
- `make workflow-check` passed (5 governance tests, 14 contract tests)
- `finalize_merge_workflow_test.rb` passed (2 tests)
- `repo_ruby_activation_test.rb` passed
- All pre-commit hooks passed (shellcheck, semgrep, markdownlint, actionlint)
