# Tooling

## Philosophy

Local checks are the primary quality gate. CI is intentionally light and acts as a backup signal.
Do not commit until the full local QA gate passes.

## One-Shot Setup

Run:

```bash
make setup
```

## Core QA Targets

- `make lint`
- `make security`
- `make workflow-check`
- `make site-audit AUDIT=seo TARGET=site`
- `make qa-local`
- `make check`

## Codex Workflow Checks

Run:

```bash
make workflow-check
```

This validates:

- repo-local skills metadata and `agents/openai.yaml` integrity
- required workflow prompts and docs
- multi-agent orchestration contracts via `scripts/validate-multi-agent-contracts.rb`
- retired workflow token checks for decommissioned surfaces

## Full Local QA

Run:

```bash
make qa-local
```

This is the required local release gate before commit, push, PR creation, or rebase integration.
