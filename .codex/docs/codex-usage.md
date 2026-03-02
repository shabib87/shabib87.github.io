# Codex Usage

## What Codex Officially Documents

For the Codex app and IDE extension, the official surfaces relevant to this repo are:

- built-in Codex slash commands for Codex controls, such as `/local`, `/cloud`, `/review`, and
  `/status`
- explicit skill invocation with `$skill-name`
- skills appearing in the app or IDE picker through `agents/openai.yaml`
- `@file` references in the IDE extension for repo files and open files

This repo does not treat `.codex/prompts/*` as Codex-native custom commands.

## What This Repo Adds

This repo adds three reusable layers on top of the official Codex surfaces:

- repo-local skills under `.agents/skills/`
- repo workflow prompt files under `.codex/prompts/`
- deterministic `make` targets and shell scripts

Use them together, not as competing systems:

- prompt file or prompt text starts the workflow
- skills drive repo-specific reasoning
- `make` commands do the deterministic work

## VS Code / Cursor Usage

In the Codex IDE extension for VS Code or Cursor, start workflow runs by referencing a repo prompt
file directly:

- `@.codex/prompts/site-workflow.md`
- `@.codex/prompts/editorial-workflow.md`
- `@.codex/prompts/medium-to-blog.md`

These are IDE file references to reusable prompt files in the repo. They are not built-in Codex
slash commands.

Built-in slash commands remain useful for Codex controls only, for example:

- `/local`
- `/cloud`
- `/review`
- `/status`

## Codex App Usage

In the Codex app, use explicit multi-skill prompts as the primary workflow starter.

Site work:

```text
$site-quality-auditor $official-doc-verifier $repo-flow
```

Draft + publish:

```text
$content-brainstormer $technical-post-drafter $fact-checker $jekyll-post-publisher $repo-flow
```

Medium migration:

```text
$medium-porter $fact-checker $jekyll-post-publisher $repo-flow
```

If you want the repo prompt-file behavior in the app, paste the prompt file content into the
thread instead of assuming `@.codex/prompts/...` is supported there.

## Make Commands

Use `make` for deterministic repo actions and validation.

- `make start-work TOPIC="..." TYPE=feat`
- `make validate-draft PATH=_drafts/post.md`
- `make qa-publish PATH=_drafts/post.md`
- `make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD`
- `make site-audit AUDIT=seo TARGET=site`
- `make codex-check`
- `make check`
- `make qa-local`
- `make create-pr TYPE=feat`
- `make finalize-merge PR=123`

## How Start-To-Finish Works

1. Start the workflow:
   use `@.codex/prompts/<workflow>.md` in VS Code or Cursor, or use the equivalent `$skills`
   prompt in the Codex app.
2. Let Codex select and sequence the repo-local skills needed for the task.
3. Let Codex use the repo `make` targets for deterministic validation, publication, and PR
   packaging.
4. Finish only when QA has passed, clean commits exist, the branch is pushed, and the PR is open.

## Copy-Paste Examples

### Site Work

VS Code / Cursor:

```text
@.codex/prompts/site-workflow.md Review the about page and tag archive for SEO, metadata, and maintenance issues, make the fixes, run the relevant audits, run make qa-local, and open the PR.
```

Codex app:

```text
$site-quality-auditor $official-doc-verifier $repo-flow

Review the about page and tag archive for SEO, metadata, and maintenance issues, make the fixes, run the relevant audits, run make qa-local, group clean commits, and open the PR.
```

### Draft + Publish A Blog Post

VS Code / Cursor:

```text
@.codex/prompts/editorial-workflow.md Turn this outline into a private draft in _drafts, fact-check the technical claims, publish it into _posts with the correct date, run QA, and open the PR: ...
```

Codex app:

```text
$content-brainstormer $technical-post-drafter $fact-checker $jekyll-post-publisher $repo-flow

Turn this outline into a private draft in _drafts, fact-check the technical claims, publish it into _posts with the correct date, run QA, group clean commits, and open the PR: ...
```

### Medium Link To Blog Post

VS Code / Cursor:

```text
@.codex/prompts/medium-to-blog.md Migrate this Medium article into a site-native draft, fact-check anything time-sensitive, publish it into _posts, run QA, and open the PR: https://medium.com/example-post
```

Codex app:

```text
$medium-porter $fact-checker $jekyll-post-publisher $repo-flow

Migrate this Medium article into a site-native draft, fact-check anything time-sensitive, publish it into _posts, run QA, group clean commits, and open the PR: https://medium.com/example-post
```

## Scope Rules

- This repo follows trunk-based development with rebase-only integration.
- Do not rely on multi-agent features for this repo.
- Prefer repo-local truth first, then Context7, then first-party docs.
