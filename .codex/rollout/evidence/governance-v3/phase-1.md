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
  - `6 runs, 14 assertions, 0 failures, 0 errors, 0 skips`

GREEN (publish workflow expansion)

- command: `make qa-local`
- result: passed after phase-1 manifest scope was updated for publish workflow paths
- representative output:
  - `codex workflow checks passed`
