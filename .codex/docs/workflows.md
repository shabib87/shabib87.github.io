# Workflows

## Site Work

### Site Starter In VS Code / Cursor

```text
@.codex/prompts/site-workflow.md Review the about page and tag archive for SEO, metadata, and maintenance issues, make the fixes, run the relevant audits, run make qa-local, and open the PR.
```

### Site Starter In The Codex App

```text
$site-quality-auditor $official-doc-verifier $repo-flow

Review the about page and tag archive for SEO, metadata, and maintenance issues, make the fixes, run the relevant audits, run make qa-local, group clean commits, and open the PR.
```

### Site Phases

1. Start the branch with `make start-work TOPIC="..." TYPE=...`.
2. Inspect the affected site files.
3. Run the relevant audits with `make site-audit`.
4. Make the site changes.
5. Preview locally with `bundle exec jekyll serve` if site-facing files changed.
6. Run `make qa-local`.
7. Group clean commits, re-run `make qa-local`, and run `make create-pr TYPE=...`.

### Site Commands

- `make start-work TOPIC="..." TYPE=...`
- `make site-audit AUDIT=seo TARGET=...`
- `make site-audit AUDIT=quality TARGET=...`
- `make site-audit AUDIT=maintenance TARGET=...`
- `make site-audit AUDIT=performance TARGET=...`
- `make qa-local`
- `make create-pr TYPE=...`

### Site Finish

The workflow finishes when the PR is open and ready for self-review.

## Draft + Publish A Blog Post

### Draft Starter In VS Code / Cursor

```text
@.codex/prompts/editorial-workflow.md Turn this outline into a private draft in _drafts, fact-check the technical claims, publish it into _posts with the correct date, run QA, and open the PR: ...
```

### Draft Starter In The Codex App

```text
$content-brainstormer $technical-post-drafter $fact-checker $jekyll-post-publisher $repo-flow

Turn this outline into a private draft in _drafts, fact-check the technical claims, publish it into _posts with the correct date, run QA, group clean commits, and open the PR: ...
```

### Draft Phases

1. Start the branch with `make start-work TOPIC="..." TYPE=feat`.
2. Brainstorm the angle if needed, then draft the article body.
3. Fact-check technical and time-sensitive claims.
4. Create or refine the private draft under `_drafts/`.
5. Run draft validation and publish QA.
6. Promote the draft into `_posts/`.
7. Run `make qa-local`, group clean commits, and open the PR.

### Draft Commands

- `make start-work TOPIC="..." TYPE=feat`
- `make validate-draft PATH=_drafts/<draft>.md`
- `make qa-publish PATH=_drafts/<draft>.md`
- `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
- `make qa-local`
- `make create-pr TYPE=feat`

### Draft Finish

The workflow finishes when the post exists in `_posts/` and the PR is open.

## Port A Medium Post

### Medium Starter In VS Code / Cursor

```text
@.codex/prompts/medium-to-blog.md Migrate this Medium article into a site-native draft, fact-check anything time-sensitive, publish it into _posts, run QA, and open the PR: https://medium.com/example-post
```

### Medium Starter In The Codex App

```text
$medium-porter $fact-checker $jekyll-post-publisher $repo-flow

Migrate this Medium article into a site-native draft, fact-check anything time-sensitive, publish it into _posts, run QA, group clean commits, and open the PR: https://medium.com/example-post
```

### Medium Phases

1. Start the branch with `make start-work TOPIC="..." TYPE=feat`.
2. Convert the Medium article into a private draft under `_drafts/`.
3. Normalize metadata, taxonomy, and structure for this site.
4. Fact-check anything time-sensitive or technical.
5. Run draft validation and publish QA.
6. Promote the draft into `_posts/`.
7. Run `make qa-local`, group clean commits, and open the PR.

### Medium Commands

- `make start-work TOPIC="..." TYPE=feat`
- `make validate-draft PATH=_drafts/<draft>.md`
- `make qa-publish PATH=_drafts/<draft>.md`
- `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
- `make qa-local`
- `make create-pr TYPE=feat`

### Medium Finish

The workflow finishes when the migrated post exists in `_posts/` and the PR is open.
