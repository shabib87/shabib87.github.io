# AI Workflow

## Purpose

This repository stores its AI workflow in version control. The root `AGENTS.md`, the
repo-local skills under `.agents/skills/`, and the helper commands in `Makefile` and `scripts/`
are the canonical source of truth for how Codex should work in this repo.

## Draft Privacy

- `_drafts/` is gitignored and local-only.
- Private drafts are not committed or included in PRs.
- Publishing happens when a draft is promoted into `_posts/`.
- This improves privacy but means drafts are not backed up by git.

## Prerequisites

- Required on the machine: Ruby `3.4.4`, Git, and Homebrew
- `make setup` bootstraps Bundler, installs repo-managed `pre-commit` into `.venv-tools/`,
  installs git hooks, and installs gems into `vendor/bundle`
- GitHub CLI is only required for PR creation and merge commands
- Valid GitHub CLI authentication is required for PR and merge commands:

```bash
gh auth login -h github.com
```

SSH is sufficient for `git push`, but it is not sufficient for `gh pr create` or
`gh pr merge`.

## Standard Flow

1. Start work from `main`:

   ```bash
   make start-work TOPIC="describe the work" TYPE=feat
   ```

2. Create or refine a private draft in `_drafts/`.
3. Validate the draft:

   ```bash
   make validate-draft PATH=_drafts/your-post.md
   ```

4. Run publish QA:

   ```bash
   make qa-publish PATH=_drafts/your-post.md
   ```

5. Publish the draft:

   ```bash
   make publish-draft PATH=_drafts/your-post.md DATE=YYYY-MM-DD
   ```

6. Run tracked repo validation:

   ```bash
   make check
   ```

7. Create the PR:

   ```bash
   make create-pr TYPE=feat
   ```

8. Finalize the solo self-review merge:

   ```bash
   make finalize-merge PR=123
   ```

## Repo-Local Skills

- `jekyll-post-publisher`: Post drafting, validation, publish QA
- `content-brainstormer`: Topic ideation and editorial backlog development
- `fact-checker`: Primary-source verification for technical claims
- `medium-porter`: Medium-to-Jekyll migration and normalization
- `repo-flow`: Branch, PR, and merge mechanics
- `official-doc-verifier`: Context7 and primary-doc confirmation for version-sensitive details

## Verification Expectations

- Use Context7 when implementation or guidance depends on official documentation for Codex,
  GitHub CLI, GitHub Actions, Jekyll, Minimal Mistakes, `pre-commit`, Semgrep, or another
  version-sensitive tool.
- Use repo-local files for repo-specific truth before consulting outside docs.
- Keep workflow scripts deterministic and lightweight. Put policies in docs or skill references,
  not in opaque shell behavior.
