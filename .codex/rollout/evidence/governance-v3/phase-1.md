RED

- command: `bash scripts/run-rollout-governance-tests.sh`
- result: failed (validator missing)
- representative output:
  - `No such file or directory -- .../scripts/validate-rollout-governance.rb`
  - `6 runs, 14 assertions, 6 failures`

GREEN

- command: `bash scripts/run-rollout-governance-tests.sh`
- result: passed
- representative output:
  - `7 runs, 15 assertions, 0 failures, 0 errors, 0 skips`

RED (branch-resolution regression fix)

- command: `GITHUB_HEAD_REF=codex/phase-1-unrelated bash scripts/run-rollout-governance-tests.sh`
- result: failed before fix (validator read CI env branch instead of temp repo branch)
- representative output:
  - `error: missing TDD evidence file .codex/rollout/evidence/governance-v3/phase-1.md`

GREEN (branch-resolution regression fix)

- command: `bash scripts/run-rollout-governance-tests.sh`
- result: passed after prioritizing repo branch over CI env fallback
- representative output:
  - `7 runs, 15 assertions, 0 failures, 0 errors, 0 skips`
