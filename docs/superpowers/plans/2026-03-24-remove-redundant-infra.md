# Remove Redundant Infrastructure (CWS-95) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the unused remember plugin and the `github-api.sh` curl fallback library, replacing wrapper calls with direct `gh` CLI calls.

**Architecture:** Clean removal — delete the fallback library, replace all wrapper calls in `create-pr.sh` and `finalize-merge.sh` with direct `gh` CLI equivalents, update tests and skill docs. No new abstractions needed.

**Tech Stack:** Bash (`gh` CLI), Ruby (Minitest), Markdown (agentskills.io SKILL.md)

**Spec:** `docs/superpowers/specs/2026-03-24-remove-redundant-infra-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `scripts/lib/github-api.sh` | Delete | Dead fallback library |
| `scripts/create-pr.sh` | Modify:264-272 | Replace wrapper calls with direct `gh` |
| `scripts/finalize-merge.sh` | Modify:7-8,25-30,76,141-142,256-264,276,280,283 | Replace wrapper calls with direct `gh` |
| `scripts/tests/create_pr_workflow_test.rb` | Modify:28-35,89-96 | Update assertions for direct `gh` patterns |
| `scripts/tests/finalize_merge_workflow_test.rb` | Modify:18-19,49-59 | Update assertions for direct `gh` patterns |
| `.agents/skills/repo-flow/SKILL.md` | Modify:17,92-93,101,149-164 | Remove fallback docs |
| `.agents/skills/repo-flow/references/branch-pr-merge.md` | Modify:40-41 | Remove `gh_or_curl` reference |
| `docs/tasks/CWS-95.md` | Already updated | Task file |
| `docs/superpowers/specs/2026-03-24-remove-redundant-infra-design.md` | Already written | Design spec |

### Prerequisite state

Commit 1 (30b1304) already landed: remember plugin removal (`.claude/remember/config.json` deleted, `.gitignore` entry removed, `Skill(remember)` removed from settings, `.remember/` directory deleted locally).

`create-pr.sh` has 2 partial edits from earlier in the session (source line removed, auth check replaced). These are unstaged. The plan treats this file as needing completion, not a fresh start.

---

## Task 1: Update tests FIRST (TDD — red phase)

Update test assertions to expect the NEW patterns before changing the scripts. Tests will fail (red) because the scripts still have old patterns.

**Files:**
- Modify: `scripts/tests/create_pr_workflow_test.rb:28-35,89-96`
- Modify: `scripts/tests/finalize_merge_workflow_test.rb:18-19,49-59`

- [ ] **Step 1: Update `create_pr_workflow_test.rb`**

Replace 4 existing test methods with new equivalents:
- `test_normalizes_pr_metadata_after_submit` — update assertions from `gh_or_curl_pr_edit` to `gh pr edit`
- `test_falls_back_to_pr_create_when_branch_has_no_pr` — update from `gh_or_curl_pr_view`/`gh_or_curl_pr_create` to `gh pr view`/`gh pr create`
- `test_sources_github_api_library` (line 89) → **rename** to `test_requires_gh_auth`, assert `gh auth status`
- `test_uses_fallback_auth_check` (line 93) → **rename** to `test_does_not_use_curl_fallback`, refute wrapper patterns

New method bodies:

```ruby
  def test_normalizes_pr_metadata_after_submit
    assert_match(/gh pr edit "\$branch" --title "\$title" --body-file "\$body_file"/, script_body)
    assert_match(/gh pr ready "\$branch"/, script_body)
  end

  def test_falls_back_to_pr_create_when_branch_has_no_pr
    assert_match(/if ! gh pr view "\$branch" >/i, script_body)
    assert_match(/gh pr create --base "\$base_branch" --head "\$branch" --title "\$title" --body-file "\$body_file"/, script_body)
  end

  def test_requires_gh_auth
    assert_match(/gh auth status/, script_body)
  end

  def test_does_not_use_curl_fallback
    refute_match(/gh_or_curl/, script_body)
    refute_match(/_gh_available/, script_body)
    refute_match(/github-api\.sh/, script_body)
  end
