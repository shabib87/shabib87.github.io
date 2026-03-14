# Editorial Skill Trigger Evals

Use this guide to evaluate implicit routing for the editorial skill set.

## Current Routing Artifacts

- `.agents/skills/content-brainstormer/evals/eval_queries.json`
- `.agents/skills/technical-post-drafter/evals/eval_queries.json`
- `.agents/skills/fact-checker/evals/eval_queries.json`
- `.agents/skills/historical-post-editor/evals/eval_queries.json`
- `~/.codex/skills/content-research-writer/evals/eval_queries.json`
- `~/.codex/skills/sh-humanizer/evals/eval_queries.json`

## Coverage Targets

Target 16 queries per implicitly invokable editorial skill:

- 8 `should_trigger`
- 8 `should_not_trigger`
- 4 and 4 in `train`
- 4 and 4 in `validation`

Bias negative cases toward near-miss prompts:

- ideation vs drafting
- drafting vs voice rewrite
- research/revision vs fact checking
- historical preservation vs net-new drafting
- explicit packaging and publish workflow
