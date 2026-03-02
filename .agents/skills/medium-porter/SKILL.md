---
name: medium-porter
description: Migrate Medium posts into this Jekyll site with polish. Use when porting legacy articles, normalizing metadata, improving structure, or converting a Medium-style post into a site-native article while preserving voice.
---

# Medium Porter

Use this skill when importing or cleaning up Medium-origin content.

## Workflow

1. Read `references/migration-checklist.md`.
2. Read `references/canonical-seo.md`.
3. Default to `faithful-port` mode unless the user explicitly asks for a rewrite or site-native
   adaptation.
4. Reuse the site's standard front matter and taxonomy conventions.
5. If the user explicitly wants a site-native rewrite, hand the draft to `technical-post-drafter`
   before final fact checking and publication.

## Output Expectations

- a site-native draft or post
- normalized metadata
- preserved historical text and dates by default
- any follow-up fact-check or SEO notes

## Done Criteria

- the migrated article preserves protected fields when in `faithful-port` mode
- metadata and media handling are consistent with the rest of the site

## Rules

- Preserve the original publish date, title, description, prose body, and media order by default.
- Exact source media is preferred, but a different relevant image is allowed when the original is
  blocked or unavailable.
- Render article media inline with the standard `figure.post-figure` and `figcaption` pattern.
- Re-check time-sensitive technical claims, but treat the results as advisory unless the user
  explicitly approves content edits.
- Avoid large rewrites unless the user explicitly asks for one.