```

- [ ] **Step 2: Update `finalize_merge_workflow_test.rb`**

Replace 4 existing test methods with new equivalents:
- `test_still_merges_with_rebase_and_deletes_branch` (line 18) — update assertion from `gh_or_curl_pr_merge` to `gh pr merge`
- `test_uses_fallback_library_for_pr_view` (line 49) → **rename** to `test_uses_gh_pr_view`, assert `gh pr view "$pr" --json`
- `test_sources_github_api_library` (line 53) → **rename** to `test_requires_gh_auth`, assert `gh auth status`
- `test_uses_fallback_auth_check` (line 57) → **rename** to `test_does_not_use_curl_fallback`, refute wrapper patterns

New method bodies:

```ruby
  def test_still_merges_with_rebase_and_deletes_branch
    assert_match(/gh pr merge "\$pr" --rebase --delete-branch/, script_body)
  end

  def test_uses_gh_pr_view
    assert_match(/gh pr view "\$pr" --json/, script_body)
  end

  def test_requires_gh_auth
    assert_match(/gh auth status/, script_body)
  end

  def test_does_not_use_curl_fallback
    refute_match(/gh_or_curl/, script_body)
    refute_match(/_gh_available/, script_body)
    refute_match(/github-api\.sh/, script_body)
  end
```

- [ ] **Step 3: Run tests to verify they FAIL**

Run: `ruby scripts/tests/create_pr_workflow_test.rb && ruby scripts/tests/finalize_merge_workflow_test.rb`

Expected: FAIL — scripts still contain old wrapper patterns. This confirms the tests are actually checking something.

- [ ] **Step 4: Commit red tests**

```bash
git add scripts/tests/create_pr_workflow_test.rb scripts/tests/finalize_merge_workflow_test.rb
git commit -m "$(cat <<'EOF'
test(cws-95): update workflow tests to expect direct gh CLI calls

Tests now assert direct gh commands instead of gh_or_curl wrapper
patterns. Tests are intentionally red — scripts not yet refactored.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Refactor `create-pr.sh` (green phase — partial)

Complete the partial edits and replace remaining wrapper calls.

**Files:**
- Modify: `scripts/create-pr.sh:264-272`

**Note:** Lines 7-8 (source removal) and lines 17-20 (auth check) are already edited from the earlier session. This task completes lines 264-272.

- [ ] **Step 1: Replace `gh_or_curl_pr_view` and `gh_or_curl_pr_create`**

Replace lines 264-266:
```bash
# OLD:
if ! gh_or_curl_pr_view "$branch" >/dev/null 2>&1; then
  gh_or_curl_pr_create "$base_branch" "$branch" "$title" "$body_file"
fi
```

With:
```bash
# NEW:
if ! gh pr view "$branch" >/dev/null 2>&1; then
  gh pr create --base "$base_branch" --head "$branch" --title "$title" --body-file "$body_file"
fi
```

- [ ] **Step 2: Replace `gh_or_curl_pr_edit`**

Replace line 268:
```bash
# OLD:
gh_or_curl_pr_edit "$branch" "$title" "$body_file"
```

With:
```bash
# NEW:
gh pr edit "$branch" --title "$title" --body-file "$body_file"
```

- [ ] **Step 3: Remove `_gh_available` guard on draft check**

Replace lines 270-272:
```bash
# OLD:
if _gh_available && [[ "$(gh pr view "$branch" --json isDraft --jq '.isDraft')" == "true" ]]; then
  gh pr ready "$branch"
fi
```

With:
```bash
# NEW:
if [[ "$(gh pr view "$branch" --json isDraft --jq '.isDraft')" == "true" ]]; then
  gh pr ready "$branch"
fi
```

- [ ] **Step 4: Run create-pr tests**

Run: `ruby scripts/tests/create_pr_workflow_test.rb`

Expected: PASS — all new assertions should match.

---

## Task 3: Refactor `finalize-merge.sh` (green phase — complete)

Replace all wrapper calls with direct `gh` CLI equivalents.

**Files:**
- Modify: `scripts/finalize-merge.sh:7-8,25-30,76,141-142,256-264,276,280,283`

- [ ] **Step 1: Remove source line and replace auth check**

Replace lines 7-30:
```bash
# OLD (lines 7-8):
# shellcheck disable=SC1091
. "$repo_root/scripts/lib/github-api.sh"

# OLD (lines 25-30):
if ! _gh_available; then
  if ! _github_resolve_token >/dev/null 2>&1; then
    echo "error: no GitHub authentication. Run: gh auth login, or set GITHUB_TOKEN" >&2
    exit 1
  fi
fi
```

