---
name: content-brainstormer
description: "Use this skill when the user wants to decide what to write next for this site by generating topics, angles, hooks, or backlog priorities. Apply it to net-new ideation, theme clustering, and editorial direction setting that strengthens the site's point of view, not article-body drafting, claim verification, voice rewrites, or post packaging."
---

# Content Brainstormer

Use this skill when the user is choosing what to write next.

## Routing Boundaries

- Use it for topic generation, angle selection, hooks, series clustering, and backlog prioritization.
- Do not use it when the user already has enough material and needs the body written. Route that to `technical-post-drafter`.
- Do not use it when the main task is verifying claims, adding citations, or checking freshness. Route that to `fact-checker`.
- Do not use it for voice rewrites of existing prose. Route that to `sh-humanizer`.
- Do not use it for front matter, validation, or publication steps. Route that to `jekyll-post-publisher`.

## Workflow

1. Read `../../../.codex/docs/editorial-voice-profile.md`.
2. Read `references/positioning.md`.
3. Read `references/topic-selection.md`.
4. Use `references/editorial-calendar.md` when turning ideas into a backlog.
5. Hand the chosen angle and outline to `technical-post-drafter` when the user is ready to write the article body.

## Output Expectations

- topic ideas
- recommended angle
- hook options
- publishable outline directions
- backlog priority suggestions

## Done Criteria

- the user has a shortlist of ideas worth drafting
- the recommended topic supports the site's point of view and core themes
- the outline is strong enough to hand to `technical-post-drafter`

## Rules

- Bias toward insight-led editorial positioning, not generic traffic.
- Start from recurring failure modes, mistaken assumptions, organizational pressure, or repeated system patterns.
- Prefer topics grounded in real engineering judgment and lived experience.
- Suggest hooks, tension, mechanism, and implication, not just titles.
- Let stronger positioning be the outcome, not the framing language.
