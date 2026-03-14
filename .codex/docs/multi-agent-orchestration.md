# Multi-Agent Orchestration

## Purpose

This repository uses multi-agent orchestration to keep the main thread focused on decisions while
specialized roles execute bounded tasks.

## Runtime Defaults

- `max_threads = 6`
- `max_depth = 1`
- `job_max_runtime_seconds = 1800`
- fallback mode: if delegation fails, continue in single-agent mode and report degraded execution

## Ownership Lock

- `writer` owns drafting and restructuring of blog body prose.
- `editor` owns editorial refinement, structure, clarity, and voice polish.
- `team-lead` owns orchestration and user communication only.
- `publisher-release` owns publish packaging and PR mechanics, not body drafting.

## Role Boundaries

- Read-only roles: `team-lead`, `researcher`, `seo-expert`, `fact-checker`
- Write roles: `developer`, `writer`, `editor`, `publisher-release`,
  `historical-post-editor`

## Delegation Rules

1. Parallelize read-heavy work first: audits, search, triage, and verification.
2. Assign one write owner per overlapping file set.
3. Do not run concurrent writes on the same files.
4. Ask the user only on blocking or high-impact decisions.

## QA Contract

- `make codex-check` validates skill metadata, prompt/doc integrity, and multi-agent contracts.
- `make qa-local` remains the release-grade gate before commit, push, PR, and integration.
- For decommissioned workflow surfaces, keep explicit negative checks in codex-check.
