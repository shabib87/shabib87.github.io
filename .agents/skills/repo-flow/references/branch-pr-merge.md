# Branch, PR, And Rebase Integration

## Branches

- start from `main`
- create a `cws/<type>-<slug>` branch
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

## Stack Merge Policy

- `make finalize-merge PR=...` merges a single PR via `gh pr merge --rebase --delete-branch`. It
  validates against the active rollout plan (`active-plan.yaml`): branch pattern matching, required
  CI checks, phase ordering (for phase branches only), and rebase-merge availability. For PRs whose
  base is a non-trunk stack branch, it warns that only the current PR is merged and directs to
  `gt merge` or Graphite web for full-stack merges. It does not call any Graphite commands, manage
  Graphite metadata, or retarget child PRs after deleting the merged branch.
- for Graphite stacks, prefer `gt merge` or Graphite web "Merge stack" to merge the full stack in
  one operation — this keeps Graphite metadata consistent and retargets children correctly
- if using `make finalize-merge` on individual PRs in a stack, do NOT run `gt sync --force` to
  reconcile the remaining children — `gt sync --force` deletes branches it considers stale and
  closes their PRs
- if a base PR was already merged and its branch deleted, manually rebase or retarget child PRs
  via `gh pr edit --base main`; do not rely on `gt sync` to recover
- if a stack is broken beyond recovery, abandon it: cherry-pick surviving commits onto a fresh
  branch from main and submit one clean PR
