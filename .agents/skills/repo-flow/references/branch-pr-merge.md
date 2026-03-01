# Branch, PR, And Merge

## Branches

- start from `main`
- create a `codex/<type>-<slug>` branch
- keep work isolated to that branch

## PRs

- run local checks before creating the PR
- use Conventional Commit style for the PR title
- include summary, why, validation, affected files, affected URLs, and self-review notes

## Merge

- require local checks and explicit self-review
- if CI has reported, require it to be green
- prefer rebase-style merge behavior for a linear history
- delete the branch after merge
