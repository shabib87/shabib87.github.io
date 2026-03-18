# Repo Workflow

Use this repository's standard repo flow.

- Follow `$repo-flow`.
- Start repo-changing work from `main` on a fresh `codex/*` branch using `make start-work`.
- Do not commit until `make qa-local` passes.
- Group related changes into clean Conventional Commits after the full local QA gate is green.
- Re-run `make qa-local` on the committed tree before push and PR creation.
- Use `make create-pr` for PR creation/submission.
- Use `make finalize-merge` for single-PR integration and Graphite stack merge (`gt merge` or Graphite web) for stacked PR integration.
