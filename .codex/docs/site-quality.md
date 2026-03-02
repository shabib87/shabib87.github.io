# Site Quality

## Purpose

This workflow covers source-level website maintenance and QA for the Jekyll site.

Use it for:

- SEO review
- performance review
- site-quality review
- maintainability review

## Entry Points

Skill:

```text
$site-quality-auditor
```

Command:

```bash
make site-audit AUDIT=seo TARGET=site
```

Slash command:

```text
/site-quality
```

## Audit Modes

- `seo`: checks plugins, metadata surfaces, JSON-LD, indexing overrides, and page metadata
- `performance`: checks obvious source-level performance risks such as global scripts and large local assets
- `quality`: checks page metadata, layout and front matter consistency, archive and 404 expectations, and workflow alignment
- `maintenance`: checks remote dependencies, third-party scripts, and workflow drift

## What This Workflow Does Not Do

- It does not pretend a live browser audit happened.
- It does not replace editorial skills.
- It does not replace manual preview when site-facing files changed.

## Required Follow-Up

If a change touches `_config.yml`, `_includes/`, `_layouts/`, `_pages/`, `_posts/`, `assets/`,
or `_sass/`, preview locally with `bundle exec jekyll serve` before commit.
