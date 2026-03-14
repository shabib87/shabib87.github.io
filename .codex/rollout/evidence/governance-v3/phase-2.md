RED

- command: `rg -n "rollout/phases|validate-phase-scope\\.sh" .codex scripts`
- result: stale legacy rollout paths/scripts still present

GREEN

- command: `make codex-check`
- result: passed after stale-surface cleanup and docs alignment
