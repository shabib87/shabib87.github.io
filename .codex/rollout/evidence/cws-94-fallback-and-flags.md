# CWS-94 PR 2: Fallback, Non-Interactive, Stack Merge, Dynamic Body

## Changes

- Created `scripts/lib/github-api.sh` with 8 shared gh/curl fallback functions (D3)
- Integrated fallback library into `create-pr.sh`, replacing direct `gh` calls (D3)
- Replaced hardcoded PR body with template-driven generation matching all 9 sections from `.github/pull_request_template.md` (D6)
- Integrated fallback library into `finalize-merge.sh`, replacing direct `gh` calls (D3)
- Added `--yes`/`--no-interactive` flag to `finalize-merge.sh` with `YES` env var support (D4)
- Added `--stack` flag to `finalize-merge.sh` with `STACK` env var support (D5)
- Stack merge uses `gt merge` preferred path with single PR merge fallback (D5)
- Updated Makefile `finalize-merge` target with `YES` and `STACK` variable passthrough (D4, D5)
- Updated `create_pr_workflow_test.rb` to assert fallback function names (D3)

## Validation

- `make qa-local` passed
- `make workflow-check` passed (5 governance tests, 14 contract tests, 2 finalize tests)
- All pre-commit hooks passed (shellcheck, semgrep, markdownlint, actionlint)
