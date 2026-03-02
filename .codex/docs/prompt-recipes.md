# Prompt Recipes

## Site Work In VS Code / Cursor

```text
@.codex/prompts/site-workflow.md Review the about page and tag archive for SEO, metadata, and maintenance issues, make the fixes, run the relevant audits, run make qa-local, and open the PR.
```

## Site Work In The Codex App

```text
$site-quality-auditor $official-doc-verifier $repo-flow

Review the about page and tag archive for SEO, metadata, and maintenance issues, make the fixes, run the relevant audits, run make qa-local, group clean commits, and open the PR.
```

## Draft + Publish In VS Code / Cursor

```text
@.codex/prompts/editorial-workflow.md Turn this outline into a private draft in _drafts, fact-check the technical claims, publish it into _posts with the correct date, run QA, and open the PR: ...
```

## Draft + Publish In The Codex App

```text
$content-brainstormer $technical-post-drafter $fact-checker $jekyll-post-publisher $repo-flow

Turn this outline into a private draft in _drafts, fact-check the technical claims, publish it into _posts with the correct date, run QA, group clean commits, and open the PR: ...
```

## Medium To Blog In VS Code / Cursor

```text
@.codex/prompts/medium-to-blog.md Migrate this Medium article into a site-native draft, fact-check anything time-sensitive, publish it into _posts, run QA, and open the PR: https://medium.com/example-post
```

## Medium To Blog In The Codex App

```text
$medium-porter $fact-checker $jekyll-post-publisher $repo-flow

Migrate this Medium article into a site-native draft, fact-check anything time-sensitive, publish it into _posts, run QA, group clean commits, and open the PR: https://medium.com/example-post
```

## Focused Skills

`Use $content-brainstormer to propose three authority-first post ideas about debugging brittle mobile systems.`

`Use $fact-checker to verify these claims and tell me what needs stronger sourcing.`

`Use $official-doc-verifier to confirm the official docs for this tool before we encode the workflow behavior.`
