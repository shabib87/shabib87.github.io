---
id: CWS-94
title: "Harden PR Scripts for Stack, Sandbox, and Agent Workflows"
parent: CWS-81
status: In Progress
linear: https://linear.app/codewithshabib/issue/CWS-94
---

## Brief

Fix broken `create-pr.sh` and `finalize-merge.sh` scripts after CWS-93 phase removal.
Add governance exempt patterns, gh/curl fallback, non-interactive mode, stack merge support,
template-driven PR body, agent-context staleness mechanism, and repo-flow skill rewrite.

## Design Spec

`docs/superpowers/specs/2026-03-22-script-hardening-design.md`

## Implementation Plan

`docs/superpowers/plans/2026-03-22-script-hardening.md`

## Evidence

- `.codex/rollout/evidence/cws-94-phase-removal-governance-fix.md`
- `.codex/rollout/evidence/cws-94-fallback-and-flags.md`
- `.codex/rollout/evidence/cws-94-staleness-and-skill.md`
