# Repo Workflow

Use this repository's standard repo flow.

- Follow `$repo-flow`.
- Start repo-changing work from `main` on a fresh `codex/*` branch using `make start-work`.
- Do not commit until `make qa-local` passes.
- Group related changes into clean Conventional Commits after the full local QA gate is green.
- Re-run `make qa-local` on the committed tree before push and PR creation.
- Use `make create-pr` and `make finalize-merge` instead of ad hoc PR and integration commands.
