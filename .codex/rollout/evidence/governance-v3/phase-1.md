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
