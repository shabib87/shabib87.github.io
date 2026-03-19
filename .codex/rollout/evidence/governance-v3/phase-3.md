RED

- command: `bash scripts/run-rollout-governance-tests.sh`
- result: failed before adding dynamic-`N` edge tests (`N=1` and `N=50`)

GREEN

- command: `bash scripts/run-rollout-governance-tests.sh`
- result: passed after adding dynamic-`N` edge tests
- command: `bash scripts/run-rollout-governance-tests.sh`
- result: passed after adding Graphite branch-tracking hardening checks for `start-work.sh`,
  `start-phase.sh`, and untracked-branch recovery in `create-pr.sh`
