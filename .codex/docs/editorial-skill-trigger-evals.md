# Editorial Skill Trigger Evals

Use this guide to evaluate implicit routing for the editorial skill set without overloading
`evals/evals.json`.

## Artifact Split

Use two distinct artifact types:

- `evals/eval_queries.json`
  Contains routing prompts only. For each implicitly invokable skill, keep fixed `train` and
  `validation` groups with both `should_trigger` and `should_not_trigger` queries.
- `evals/evals.json`
  Contains output-quality checks only. These cases evaluate what the skill produces after routing
  is already correct.

Current routing artifacts:

- `.agents/skills/content-brainstormer/evals/eval_queries.json`
- `.agents/skills/technical-post-drafter/evals/eval_queries.json`
- `.agents/skills/fact-checker/evals/eval_queries.json`
- `.agents/skills/historical-post-editor/evals/eval_queries.json`
- `.agents/skills/medium-porter/evals/eval_queries.json`
- `~/.codex/skills/content-research-writer/evals/eval_queries.json`
- `~/.codex/skills/sh-humanizer/evals/eval_queries.json`

`jekyll-post-publisher` stays explicit-only in this repo, so it has output-quality evals but no
implicit-routing query set.

## Run Method

For each routing query:

1. Run it in a fresh thread with no explicit `$skill-name`.
2. Repeat the same prompt 3 times.
3. Record whether the intended skill triggers first on each run.
4. Grade trigger rate separately for `train` and `validation`.

Pass thresholds:

- `should_trigger`: trigger rate must be greater than `0.5`
- `should_not_trigger`: trigger rate must be less than `0.5`

Do not accept description or policy changes based only on the train set. Compare train and
validation behavior before keeping a routing update.

## Recommended Workspace

For each evaluated skill, keep a local results workspace with:

- `with_skill/`
  Explicit `$skill-name` runs for output comparison.
- `without_skill/`
  Clean-context runs for implicit routing checks.
- `outputs/`
  Captured model outputs for each iteration.
- `timing.json`
  Run timing, latency, and invocation metadata.
- `grading.json`
  Pass or fail notes, routing collisions, and human review comments.
- `benchmark.json`
  A per-iteration summary with aggregate trigger rates for train and validation.

Save three fresh-thread runs per prompt so the trigger rate is meaningful enough to compare.

## Coverage Targets

Target 16 queries per implicitly invokable editorial skill:

- 8 `should_trigger`
- 8 `should_not_trigger`
- 4 and 4 in `train`
- 4 and 4 in `validation`

Bias the negative cases toward near-miss prompts that could plausibly collide:

- ideation vs drafting
- drafting vs voice rewrite
- research and revision vs fact checking
- historical preservation vs Medium migration
- explicit packaging and publish workflow

## Output-Quality Evals

Use `evals/evals.json` to check output quality after routing:

- include `skill_name`
- keep `evals` as the case list
- include `expected_output`
- include `files` when the case depends on concrete fixtures
- use assertions only for objective checks such as preserved fields, required sections, explicit
  next steps, or metadata completeness

Keep voice, usefulness, and boundary quality in human review notes inside `grading.json`.

Use `.codex/docs/editorial-voice-eval-rubric.md` for the manual voice review checklist during those
notes.
