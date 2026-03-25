# Memory Update Protocol

## Principles

1. Memory is an instruction set — changes need human oversight
2. Never auto-apply memory changes
3. Verify memories against current file state before proposing
4. Respect the 200-line MEMORY.md hard cap

## Proposal categories

| Action | When to use |
| ------ | ----------- |
| `[NEW]` | Pattern emerged that no existing memory covers |
| `[STRENGTHEN]` | Existing memory exists but wasn't strong enough to prevent a mistake |
| `[STALE?]` | Memory references state that has changed (file moved, task completed) |
| `[DELETE]` | Memory is demonstrably wrong or fully superseded |

## Diff format

Present proposals to the user in this format:

```text
PROPOSED MEMORY CHANGES:

[NEW] feedback_<topic>.md
  <One-line rule>
  Why: <reason from session evidence>
  How to apply: <when this kicks in>

[STRENGTHEN] feedback_<existing>.md
  Add: <additional guidance>
  Evidence: <what happened this session>

[STALE?] project_<existing>.md
  Current content: <what it says>
  Actual state: <what's true now>

[DELETE] reference_<existing>.md
  Reason: <why it's no longer needed>

Apply? [review each / apply all / skip]
```

## Rules

- Each proposal must cite session evidence (which event triggered it)
- Before proposing [NEW], check existing memories — maybe strengthen instead
- Before proposing [STALE?], verify by reading the referenced files/state
- [DELETE] requires strong evidence, not just "seems old"
- After applying, update MEMORY.md index (watch the 200-line cap)
