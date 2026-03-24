# Design: Remove Redundant Infrastructure (CWS-95)

## Problem

Two pieces of infrastructure add complexity for zero benefit:

1. **Remember plugin** (`remember@claude-plugins-official`) — third-party plugin never used.
   `.remember/remember.md` stayed 0 bytes across multiple sessions. Built-in auto memory +
   `docs/agent-context.md` already provide cross-session continuity.

2. **`scripts/lib/github-api.sh`** — 332-line curl fallback library with Ruby JSON parsing.
   Was a workaround for `gh` CLI TLS issues in the Claude Code sandbox. `gh` auth is now
   fixed. CI never calls these scripts (work is left-shifted to pre-commit/pre-push hooks).

## Approach

Clean removal. No partial fallback or abstraction layer needed.

## Changes

### Remember plugin (already done in commit 30b1304)

| File | Action |
|------|--------|
| `.claude/remember/config.json` | Delete (tracked) |
| `.gitignore` | Remove `.remember/` entry |
| `.claude/settings.local.json` | Remove `Skill(remember)` allowlist entry |
| `.remember/` directory | Delete locally (untracked) |

### github-api.sh curl fallback removal

| File | Action |
|------|--------|
| `scripts/lib/github-api.sh` | Delete entirely |
| `scripts/create-pr.sh` | Replace wrapper calls with direct `gh` CLI |
| `scripts/finalize-merge.sh` | Replace wrapper calls with direct `gh` CLI |
| `scripts/tests/create_pr_workflow_test.rb` | Update assertions |
| `scripts/tests/finalize_merge_workflow_test.rb` | Update assertions |
| `.agents/skills/repo-flow/SKILL.md` | Remove fallback sections, update filePattern |
| `.agents/skills/repo-flow/references/branch-pr-merge.md` | Rewrite stack merge policy reference |

### Mapping: wrapper to direct `gh` calls

| Wrapper function | Direct replacement |
|---|---|
| `. github-api.sh` + `_gh_available` + `_github_resolve_token` | `gh auth status` |
| `gh_or_curl_pr_view "$ref"` | `gh pr view "$ref" --json number,state,url,headRefName,baseRefName,isDraft,statusCheckRollup,mergedAt` |
| `gh_or_curl_pr_create "$base" "$head" "$title" "$body_file"` | `gh pr create --base "$base" --head "$head" --title "$title" --body-file "$body_file"` |
| `gh_or_curl_pr_edit "$ref" "$title" "$body_file"` | `gh pr edit "$ref" --title "$title" --body-file "$body_file"` |
| `gh_or_curl_pr_merge "$ref" rebase` | `gh pr merge "$ref" --rebase --delete-branch` |
| `_github_resolve_repo` + `github_api_get "/repos/$slug"` | `gh api repos/{owner}/{repo} --jq '.allow_rebase_merge' 2>/dev/null \|\| echo "true"` |
| `if _gh_available && ...` (create-pr.sh draft check) | Remove `_gh_available` guard; keep `gh pr view` check unconditionally |
| `if _gh_available; then ... else warning` (finalize-merge.sh staleness CI check) | Direct `gh pr checks` call (remove else branch) |

### Detail: `create-pr.sh` changes

1. Remove `. "$repo_root/scripts/lib/github-api.sh"` source line
2. Replace `_gh_available` + `_github_resolve_token` auth block with `gh auth status`
3. Replace `gh_or_curl_pr_view "$branch"` with `gh pr view "$branch"`
4. Replace `gh_or_curl_pr_create ...` with `gh pr create --base ... --head ... --title ... --body-file ...`
5. Replace `gh_or_curl_pr_edit ...` with `gh pr edit "$branch" --title ... --body-file ...`
6. Remove `_gh_available` guard on draft check (line 270); keep unconditional `gh pr view` + `gh pr ready`

### Detail: `finalize-merge.sh` changes

1. Remove `. "$repo_root/scripts/lib/github-api.sh"` source line
2. Replace `_gh_available` + `_github_resolve_token` auth block with `gh auth status`
   - Error message drops "or set GITHUB_TOKEN" since that path no longer exists
3. Replace `gh_or_curl_pr_view "$pr"` with `gh pr view "$pr" --json ...`
4. Replace `_github_resolve_repo` + `github_api_get` + `ruby -rjson` with
   `gh api repos/{owner}/{repo} --jq '.allow_rebase_merge'`
   - Preserve `|| echo "true"` default fallback for API failure
   - Ruby JSON parsing layer eliminated by `--jq`
