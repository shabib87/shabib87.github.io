---
name: technical-post-drafter
description: "Use this skill when the user needs to write or substantially reshape the body of a technical post for this site from a topic, outline, notes, transcript, or rough draft. Apply it to net-new drafting and major restructures before fact checking and publish QA, not ideation, pure voice polish, source verification, or metadata packaging."
---

# Technical Post Drafter

Use this skill when the article body needs to be written or substantially reworked.

## Routing Boundaries

- Use it when the body is missing, thin, out of order, or structurally weak.
- Do not use it for choosing topics or backlog direction. Route that to `content-brainstormer`.
- Do not use it for pure voice polish on otherwise solid prose. Route that to `sh-humanizer`.
- Do not use it when the main job is verifying claims or citing sources. Route that to `fact-checker`.
- Do not use it for metadata, validation, or publish workflow. Route that to `jekyll-post-publisher`.

## When To Use

- turning a brainstormed topic into a full draft
- expanding an outline into sections
- restructuring a rough draft that feels thin, repetitive, or out of order
- sharpening hooks, transitions, explanations, and examples
- preparing a migrated or legacy post for fact checking and repo publication

## Required Inputs

- topic, title, or working thesis
- intended audience
- outline, notes, transcript, or rough draft
- any non-negotiable claims, examples, or stories
- target publish outcome if known

## Workflow

1. Read `../../../.codex/docs/editorial-voice-profile.md`.
2. Read `references/article-structure.md` for section sequencing and pacing.
3. Read `references/drafting-rules.md` for voice, example, and claim-marking rules.
4. If the input is only an idea or hook, hand off to `content-brainstormer` first.
5. Draft or restructure the article body before metadata polishing.
6. Send technical claims to `fact-checker` before calling the draft publish-ready.
7. Hand the checked draft to `jekyll-post-publisher` for front matter, validation, and publication.

## Output Expectations

- a full draft or a materially stronger draft
- a sharper hook and clearer throughline
- section-level recommendations when gaps remain
- explicit next step: `fact-checker` or `jekyll-post-publisher`

## Done Criteria

- the reader can follow the argument without missing context
- each section has a clear job and non-empty payoff
- examples are concrete enough to carry the technical point
- the draft is ready for fact checking or metadata and publish workflow

## Rules

- Preserve the author's judgment and voice; do not flatten it into generic tutorial prose.
- Default to `problem -> mechanism -> consequence` before drifting into advice or process.
- Prefer concrete systems examples over abstract claims.
- Mark uncertain or source-dependent claims so `fact-checker` can verify them.
- Avoid publish metadata work unless the user asks for file creation or packaging.
- Keep headings crisp and make the post feel intentional, not padded.
