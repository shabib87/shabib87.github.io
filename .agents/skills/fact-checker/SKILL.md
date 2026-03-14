---
name: fact-checker
description: "Use this skill when the user has a substantive draft or claim list and needs technical or time-sensitive assertions verified against primary sources before publication. Apply it to library, framework, API, tool, product, and version-sensitive claims, not ideation, net-new drafting, voice rewrites, or metadata packaging."
---

# Fact Checker

Use this skill when content accuracy matters.

## Routing Boundaries

- Use it after the substance exists and the question is whether specific claims are true, current, or supportable.
- Do not use it for choosing topics or angles. Route that to `content-brainstormer`.
- Do not use it for writing the main body from scratch or restructuring a weak draft. Route that to `technical-post-drafter`.
- Do not use it for stylistic rewrites or voice polish. Route that to `sh-humanizer`.
- Do not use it for front matter, publish QA, or promotion into `_posts/`. Route that to `jekyll-post-publisher`.

## Workflow

1. Read `references/source-policy.md`.
2. Read `references/citation-format.md`.
3. Use Context7 whenever the official docs are available there and exact behavior matters.
4. If the piece is in a preservation-first workflow, treat fact-checking as advisory unless the
   user explicitly approves text edits.
5. If the piece is still outline-only or structurally weak, send it to `technical-post-drafter`
   before spending time on detailed verification.
6. Return the checked draft to `jekyll-post-publisher` for metadata, QA, and publication.

## Output Expectations

- claims that were checked
- source-backed conclusions
- unsupported or stale claims
- wording changes needed before publish

## Done Criteria

- technical claims are either verified, qualified, or removed
- the draft is ready to pass publish QA with an accurate `fact_check_status`

## Rules

- Prefer primary sources.
- Do not rely on memory for version-sensitive claims when official docs are available.
- Surface unsupported, stale, or ambiguous claims clearly.
- In faithful Medium ports or historical-preservation edits, do not silently rewrite historically
  protected text.
