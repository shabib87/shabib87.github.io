# Branch, PR, And Rebase Integration

## Branches

- start from `main`
- create a `codex/<type>-<slug>` branch
- keep work isolated to that branch
- do not commit until `make qa-local` passes
- if site-facing files changed, preview with `bundle exec jekyll serve` before commit

## PRs

- run `make qa-local` before creating the PR
- keep the working tree clean before PR creation
- use Conventional Commit style for the PR title
- include summary, why, validation, affected files, affected URLs, and self-review notes

## Integration

- require `make qa-local` on the committed tree and explicit self-review
- if CI has reported, require it to be green
- integrate with rebase only for a linear history
- delete the branch after integration