5. Remove `_gh_available` guard on staleness CI check (line 256); keep direct `gh pr checks`
   call, remove else branch with warning
6. Replace all `gh_or_curl_pr_merge "$pr" rebase` calls with `gh pr merge "$pr" --rebase --delete-branch`

### Detail: test assertion updates

**`create_pr_workflow_test.rb`** — 4 methods to update:

| Method | Current assertion | New assertion |
|--------|------------------|---------------|
| `test_sources_github_api_library` | `scripts/lib/github-api\.sh` | `gh auth status` |
| `test_uses_fallback_auth_check` | `_gh_available` + `_github_resolve_token` | `gh auth status` |
| `test_normalizes_pr_metadata_after_submit` | `gh_or_curl_pr_edit` | `gh pr edit` |
| `test_falls_back_to_pr_create_when_branch_has_no_pr` | `gh_or_curl_pr_view` + `gh_or_curl_pr_create` | `gh pr view` + `gh pr create` |

**`finalize_merge_workflow_test.rb`** — 4 methods to update:

| Method | Current assertion | New assertion |
|--------|------------------|---------------|
| `test_sources_github_api_library` | `scripts/lib/github-api\.sh` | `gh auth status` |
| `test_uses_fallback_auth_check` | `_gh_available` + `_github_resolve_token` | `gh auth status` |
| `test_uses_fallback_library_for_pr_view` | `gh_or_curl_pr_view` | `gh pr view` |
| `test_still_merges_with_rebase_and_deletes_branch` | `gh_or_curl_pr_merge` | `gh pr merge` |

### Detail: SKILL.md updates

Three sections to modify in `.agents/skills/repo-flow/SKILL.md`:

1. **filePattern metadata** (line 17): Remove `"scripts/lib/github-api.sh"` entry
2. **Gotchas** (lines 92-93): Remove bullet about `gh` CLI failing and curl fallback
3. **Rules** (line 101): Simplify from "Require valid GitHub authentication (`gh` CLI or
   `GITHUB_TOKEN` for curl fallback)" to "Require `gh` CLI authentication"
4. **Fallback Authentication section** (lines 149-164): Delete entirely

### Detail: branch-pr-merge.md updates

Rewrite line 40-41 in Stack Merge Policy section from:
> `make finalize-merge PR=...` merges a single PR via `gh pr merge --rebase --delete-branch`
> (or the `gh_or_curl` fallback in `scripts/lib/github-api.sh` when `gh` CLI is unavailable).

To:
> `make finalize-merge PR=...` merges a single PR via `gh pr merge --rebase --delete-branch`.

### Not touched (historical/immutable)

- `docs/superpowers/plans/2026-03-22-script-hardening.md`
- `docs/superpowers/specs/2026-03-22-script-hardening-design.md`
- `.codex/rollout/evidence/cws-94-fallback-and-flags.md`
- `docs/superpowers/plans/2026-03-22-backlog-hygiene.md`

## Behavior preservation

The `gh` CLI was already the primary path in all wrappers — every `gh_or_curl_*` function
tries `gh` first and only falls back to `curl` on failure. Removing the fallback changes
nothing about the happy path.

Error messages will improve — `gh` CLI native errors are more informative than the library's
custom messages, and stderr is no longer suppressed by `2>/dev/null` on wrapper calls.

The `|| echo "true"` fallback on the rebase-allowed check is preserved so the script does
not fail hard if the API call fails (matching current behavior).

## Commit structure

1. **Commit 1** (already done): Remember plugin removal
2. **Commit 2**: Delete `github-api.sh` + refactor both scripts + update tests (atomic —
   scripts must not reference deleted functions between commits)
3. **Commit 3**: Update skill docs (SKILL.md + branch-pr-merge.md)

## Risks

- **Low**: `gh` CLI must be authenticated for scripts to work. This was already true for the
  primary path. The only lost capability is the `GITHUB_TOKEN` env var fallback, which was
  never used outside the curl workaround context.

## Validation

- `make qa-local` must pass (pre-commit hooks, shellcheck, markdownlint, semgrep)
- Ruby workflow tests must pass (`ruby scripts/tests/create_pr_workflow_test.rb`,
  `ruby scripts/tests/finalize_merge_workflow_test.rb`)
- Manual smoke test: `make create-pr TYPE=chore` on the CWS-95 branch
