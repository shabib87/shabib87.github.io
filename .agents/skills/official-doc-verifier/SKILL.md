---
name: official-doc-verifier
description: Decide when official documentation must be consulted before making a claim or encoding workflow behavior. Use when tool, library, product, or API behavior may have drifted and should be confirmed with Context7 or another first-party source.
---

# Official Doc Verifier

Use this skill when memory is not enough.

## Workflow

1. Prefer Context7 when the official docs are available there.
2. Fall back to first-party docs when Context7 is not the right source.
3. Summarize the confirmed behavior before encoding it in code, docs, or publishing guidance.

## Output Expectations

- confirmed official behavior
- source used
- any implementation-impacting constraints or caveats

## Done Criteria

- the relevant tool or product behavior is verified against a primary source
- the result is clear enough to implement without guessing

## Rules

- Prefer official docs over memory for version-sensitive behavior.
- Use Context7 first when the official docs are available there.
- Fall back to first-party docs when Context7 is not the right source.
- Summarize the conclusion when it affects implementation or published guidance.
