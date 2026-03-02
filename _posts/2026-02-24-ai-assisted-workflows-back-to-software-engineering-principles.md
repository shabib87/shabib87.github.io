---
title: 'AI-Assisted Workflows: Back to Software Engineering Principles'
description: We spent years wondering if AI would replace the engineer. What we actually
  found is that it only raised the stakes for how we design and structure systems.
date: '2026-02-24'
permalink: "/ai-assisted-workflows-back-to-software-engineering-principles/"
categories:
- blog
- ai
- developer-tools
- architecture
tags:
- ai-assisted-workflows
- ai-guardrails
- developer-tools
- software-architecture
- software-engineering
- codex
- cursor
- claude-code
- markdown
last_modified_at: 2026-03-02 00:00:00 +0000
image: https://images.unsplash.com/photo-1489875347897-49f64b51c1f8?auto=format&fit=crop&w=1600&q=80&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
image_alt: MacBook Pro with images of computer language codes
image_source: unsplash
fact_check_status: complete
---

<figure class="post-figure">
  <img
    src="https://images.unsplash.com/photo-1489875347897-49f64b51c1f8?auto=format&fit=crop&w=1600&q=80&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    alt="MacBook Pro with images of computer language codes"
  >
  <figcaption>Photo by <a href="https://unsplash.com/@casparrubin">Caspar Camille Rubin</a> on <a href="https://unsplash.com/photos/macbook-pro-with-images-of-computer-language-codes-fPkvU7RDmCo">Unsplash</a></figcaption>
</figure>

I recently shared a thought on
[LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7431098266190163968/) about how
Markdown is becoming our primary language.

> If you told me ten years ago that I would be spending a surprising amount of time fine-tuning
> markdown files like [AGENTS.md](https://agents.md/) or
> [.cursor/rules/*.mdc](https://cursor.com/docs/context/rules), I would’ve laughed. I am not sure
> how I feel about it yet. Mostly, I am amused.

The AI-assisted workflow is evolving very quickly. First it was prompt engineering, then managing
context. These are still true, but as “vibe coding” started to become mainstream, people are
finally noticing the flaws in it.

They are realizing the reality of “AI slop” and re-learning that software engineering is not just
about writing code.

Writing the code is the last step. With this realization more people are starting to be systematic
and are going back to first principles.

## The Fragmentation Tax

This shift resulted in a flood of rules and workflows:
[Claude.md](https://code.claude.com/docs/en/overview#customize-with-instructions-skills-and-hooks),
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD),
[Agent OS](https://github.com/buildermethods/agent-os), and
[Spec Kit](https://github.com/github/spec-kit). Each has its own system and style, but the core
idea is always the same.

*Set proper boundaries, break down the problem, and plan small to build incrementally.*

Sounds familiar?

As models become smarter and faster, code becomes cheaper. These guardrails are now a necessity.

We are seeing an innovation battle between AI companies, moving from simple IDEs to agentic ones.

Cursor popularized rules and plan mode. Claude gave us sub-agents. OpenAI introduced Codex rules.

Eventually we arrived at today. We have skills, agents, rules, hooks, and sub-agents. It is
overwhelming and non-standard.

Companies are trying to differentiate themselves so they can sell a product to as many people as
possible. This creates subtle differences in how things work.

Claude and Cursor call them hooks, Codex calls them
[automations](https://developers.openai.com/codex/app/automations/) and rules. We have .cursor
folders, .claude folders, and .codex folders and Codex projects.

Each tool has its own system.

## The Portability Trap

The fragmentation makes it harder for teams to generalize AI guardrails. I do not like being tied
to one system.

I started with VS Code, tried Windsurf and Claude Code, and finally settled on Cursor. But I am
liking Codex a lot these days, and things might change again.

How do I ensure the guardrails are set up correctly regardless of the tooling? There is also the
issue of porting guardrails when a new feature is introduced.

A lot of custom commands and Cursor rules can be moved to a project-specific skill. Some custom
commands can be ported to sub-agents and called from a hook.

It is actually fun and exciting to rediscover software engineering under this new lens.

## Fundamentals Never Changed

Are you seeing the similarities with pre-AI software engineering? Look closely.

The ecosystem looks fragmented on the surface, but the way through it feels very familiar. The
deeper I go, the less it feels like a tooling problem at all. It keeps revealing itself as a
structure problem.

Vendors will keep differentiating. Tools will keep evolving. And teams will still need a stable
layer above them.

I am finding myself pushing guardrails up to the repo level, treating them less like tool settings
and more like contracts.

Using conventions like AGENTS.md and skills as shared entry points, sharding documentation and
indexes so only the right context loads when needed, wiring hooks and scripts so behavior is
enforced regardless of which tool someone opens.

Sometimes that even means symlinking definitions so the same source of truth works across tools.

The tools are different. The interface is different. But the discipline required to build stable,
maintainable systems did not really change.

## The Software Engineering Reality

We spent years wondering if AI would replace the engineer. What we actually found is that it only
raised the stakes for how we design and structure systems.

The “boring” parts of software engineering, the boundaries, the contracts, and the modularity,
turned out to be the parts that actually support scale. Surprising? Or maybe not so much.

I am still amused by how much time I spend in Markdown, but I am also focused on the
responsibility.

People are starting to realize that writing code is only one layer of the job. The higher leverage
is in how the system is structured and orchestrated around it.

The proprietary vendor folders will keep shifting and the tools will keep evolving. But the
mission to build something that actually lasts is still our job. It always was.

That was, is and will be the core of Software Engineering.
