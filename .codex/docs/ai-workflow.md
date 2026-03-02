# AI Workflow

## Purpose

This repository stores its AI workflow in version control. The root `AGENTS.md`, the
repo-local skills under `.agents/skills/`, the repo workflow prompt files under
`.codex/prompts/`, and the helper commands in `Makefile` and `scripts/` are the canonical source
of truth for how Codex should work in this repo.

## Draft Privacy

- `_drafts/` is gitignored and local-only.
- Private drafts are not committed or included in PRs.
- Publishing happens when a draft is promoted into `_posts/`.
- This improves privacy but means drafts are not backed up by git.

## Prerequisites

- Required on the machine: Ruby `3.4.4`, Git, and Homebrew
- `make setup` bootstraps Bundler, installs repo-managed `pre-commit` into `.venv-tools/`,
  installs git hooks, and installs gems into `vendor/bundle`
- GitHub CLI is only required for PR creation and rebase-only integration commands
- Valid GitHub CLI authentication is required for PR and integration commands:

```bash
gh auth login -h github.com
```

SSH is sufficient for `git push`, but it is not sufficient for `gh pr create` or
`gh pr merge --rebase`.

## Workflow Starters

- Use repo-local skills for reusable repo-specific workflows.
- In VS Code or Cursor, use repo workflow prompt files from `.codex/prompts/` via
  `@.codex/prompts/<workflow>.md`.
- In the Codex app, use explicit `$skills` prompts for the same workflows.
- Use `make` targets for deterministic repo mechanics and validation.
- This repo follows trunk-based development and integrates changes with rebase only.

## Standard Flow

1. Start work from `main`:

   ```bash
   make start-work TOPIC="describe the work" TYPE=feat
   ```

2. Use a repo-local skill, a repo workflow prompt file, or an explicit multi-skill prompt to
   start the right workflow.
3. Create or refine a private draft in `_drafts/` when the work is editorial.
4. Validate the draft:

   ```bash
   make validate-draft PATH=_drafts/your-post.md
   ```

5. Run publish QA:

   ```bash
   make qa-publish PATH=_drafts/your-post.md
   ```

6. Publish the draft:

   ```bash
   make publish-draft PATH=_drafts/your-post.md DATE=YYYY-MM-DD
   ```

7. Run site audits as needed:

   ```bash
   make site-audit AUDIT=seo TARGET=site
   make site-audit AUDIT=quality TARGET=site
   ```

8. Run the full local QA gate:

   ```bash
   make qa-local
   ```

9. Create the PR:

   ```bash
   make create-pr TYPE=feat
   ```

10. Finalize the solo self-review integration:

   ```bash
   make finalize-merge PR=123
   ```

## Release Rules

- Do not commit until `make qa-local` passes.
- Re-run `make qa-local` on the committed tree before push or rebase integration.
- If a change touches `_config.yml`, `_includes/`, `_layouts/`, `_pages/`, `_posts/`, `assets/`,
  or `_sass/`, preview locally with `bundle exec jekyll serve` before commit.

## Repo-Local Skills

- `jekyll-post-publisher`: Post drafting, validation, publish QA
- `content-brainstormer`: Topic ideation and editorial backlog development
- `fact-checker`: Primary-source verification for technical claims
- `medium-porter`: Medium-to-Jekyll migration and normalization
- `repo-flow`: Branch, PR, and rebase-only integration mechanics
- `official-doc-verifier`: Context7 and primary-doc confirmation for version-sensitive details
- `site-quality-auditor`: Site SEO, quality, performance, and maintenance reviews

## Verification Expectations

- Use Context7 when implementation or guidance depends on official documentation for Codex,
  GitHub CLI, GitHub Actions, Jekyll, Minimal Mistakes, `pre-commit`, Semgrep, or another
  version-sensitive tool.
- Use repo-local files for repo-specific truth before consulting outside docs.
- Keep workflow scripts deterministic and lightweight. Put policies in docs or skill references,
  not in opaque shell behavior.
- Use the release gate explicitly:

   ```bash
   make qa-local
   make check
   ```