With (remove lines 7-8 entirely, replace lines 25-30):
```bash
# NEW:
if ! gh auth status >/dev/null 2>&1; then
  echo "error: no GitHub authentication. Run: gh auth login" >&2
  exit 1
fi
```

- [ ] **Step 2: Replace `gh_or_curl_pr_view`**

Replace line 76:
```bash
# OLD:
pr_state="$(gh_or_curl_pr_view "$pr")"
```

With:
```bash
# NEW:
pr_state="$(gh pr view "$pr" --json number,state,url,headRefName,baseRefName,isDraft,statusCheckRollup,mergedAt)"
```

- [ ] **Step 3: Replace `_github_resolve_repo` + `github_api_get` + Ruby JSON**

Replace lines 141-142:
```bash
# OLD:
repo_slug="$(_github_resolve_repo)"
rebase_allowed="$(github_api_get "/repos/${repo_slug}" | ruby -rjson -e 'puts JSON.parse(STDIN.read)["allow_rebase_merge"]' 2>/dev/null || echo "true")"
```

With:
```bash
# NEW:
rebase_allowed="$(gh api repos/{owner}/{repo} --jq '.allow_rebase_merge' 2>/dev/null || echo "true")"
```

- [ ] **Step 4: Remove `_gh_available` guard on staleness CI check**

Replace lines 256-264:
```bash
# OLD:
      if _gh_available; then
        echo "waiting for CI checks after staleness bump..."
        if ! gh pr checks "$pr" --watch --fail-level error; then
          echo "error: CI checks failed after staleness bump; aborting merge" >&2
          exit 1
        fi
      else
        echo "warning: gh CLI not available; cannot verify CI checks after staleness bump" >&2
      fi
```

With:
```bash
# NEW:
      echo "waiting for CI checks after staleness bump..."
      if ! gh pr checks "$pr" --watch --fail-level error; then
        echo "error: CI checks failed after staleness bump; aborting merge" >&2
        exit 1
      fi
```

- [ ] **Step 5: Replace all `gh_or_curl_pr_merge` calls**

Replace lines 276, 280, 283 (3 occurrences):
```bash
# OLD (each occurrence):
gh_or_curl_pr_merge "$pr" rebase
```

With:
```bash
# NEW (each occurrence):
gh pr merge "$pr" --rebase --delete-branch
```

- [ ] **Step 6: Run finalize-merge tests**

Run: `ruby scripts/tests/finalize_merge_workflow_test.rb`

Expected: PASS — all new assertions should match.

---

## Task 4: Delete `github-api.sh` and run full tests (green phase — complete)

**Files:**
- Delete: `scripts/lib/github-api.sh`

- [ ] **Step 1: Delete the fallback library**

```bash
git rm scripts/lib/github-api.sh
```

- [ ] **Step 2: Run ALL tests**

Run: `ruby scripts/tests/create_pr_workflow_test.rb && ruby scripts/tests/finalize_merge_workflow_test.rb`

Expected: PASS — no script references the deleted file.

- [ ] **Step 3: Run `make qa-local`**

Run: `make qa-local`

Expected: PASS — shellcheck, markdownlint, semgrep, all hooks green.

- [ ] **Step 4: Commit atomic refactor**

```bash
git add scripts/lib/github-api.sh scripts/create-pr.sh scripts/finalize-merge.sh scripts/tests/create_pr_workflow_test.rb scripts/tests/finalize_merge_workflow_test.rb
git commit -m "$(cat <<'EOF'
refactor(cws-95): replace github-api.sh curl fallback with direct gh CLI

The curl fallback library was a workaround for gh CLI TLS issues in the
Claude Code sandbox. Now that gh auth is fixed and CI never calls these
scripts, the 332-line library with Ruby JSON parsing is dead code.

- Replace gh_or_curl_* wrappers with direct gh commands
- Replace _github_resolve_repo + github_api_get with gh api
- Remove _gh_available guards (gh is unconditionally required)
- Update structural tests for new patterns
- Delete scripts/lib/github-api.sh

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Update skill docs

Update repo-flow SKILL.md (per agentskills.io spec) and branch-pr-merge.md reference.

**Files:**
- Modify: `.agents/skills/repo-flow/SKILL.md:17,92-93,101,149-164`
- Modify: `.agents/skills/repo-flow/references/branch-pr-merge.md:40-41`

**Compliance:** All SKILL.md changes must maintain agentskills.io open standard compliance
(frontmatter fields, body structure, progressive disclosure budget). Reference:
https://agentskills.io/specification

- [ ] **Step 1: Remove `github-api.sh` from SKILL.md filePattern metadata**

In the frontmatter `metadata.filePattern` list, delete the line:
```yaml
    - "scripts/lib/github-api.sh"
