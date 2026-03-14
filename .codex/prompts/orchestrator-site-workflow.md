# Orchestrator Site Workflow

Use this workflow when the user needs site changes through QA and PR packaging.

- Team lead orchestrates task decomposition and user communication.
- Route source-level findings to `$site-quality-auditor` and `$official-doc-verifier`.
- Route file edits to `developer` behavior.
- Keep writer/editor roles out of site-only implementation unless prose editing is requested.
- Run relevant audits:
  `make site-audit AUDIT=seo TARGET=...`
  `make site-audit AUDIT=quality TARGET=...`
  `make site-audit AUDIT=maintenance TARGET=...`
  `make site-audit AUDIT=performance TARGET=...`
- Run `make qa-local` before commit.
- Finish with repo flow and PR packaging.
