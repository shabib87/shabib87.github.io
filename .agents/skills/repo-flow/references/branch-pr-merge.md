# Branch, PR, And Rebase Integration

## Branches

- start from `main`
- create a `codex/<type>-<slug>` branch
- if the branch is created via `git checkout -b` (not `gt create`), run `gt track --parent main`
  before any `gt create`/`gt submit` command
- on a pre-created task branch, use `gt modify --commit` to create commits; do not run `gt create`
  from that branch because it creates a new branch and can violate branch-pattern gates.
- keep work isolated to that branch
- do not commit until `make qa-local` passes
- if site-facing files changed, preview with `bundle exec jekyll serve` before commit

## PRs

- run `make qa-local` before creating the PR
- keep the working tree clean before PR creation
- use Conventional Commit style for the PR title
- prefer `gt submit --stack --no-interactive --publish` for non-interactive Graphite submission
- include summary, why, validation, affected files, affected URLs, and self-review notes
- for task branches, require `docs/tasks/CWS-<id>.md` as local execution context; do not maintain mutable status text in the task file

## Integration

- require `make qa-local` on the committed tree and explicit self-review
- if CI has reported, require it to be green
- integrate with rebase only for a linear history
- delete the branch after integration
- keep Linear issue and PR traceability links current; keep mutable status transitions in Linear only
- if git/Graphite operations fail with `.git/index.lock` or sandbox write denial, escalate command
  approval explicitly and retry; command prefix rules improve consistency but do not replace
  filesystem permissions.
