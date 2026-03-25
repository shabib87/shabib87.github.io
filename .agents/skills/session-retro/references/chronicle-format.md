# Chronicle File Format Reference

## Location

`~/.claude/projects/<project-dir>/chronicle/YYYY-MM-DD-<branch-slug>.md`

## Frontmatter

```yaml
---
session_id: <uuid from SessionStart hook>
date: YYYY-MM-DD
branch: <git branch name>
task: CWS-<id> (extracted from branch, may be empty)
started: <ISO 8601 UTC timestamp>
---
```

## Locked headers

Only two H2 headers are allowed:

- `## Events` — structured event log
- `## Summary` — session narrative

No other H2 headers. No H1 headers (frontmatter serves as the title).

## Event format

```text
- [TAG] brief description
- HH:MM [TAG] brief description (timestamp optional, use for chronology)
  Indented detail line (only when rationale is not obvious)
```

## Event tags (8 categories)

| Tag | When to log |
| --- | ----------- |
| `[DECISION]` | Chose between alternatives with tradeoffs |
| `[ERROR]` | Code or reasoning mistake; something broke |
| `[PIVOT]` | Changed direction; abandoned previous approach |
| `[INSIGHT]` | Surprising or non-obvious discovery |
| `[MEMORY-HIT]` | Memory file prevented a mistake |
| `[MEMORY-MISS]` | Memory failed to prevent mistake, or gap found |
| `[USER-CORRECTION]` | Human corrected Claude's approach |
| `[BLOCKED]` | Environmental/tooling obstacle preventing progress |

## Category boundaries

- `[ERROR]` = Claude's mistake. `[BLOCKED]` = external obstacle.
- `[DECISION]` = fresh choice. `[PIVOT]` = abandoning a previous commitment.
- `[INSIGHT]` = discovery without immediate action. If it leads to action, use `[DECISION]`.
- `[MEMORY-HIT]` = memory prevented a mistake. `[MEMORY-MISS]` = it should have but didn't.

## What NOT to log

- Routine actions: file reads, tool calls, simple edits
- Obvious steps: "read the file", "ran the tests"
- Only log: decisions, failures, surprises, and corrections
