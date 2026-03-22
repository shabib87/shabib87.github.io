# CWS-93: Branch Prefix Rename Evidence

## Scripts Modified

- `scripts/create-pr.sh` — regex `codex/cws-` → `cws/`
- `scripts/start-phase.sh` — string construction `codex/` → `cws/`
- `scripts/run-codex-checks.sh` — regex `codex/phase-` → `cws/phase-`

## Change Type

Mechanical text replacement only. No logic changes. Branch prefix convention
`codex/cws-<id>-<slug>` renamed to `cws/<id>-<slug>`.

## Verification

```bash
rg "codex/(cws|phase|[a-z]+-)" scripts/create-pr.sh scripts/start-phase.sh scripts/run-codex-checks.sh
```

Expected: zero matches. Confirmed.
