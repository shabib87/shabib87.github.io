---
title: "Using Notion as Shared Memory Across Claude Surfaces"
description: "Because Claude's own memory doesn't sync across them yet"
date: '2026-03-31'
permalink: "/using-notion-as-shared-memory-across-claude-surfaces/"
categories:
- blog
- ai
- developer-tools
- architecture
tags:
- claude-code
- notion
- mcp
- agentic-systems
- cross-surface-memory
- developer-workflows
last_modified_at: 2026-03-31 00:00:00 +0000
image: https://images.unsplash.com/photo-1674027444485-cec3da58eef4?auto=format&fit=crop&w=1600&q=80&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
image_alt: Abstract sphere of interconnected dots and lines evoking neural connections and shared memory
image_source: unsplash
fact_check_status: not-needed
excerpt: "Because Claude's own memory doesn't sync across them yet."
---

<figure class="post-figure">
  <img
    src="https://images.unsplash.com/photo-1674027444485-cec3da58eef4?auto=format&fit=crop&w=1600&q=80&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    alt="Abstract sphere of interconnected dots and lines evoking neural connections and shared memory"
  >
  <figcaption>Photo by <a href="https://unsplash.com/@growtika">Growtika</a> on <a href="https://unsplash.com/photos/an-abstract-image-of-a-sphere-with-dots-and-lines-nGoCBxiaRO0">Unsplash</a></figcaption>
</figure>

Over the last couple of weeks I've been trying to get Claude to work the way I actually work, which is mostly Claude Code on my laptop and then picking things up from my phone when I'm away from my desk. I have the same Anthropic account, I'm using the same project, I just want continuity between surfaces.

## The memory gap

Turns out that's not how it works right now. Claude Code stores memory locally, keyed to the filesystem path of your project. The mobile app and [claude.ai](http://claude.ai) have their own cloud-synced memory that's completely separate. They're on the same Anthropic account but they don't share state. [claude.ai](http://claude.ai/) and mobile do sync memory with each other now, but Claude Code remains completely isolated from both.

There's a [GitHub issue](https://github.com/anthropics/claude-code/issues/25739) with a growing thread of people describing exactly this problem and the workarounds are all over the place, Drive/Dropbox syncs, private Git repos to carry context, community tools that sort of work until your paths diverge between machines.

I stopped using Codex and ChatGPT and Perplexity a couple of weeks ago. That started with [a multi-agent workflow that surprised me by actually working end to end](https://www.linkedin.com/posts/ahmadshabibulhossain_over-the-last-week-ive-been-messing-with-activity-7439711431534526465-DbsQ), then [a broken connector that led me to try Claude for the same task](https://www.linkedin.com/posts/ahmadshabibulhossain_cursor-had-been-my-tool-of-choice-for-most-activity-7440812522930110464-nzph) — and it just worked. Claude is the whole AI stack for me now, I'm on the Max plan, and this is not a casual experiment where I can just hop to another platform when something is annoying. So I needed to actually solve this.

## Notion as the shared layer

With a lot of trial and error what I ended up doing is using Notion as the shared memory layer. I have a workspace set up with multiple layers, an ideas lab for things in various stages of exploration, a context section with reference docs that any surface can pull from, and a governance layer for process rules.

Linear sits alongside it for execution tracking and backlog, but Notion is the one carrying the cross-surface context that Claude itself doesn't share natively.

<figure class="post-figure">
  <img
    src="/assets/images/2026-03-31-using-notion-as-shared-memory-across-claude-surfaces/notion-shared-memory-diagram-v3.png"
    alt="Diagram showing Claude Code and claude.ai/Mobile as isolated memory surfaces, with Notion as the shared context bridge via MCP, and Linear for execution tracking."
    style="height: auto; object-fit: contain;"
  >
</figure>

## Making it efficient

The part that took the most trial and error was making it efficient. Notion's search index goes stale after edits, so I started caching page IDs directly in Claude's memory so it can fetch by ID instead of searching. That one change cut out a surprising amount of wasted time and tokens. I also had to be deliberate about what lives in Notion versus what stays in Claude's local memory, because pulling everything through MCP every session is expensive. Every page you load is tokens spent before the actual work even starts.

I can start a planning session on mobile, hand context to Claude Code for implementation, and pick it back up later without starting from scratch. That part is genuinely useful.

## The tradeoffs

But the token overhead is not small, the maintenance of keeping Notion and Linear telling the same story compounds over time, and I'm maintaining what is probably governance infrastructure built for a team when it's really just me and a bunch of agents.

The slightly absurd part is that I'm essentially building an external brain for an AI and myself, because the AI's own memory system doesn't work across its own surfaces yet. That's where we are in March 2026 apparently.

Anthropic is shipping things in this direction, [Dispatch](https://coey.com/resources/blog/2026/03/17/anthropic-dispatch-turns-claude-into-your-always-on-creative-coworker/) as research preview, but it's targeting a different problem. Nothing has connected into a full solution yet. There are people in the community building more purpose-built approaches to cross-surface context and memory sharing, and I'm paying close attention to how those shape up.

For now it works, honestly with tradeoffs, and I know I'll need something more efficient as the workflow gets more complex. But I'm not gonna lie, the fact that it works at all across every surface has been worth the overhead so far (emphasis on "so far").
