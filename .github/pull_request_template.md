## Branch And Title Convention

- Branch: `cws/<id>-<slug>` (task) or `cws/phase-<n>-<slug>` (rollout)
- Task-branch PR title must include matching issue token (`CWS-<id>` or `cws-<id>`)
- Include a direct Linear issue link in the PR body
- For non-interactive stack submit (`gt submit --no-interactive`), replace this template body with a concrete summary before PR ready.

## Traceability Checklist

- [ ] Branch name matches approved pattern
- [ ] PR title contains matching issue token (`CWS-<id>` or `cws-<id>`) (task branches)
- [ ] `docs/tasks/CWS-<id>.md` exists and is committed (task branches)
- [ ] `docs/agent-context.md` is fresh (not stale)
- [ ] Linear issue link is present in this PR

## Summary

- Describe what changed in one to three bullets.

## Why

- Describe the user or workflow impact and why this change is needed.

## Linear Traceability

- Parent issue: `<link>`
- This issue: `<link>`

## Validation

- `make qa-local`

## Affected Files

```text

```

## Affected URLs

```text

```

## Self-review Notes

- Risk assessment:
- Backward compatibility notes:
