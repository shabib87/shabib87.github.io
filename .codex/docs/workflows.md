# Workflows

## Site Work

### Site Starter (VS Code / Cursor)

```text
@.codex/prompts/orchestrator-site-workflow.md Review the about page and tag archive for SEO, metadata, and maintenance issues, make the fixes, run the relevant audits, run make qa-local, and open the PR.
```

### Site Starter (Codex App)

```text
$site-quality-auditor $official-doc-verifier $repo-flow
```

## Draft + Publish A Blog Post

### Editorial Starter (VS Code / Cursor)

```text
@.codex/prompts/orchestrator-editorial-workflow.md Turn this outline into a private draft in _drafts, fact-check the technical claims, publish it into _posts with the correct date, run QA, and open the PR: ...
```

### Editorial Starter (Codex App)

```text
$content-brainstormer $technical-post-drafter $fact-checker $jekyll-post-publisher $repo-flow
```

## Preserve An Existing Published Post

### Preservation Starter (VS Code / Cursor)

```text
@.codex/prompts/orchestrator-preserve-existing-post.md Add a relevant inline image, fix SEO metadata, keep title/description/date/prose unchanged, run QA, and open the PR: _posts/2025-10-01-example.md
```

### Preservation Starter (Codex App)

```text
$historical-post-editor $site-quality-auditor $repo-flow
```

## Notes

- Legacy non-orchestrator prompts remain temporarily for compatibility.
- Legacy import workflow is retired in this repository.
- Normal task branches use Linear-first naming (`cws/<id>-...`).
- Rollout governance remains phase-based and sequential for rollout branches (`cws/phase-<n>-...`).
- Use `make start-phase PLAN=<plan-id> PHASE=<n> TOPIC="..." TYPE=...` for governed work.
- Validate ruleset/check alignment with `make rollout-audit`.