```

- [ ] **Step 2: Remove curl fallback gotcha from SKILL.md**

Delete lines 92-93:
```markdown
- If `gh` CLI fails, scripts automatically fall back to `curl` + GitHub REST API. The fallback
  requires `GITHUB_TOKEN` or `gh auth token` to be available.
```

- [ ] **Step 3: Simplify auth rule in SKILL.md**

Replace line 101:
```markdown
# OLD:
- Require valid GitHub authentication (`gh` CLI or `GITHUB_TOKEN` for curl fallback).
```

With:
```markdown
# NEW:
- Require `gh` CLI authentication (`gh auth login`).
```

- [ ] **Step 4: Delete Fallback Authentication section from SKILL.md**

Delete lines 149-164 (the entire "## Fallback Authentication" section, from the heading through
the paragraph ending "transparent to callers.").

- [ ] **Step 5: Update branch-pr-merge.md Stack Merge Policy**

Replace lines 40-41:
```markdown
# OLD:
- `make finalize-merge PR=...` merges a single PR via `gh pr merge --rebase --delete-branch` (or
  the `gh_or_curl` fallback in `scripts/lib/github-api.sh` when `gh` CLI is unavailable). It
```

With:
```markdown
# NEW:
- `make finalize-merge PR=...` merges a single PR via `gh pr merge --rebase --delete-branch`. It
```

- [ ] **Step 6: Validate SKILL.md stays under progressive disclosure budget**

The SKILL.md body must be under 500 lines / ~5000 tokens (per agentskills.io spec and
`docs/sop.md` Section 2.5). After removing the Fallback Authentication section (~16 lines),
the file gets shorter. Verify with:

Run: `wc -l .agents/skills/repo-flow/SKILL.md`

Expected: Under 200 lines (currently ~206, minus ~16 deleted = ~190).

- [ ] **Step 7: Run `make qa-local`**

Run: `make qa-local`

Expected: PASS — markdownlint clean on updated docs.

- [ ] **Step 8: Commit docs update**

```bash
git add .agents/skills/repo-flow/SKILL.md .agents/skills/repo-flow/references/branch-pr-merge.md
git commit -m "$(cat <<'EOF'
docs(cws-95): remove curl fallback references from repo-flow skill

The github-api.sh curl fallback was removed in the previous commit.
Update skill docs to reflect that gh CLI is now the only auth path.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Final validation and PR

- [ ] **Step 1: Run full test suite one more time**

Run: `ruby scripts/tests/create_pr_workflow_test.rb && ruby scripts/tests/finalize_merge_workflow_test.rb`

Expected: PASS

- [ ] **Step 2: Run `make qa-local`**

Run: `make qa-local`

Expected: PASS

- [ ] **Step 3: Verify no orphaned references to deleted file**

Run: `grep -r 'github-api\.sh\|gh_or_curl\|_gh_available\|_github_resolve_token\|_github_resolve_repo' scripts/ .agents/skills/repo-flow/ --include='*.sh' --include='*.rb' --include='*.md'`

Expected: No matches (historical docs under `docs/superpowers/` are excluded from the search).

- [ ] **Step 4: Push and create PR**

Run: `git push origin cws/95-remove-remember-plugin` then `make create-pr TYPE=chore`

---

## DRY/KISS/SOLID/TDD Audit Summary

| Principle | Finding | Action |
|-----------|---------|--------|
| **DRY** | `gh auth status` guard appears in both scripts (3 lines each). Only 2 consumers — not worth extracting. | No change needed |
| **KISS** | Removing 332-line fallback + Ruby JSON pipes is the main KISS win. `finalize-merge.sh` rebase check goes from 3-tool chain to 1 `gh api` call. | Done in Task 3 |
| **SOLID (SRP)** | Both scripts maintain single responsibility. No new abstractions introduced. | No change needed |
| **TDD** | Tests updated FIRST (Task 1, red phase) before scripts. Green confirmed in Tasks 2-4. | Done in Task 1 |
| **New skill?** | Not needed — all changes are within existing repo-flow skill scope. The skill gets simpler, not more complex. | No new skill |
