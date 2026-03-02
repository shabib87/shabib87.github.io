---
name: site-quality-auditor
description: Audit this Jekyll site for source-level SEO, performance, quality, and maintainability issues. Use when reviewing website changes, validating page metadata, checking archive and about pages, inspecting structured data and head tags, or hardening the repo's site QA workflow before commit or PR.
---

# Site Quality Auditor

Use this skill for repo-specific website maintenance and QA.

## Workflow

1. Read `references/quality.md`.
2. Read the mode-specific reference for the requested audit:
   `references/seo.md`, `references/performance.md`, or `references/maintenance.md`.
3. Start from repo-local truth:
   `_config.yml`, `_includes/head/custom.html`, `_includes/json-ld.html`, `_pages/`, and the affected file paths.
4. Use `make site-audit AUDIT=<mode> TARGET=<target>` when deterministic repo-local checks will reduce guesswork.
5. Use `official-doc-verifier` when current Codex, Jekyll, Minimal Mistakes, or other official behavior matters.
6. If the audit leads to repo changes, follow `repo-flow` and require `make qa-local` before commit.

## Modes

- `seo`
- `performance`
- `quality`
- `maintenance`

## Output Expectations

- findings grouped by severity
- affected files or templates
- recommended next step
- explicit follow-up checks when manual preview is still required

## Done Criteria

- the audit is grounded in the actual repo files
- the result separates source-level facts from manual follow-up
- the next action is clear: fix, preview, verify docs, or continue through repo QA

## Rules

- Stay source-first. Do not pretend a live-site or browser audit happened if it did not.
- Treat `_config.yml`, `_includes/head/custom.html`, and `_includes/json-ld.html` as primary SEO and metadata surfaces.
- Prefer repo-specific findings over generic web advice.
- Do not replace editorial skills. Hand drafting, fact-checking, and publication work back to the editorial pipeline.
