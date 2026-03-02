---
name: fact-checker
description: Verify technical and time-sensitive claims for blog content. Use when a post contains library, framework, API, tool, or product claims that should be checked against primary sources or official documentation before publication.
---

# Fact Checker

Use this skill when content accuracy matters.

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
