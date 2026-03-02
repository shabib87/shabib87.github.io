---
name: official-doc-verifier
description: Decide when official documentation must be consulted before making a claim or encoding workflow behavior. Use when tool, library, product, or API behavior may have drifted and should be confirmed with Context7 or another first-party source.
---

# Official Doc Verifier

Use this skill when memory is not enough.

## Workflow

1. Read `references/approved-sources.md`.
2. Read `references/context7-lookup.md` when the docs are likely to be available in Context7.
3. Read `references/research-sequencing.md` when the answer will affect code, docs, or workflow behavior.
4. Check repo-local truth before leaving the workspace.
5. Prefer Context7 when the official docs are available there.
6. Fall back to first-party docs when Context7 is not the right source.
7. Use general web search only when repo-local truth, Context7, and first-party docs still do not answer the question.
8. Summarize the confirmed behavior before encoding it in code, docs, or publishing guidance.

## Output Expectations

- confirmed official behavior
- source used
- any implementation-impacting constraints or caveats

## Done Criteria

- the relevant tool or product behavior is verified against a primary source
- the result is clear enough to implement without guessing

## Rules

- Prefer official docs over memory for version-sensitive behavior.
- Check the repo first for repo-owned truth before leaving the workspace.
- Use Context7 first when the official docs are available there.
- Fall back to first-party docs when Context7 is not the right source.
- Use narrow, behavior-specific queries instead of topic-level lookups.
- State the implementation impact, not only the citation result.
- Summarize the conclusion when it affects implementation or published guidance.
