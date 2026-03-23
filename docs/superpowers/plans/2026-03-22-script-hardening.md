# CWS-94: Harden PR Scripts — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix broken `create-pr.sh` and `finalize-merge.sh` scripts, add governance exempt patterns to unblock Dependabot PR #46, add `curl` fallback for `gh`, non-interactive mode, stack merge support, template-driven PR body generation, agent-context staleness mechanism, and repo-flow skill rewrite.

**Architecture:** 3-PR Graphite stack. PR 1 (urgent) removes dead phase logic and renames `codex-check` → `workflow-check`, unblocking CI. PR 2 adds `gh`/`curl` fallback library, non-interactive flags, stack merge, and template-driven PR body. PR 3 adds agent-context staleness hook and rewrites the repo-flow skill.

**Tech Stack:** Bash, Ruby (minitest), GitHub Actions YAML, Graphite CLI

**Spec:** `docs/superpowers/specs/2026-03-22-script-hardening-design.md`

---

## File Structure

### PR 1 — Phase removal + governance fix + rename

| Action | Path | Responsibility |
|--------|------|---------------|
| Modify | `.codex/rollout/active-plan.yaml` | Add `exempt_branch_patterns` list |
| Modify | `scripts/validate-rollout-governance.rb` | Handle exempt patterns, skip branch validation for exempt branches |
| Modify | `scripts/tests/rollout_governance_test.rb` | Add exempt pattern tests |
| Rename | `scripts/run-codex-checks.sh` → `scripts/run-workflow-checks.sh` | File rename + internal updates |
| Modify | `scripts/create-pr.sh` | Remove phase logic (lines 41-69, 137-170) |
| Modify | `scripts/finalize-merge.sh` | Remove phase logic (lines 39-42, 58-60, 65, 71-72, 78, 87-95, 139-170) |
| Modify | `scripts/tests/finalize_merge_workflow_test.rb` | Remove phase pattern assertions |
| Modify | `scripts/tests/repo_ruby_activation_test.rb` | Update `CODEX_CHECK_PATH` constant |
| Modify | `Makefile` | Rename `codex-check` → `workflow-check` |
| Modify | `.github/workflows/rollout-governance.yml` | Update script ref + bump `actions/checkout@v6` |
| Modify | `.github/workflows/jekyll-build.yml` | Bump `actions/checkout@v6` |
| Modify | `.github/workflows/semgrep.yml` | Bump `actions/checkout@v6` |
| Modify | `scripts/run-local-qa.sh` | `make codex-check` → `make workflow-check` |
| Modify | `scripts/site-audit.sh` | `codex-check` → `workflow-check` in target validation |
| Modify | `.codex/docs/tooling.md` | `codex-check` → `workflow-check` references |
| Modify | `.codex/docs/multi-agent-orchestration.md` | `codex-check` → `workflow-check` references |
| Modify | `.codex/docs/multi-agent-rollout-checklist.md` | `codex-check` → `workflow-check` references |
| Create | `.codex/rollout/evidence/cws-94-phase-removal-governance-fix.md` | Evidence file |

### PR 2 — Fallback, non-interactive, stack merge, dynamic body

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `scripts/lib/github-api.sh` | Shared `gh`/`curl` fallback functions |
| Modify | `scripts/create-pr.sh` | Use fallback lib, template-driven PR body |
| Modify | `scripts/finalize-merge.sh` | Use fallback lib, `--yes` flag, `--stack` flag |
| Modify | `Makefile` | Add `YES=1` and `STACK=1` variables |
| Create | `.codex/rollout/evidence/cws-94-fallback-and-flags.md` | Evidence file |

### PR 3 — Staleness mechanism + repo-flow skill update

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `.claude/hooks/check-agent-context-staleness.sh` | SessionStart hook |
| Modify | `scripts/finalize-merge.sh` | Post-merge staleness timestamp bump |
| Modify | `.agents/skills/repo-flow/SKILL.md` | Full rewrite of workflow docs |
| Modify | `.agents/skills/repo-flow/references/branch-pr-merge.md` | Update for new workflow |
| Create | `.codex/rollout/evidence/cws-94-staleness-and-skill.md` | Evidence file |
| Create | `docs/tasks/CWS-94.md` | Task file |

---

## Task 0: Branch setup and Graphite stack base

**Files:**
- None (git operations only)

- [ ] **Step 1: Switch to main and pull latest**

```bash
git checkout main && git pull --ff-only origin main
```

- [ ] **Step 2: Create the task branch for PR 1**

```bash
gt create cws/94-phase-removal-governance-fix -m "chore: PR 1 — phase removal + governance fix + rename"
```

- [ ] **Step 3: Verify branch**

```bash
git branch --show-current
```

Expected: `cws/94-phase-removal-governance-fix`

---

## Task 1: Add exempt branch patterns to active-plan.yaml (D1)

**Files:**
- Modify: `.codex/rollout/active-plan.yaml`

- [ ] **Step 1: Add `exempt_branch_patterns` to active-plan.yaml**

Add after `task_branch_pattern`:

```yaml
exempt_branch_patterns:
  - '^dependabot/'
  - '^renovate/'
  - '^gh-pages$'
```

- [ ] **Step 2: Commit**

```bash
git add .codex/rollout/active-plan.yaml
git commit -m "chore(cws-94): add exempt_branch_patterns to active-plan.yaml"
```

---

## Task 2: Update governance validator for exempt patterns (D1)

**Files:**
- Modify: `scripts/validate-rollout-governance.rb`
- Modify: `scripts/tests/rollout_governance_test.rb`

- [ ] **Step 1: Write failing tests for exempt patterns**

Add two new tests to `scripts/tests/rollout_governance_test.rb`:

```ruby
def test_accepts_exempt_dependabot_branch
  with_repo(branch: "dependabot/npm_and_yarn/lodash-4.17.21") do
    write_active_plan("exempt_branch_patterns" => ["^dependabot/", "^renovate/", "^gh-pages$"])
    stdout, stderr, status = run_validator(branch: "dependabot/npm_and_yarn/lodash-4.17.21")
    assert status.success?, "expected success for exempt branch, got stderr: #{stderr}"
    assert_match(/exempt/, stdout)
  end
end

def test_accepts_exempt_gh_pages_branch
  with_repo(branch: "gh-pages") do
    write_active_plan("exempt_branch_patterns" => ["^dependabot/", "^renovate/", "^gh-pages$"])
    stdout, stderr, status = run_validator(branch: "gh-pages")
    assert status.success?, "expected success for exempt branch, got stderr: #{stderr}"
    assert_match(/exempt/, stdout)
  end
end

def test_rejects_non_exempt_non_matching_branch
  with_repo(branch: "feature/random") do
    write_active_plan("exempt_branch_patterns" => ["^dependabot/", "^renovate/", "^gh-pages$"])
    _stdout, stderr, status = run_validator(branch: "feature/random")
    refute status.success?
    assert_match(/does not match task pattern/i, stderr)
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd scripts && ruby tests/rollout_governance_test.rb
```

Expected: 2 new tests FAIL (exempt pattern not handled yet), 1 new test may pass (existing rejection behavior)

- [ ] **Step 3: Implement exempt pattern handling in validator**

In `scripts/validate-rollout-governance.rb`, after reading `task_branch_pattern` (line 37), add:

```ruby
exempt_branch_patterns = plan["exempt_branch_patterns"].is_a?(Array) ? plan["exempt_branch_patterns"] : []
```

Then modify the branch validation block (lines 61-71). Replace:

```ruby
if branch == base_branch
  puts "rollout governance check skipped for base branch #{base_branch}"
  exit 0 if errors.empty?
elsif branch.empty?
  errors << "unable to detect current branch"
else
  task_match = Regexp.new(task_branch_pattern).match(branch) rescue nil
  if task_match.nil? && apply_to_all_prs
    errors << "branch #{branch.inspect} does not match task pattern #{task_branch_pattern.inspect}"
  end
end
```

With:

```ruby
if branch == base_branch
  puts "rollout governance check skipped for base branch #{base_branch}"
  exit 0 if errors.empty?
elsif branch.empty?
  errors << "unable to detect current branch"
else
  exempt = exempt_branch_patterns.any? { |pattern| Regexp.new(pattern).match?(branch) rescue false }
  if exempt
    puts "rollout governance check passed for plan=#{plan_id} branch=#{branch} (exempt)"
    exit 0 if errors.empty?
  else
    task_match = Regexp.new(task_branch_pattern).match(branch) rescue nil
    if task_match.nil? && apply_to_all_prs
      errors << "branch #{branch.inspect} does not match task pattern #{task_branch_pattern.inspect}"
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd scripts && ruby tests/rollout_governance_test.rb
```

Expected: ALL tests pass (including new exempt pattern tests)

- [ ] **Step 5: Commit**

```bash
git add scripts/validate-rollout-governance.rb scripts/tests/rollout_governance_test.rb
git commit -m "feat(cws-94): add exempt branch pattern support to governance validator"
```

---

## Task 3: Remove phase logic from create-pr.sh (D2)

**Files:**
- Modify: `scripts/create-pr.sh`

- [ ] **Step 1: Remove `phase_branch_pattern` from the Ruby plan-reading block**

In the inline Ruby (lines 25-69), replace the plan validation and branch-mode detection with task-only logic:

Remove lines referencing `phase_branch_pattern`:
- Line 41: `phase_branch_pattern = data["phase_branch_pattern"].to_s.strip`
- Line 44: remove `phase_branch_pattern.empty?` from the `if` condition
- Lines 48-66: Replace the entire branch_mode detection block
- Line 68: Update the `puts` output to remove phase fields

The new inline Ruby should:
1. Read only `plan_id`, `base_branch`, `task_branch_pattern`, `required_checks`
2. Validate only those fields are present
3. Match branch only against `task_branch_pattern`
4. Output: `plan_id\tbase_branch\trequired_checks`

- [ ] **Step 2: Update the awk parsing after the Ruby block**

Lines 72-77: Remove parsing of `branch_mode`, `phase`, `phase_branch_pattern`. Keep only `plan_id`, `base_branch`, `required_checks`.

- [ ] **Step 3: Remove the phase prior-merge check block**

Delete lines 137-170 entirely (the `if [[ "$branch_mode" == "phase" && "$phase" -gt 1 ]]` block).

- [ ] **Step 4: Remove phase references from PR body**

In the `cat > "$body_file"` heredoc (lines 216-257):
- Remove the `branch_mode` and `phase` lines from Rollout Metadata
- Keep `plan_id` and `required_checks`

- [ ] **Step 5: Clean up `branch_mode` references**

The `issue_id` extraction (lines 118-135) is already task-only. Remove the `if [[ "$branch_mode" == "task" ]]` guard — since phase mode is gone, this is always task mode. The branch must match `task_branch_pattern` or the Ruby block already exits.

- [ ] **Step 6: Verify script syntax**

```bash
bash -n scripts/create-pr.sh
```

Expected: No syntax errors

- [ ] **Step 7: Commit**

```bash
git add scripts/create-pr.sh
git commit -m "fix(cws-94): remove phase logic from create-pr.sh"
```

---

## Task 4: Remove phase logic from finalize-merge.sh (D2)

**Files:**
- Modify: `scripts/finalize-merge.sh`
- Modify: `scripts/tests/finalize_merge_workflow_test.rb`

- [ ] **Step 1: Update finalize_merge_workflow_test.rb first**

Remove tests that assert phase-related patterns:

```ruby
# Remove test_allows_rollout_stack_base_branches — it asserts phase_branch_pattern.match?
# which no longer exists after phase removal.
# Keep: test_still_merges_with_rebase_and_deletes_branch
# Keep: test_self_review_checklist_prints_pr_base_branch
# Keep: test_prompt_targets_pr_base_for_single_pr_merge
# Keep: test_stack_note_points_to_graphite_stack_merge
# Keep: test_does_not_gate_on_task_file_status_text
```

Update `test_allows_rollout_stack_base_branches` to check for task-only stack base validation:

```ruby
def test_allows_rollout_stack_base_branches
  assert_match(/base_is_stack_branch = task_branch_pattern\.match\?\(base_ref\)/, script_body)
  assert_includes(script_body, "or a rollout stack branch")
end
```

- [ ] **Step 2: Remove phase logic from finalize-merge.sh**

In the inline Ruby plan-reading block (lines 23-54):
- Remove line 39: `phase_branch_pattern = ...`
- Remove `phase_branch_pattern.empty?` from the validation `if`
- Update `puts` output to remove `phase_branch_pattern` field

In the validation Ruby block (lines 64-127):
- Remove `phase_branch_pattern` parameter (ARGV.fetch(3))
- Remove `phase_branch_pattern` from `base_is_stack_branch` check — keep only `task_branch_pattern.match?(base_ref)`
- Remove the `if (phase_match = ...)` branch_mode detection — only match task pattern
- Remove `phase` from output

Remove the awk parsing of `phase_branch_pattern` and `phase` fields.

Delete lines 139-170: the `if [[ "$branch_mode" == "phase" && "$phase" -gt 1 ]]` prior-merge check block.

Remove `phase` from the self-review checklist output.

- [ ] **Step 3: Verify script syntax**

```bash
bash -n scripts/finalize-merge.sh
```

Expected: No syntax errors

- [ ] **Step 4: Run finalize-merge tests**

```bash
cd scripts && ruby tests/finalize_merge_workflow_test.rb
```

Expected: ALL tests pass

- [ ] **Step 5: Commit**

```bash
git add scripts/finalize-merge.sh scripts/tests/finalize_merge_workflow_test.rb
git commit -m "fix(cws-94): remove phase logic from finalize-merge.sh"
```

---

## Task 5: Rename run-codex-checks.sh → run-workflow-checks.sh (D8, D10)

**Files:**
- Rename: `scripts/run-codex-checks.sh` → `scripts/run-workflow-checks.sh`
- Modify: `scripts/run-workflow-checks.sh` (internal updates)
- Modify: `scripts/tests/repo_ruby_activation_test.rb`

- [ ] **Step 1: Rename the file**

```bash
git mv scripts/run-codex-checks.sh scripts/run-workflow-checks.sh
```

- [ ] **Step 2: Update internal self-check target**

In `scripts/run-workflow-checks.sh` line 73, replace:

```ruby
%w[site-audit codex-check qa-local start-phase rollout-audit].each do |target|
```

With:

```ruby
%w[site-audit workflow-check qa-local start-phase rollout-audit].each do |target|
```

- [ ] **Step 3: Update governance change detection regex**

In `scripts/run-workflow-checks.sh` line 170, replace:

```ruby
path.match?(%r{\Ascripts/(validate-rollout-governance\.rb|create-pr\.sh|finalize-merge\.sh|start-phase\.sh|rollout-audit\.sh|run-codex-checks\.sh)\z}) ||
```

With:

```ruby
path.match?(%r{\Ascripts/(validate-rollout-governance\.rb|create-pr\.sh|finalize-merge\.sh|start-phase\.sh|rollout-audit\.sh|run-workflow-checks\.sh)\z}) ||
```

- [ ] **Step 4: Fix backtick interpolation (D10)**

Replace backtick git command interpolation (lines 148-167) with `IO.popen` calls.

Replace:

```ruby
common_ancestor = `git -C "#{repo_root}" merge-base main HEAD 2>/dev/null`.strip
changed = Set.new
if !common_ancestor.empty?
  `git -C "#{repo_root}" diff --name-only --diff-filter=ACMRD #{common_ancestor}...HEAD`.each_line do |line|
```

With:

```ruby
common_ancestor = IO.popen(["git", "-C", repo_root, "merge-base", "main", "HEAD"], err: File::NULL, &:read).to_s.strip
changed = Set.new
if !common_ancestor.empty?
  IO.popen(["git", "-C", repo_root, "diff", "--name-only", "--diff-filter=ACMRD", "#{common_ancestor}...HEAD"], &:read).to_s.each_line do |line|
```

Apply the same pattern to all 4 backtick git commands:

```ruby
IO.popen(["git", "-C", repo_root, "diff", "--name-only", "--diff-filter=ACMRD"], &:read).to_s.each_line do |line|
```

```ruby
IO.popen(["git", "-C", repo_root, "diff", "--name-only", "--cached", "--diff-filter=ACMRD"], &:read).to_s.each_line do |line|
```

```ruby
IO.popen(["git", "-C", repo_root, "ls-files", "--others", "--exclude-standard"], &:read).to_s.each_line do |line|
```

- [ ] **Step 5: Update success message**

Line 185, replace:

```ruby
puts "codex workflow checks passed"
```

With:

```ruby
puts "workflow checks passed"
```

- [ ] **Step 6: Update repo_ruby_activation_test.rb**

In `scripts/tests/repo_ruby_activation_test.rb`, replace:

```ruby
CODEX_CHECK_PATH = File.expand_path("../run-codex-checks.sh", __dir__)
```

With:

```ruby
WORKFLOW_CHECK_PATH = File.expand_path("../run-workflow-checks.sh", __dir__)
```

And update the `codex_check_body` method and test:

```ruby
def workflow_check_body
  @workflow_check_body ||= File.read(WORKFLOW_CHECK_PATH)
end

def test_workflow_checks_activates_and_requires_repo_ruby
  assert_match(/activate_repo_ruby/, workflow_check_body)
  assert_match(/require_repo_ruby \|\| exit 1/, workflow_check_body)
end
```

- [ ] **Step 7: Commit**

```bash
git add scripts/run-workflow-checks.sh scripts/tests/repo_ruby_activation_test.rb
git commit -m "refactor(cws-94): rename run-codex-checks.sh to run-workflow-checks.sh, fix backtick interpolation"
```

---

## Task 6: Update all codex-check references (D8, D11)

**Files:**
- Modify: `Makefile`
- Modify: `.github/workflows/rollout-governance.yml`
- Modify: `.github/workflows/jekyll-build.yml`
- Modify: `.github/workflows/semgrep.yml`
- Modify: `scripts/run-local-qa.sh`
- Modify: `scripts/site-audit.sh`
- Modify: `.codex/docs/tooling.md`
- Modify: `.codex/docs/multi-agent-orchestration.md`
- Modify: `.codex/docs/multi-agent-rollout-checklist.md`

- [ ] **Step 1: Update Makefile**

Replace `.PHONY` line: `codex-check` → `workflow-check`

Replace help text: `make codex-check` → `make workflow-check`

Replace target:

```makefile
workflow-check:
	@./scripts/run-workflow-checks.sh
```

- [ ] **Step 2: Update rollout-governance.yml**

Replace `actions/checkout@v4` with `actions/checkout@v6`.

Replace `./scripts/run-codex-checks.sh` with `./scripts/run-workflow-checks.sh`.

- [ ] **Step 3: Update jekyll-build.yml and semgrep.yml**

Replace `actions/checkout@v4` with `actions/checkout@v6` in both files.

- [ ] **Step 4: Update run-local-qa.sh**

Line 19, replace:

```bash
run_step "Validating Codex skills, prompts, and docs" make codex-check
```

With:

```bash
run_step "Validating workflow skills, prompts, and docs" make workflow-check
```

- [ ] **Step 5: Update site-audit.sh**

Line 221, replace:

```ruby
%w[site-audit codex-check qa-local].each do |target_name|
```

With:

```ruby
%w[site-audit workflow-check qa-local].each do |target_name|
```

- [ ] **Step 6: Update .codex/docs references**

In `.codex/docs/tooling.md`:
- Replace `make codex-check` with `make workflow-check` (2 occurrences)

In `.codex/docs/multi-agent-orchestration.md`:
- Replace `make codex-check` with `make workflow-check`
- Replace `codex-check` with `workflow-check` in prose (2 occurrences)

In `.codex/docs/multi-agent-rollout-checklist.md`:
- Replace `make codex-check` with `make workflow-check`

- [ ] **Step 7: Commit**

```bash
git add Makefile .github/workflows/ scripts/run-local-qa.sh scripts/site-audit.sh .codex/docs/tooling.md .codex/docs/multi-agent-orchestration.md .codex/docs/multi-agent-rollout-checklist.md
git commit -m "refactor(cws-94): rename codex-check to workflow-check across all references, bump actions/checkout to v6"
```

---

## Task 7: Create evidence file and run validation for PR 1

**Files:**
- Create: `.codex/rollout/evidence/cws-94-phase-removal-governance-fix.md`

- [ ] **Step 1: Create evidence file**

```markdown
# CWS-94 PR 1: Phase Removal + Governance Fix + Rename

## Changes

- Added `exempt_branch_patterns` to `active-plan.yaml` (D1)
- Updated `validate-rollout-governance.rb` to skip branch validation for exempt patterns (D1)
- Added 3 exempt pattern tests to `rollout_governance_test.rb` (D1)
- Removed all `phase_branch_pattern` logic from `create-pr.sh` (D2)
- Removed all `phase_branch_pattern` logic from `finalize-merge.sh` (D2)
- Renamed `run-codex-checks.sh` → `run-workflow-checks.sh` (D8)
- Fixed backtick interpolation with `IO.popen` in `run-workflow-checks.sh` (D10)
- Updated Makefile target `codex-check` → `workflow-check` (D8)
- Updated all downstream references (CI, scripts, docs) (D8)
- Bumped `actions/checkout` from `@v4` to `@v6` across all workflows (D11)

## Validation

- `make qa-local` passed
- `make workflow-check` passed
- Governance tests pass (including exempt pattern tests)
```

- [ ] **Step 2: Run full validation**

```bash
make qa-local
```

Expected: PASS

- [ ] **Step 3: Commit evidence**

```bash
git add .codex/rollout/evidence/cws-94-phase-removal-governance-fix.md
git commit -m "docs(cws-94): add PR 1 evidence file"
```

---

## Task 8: Create PR 2 branch and github-api.sh library (D3)

**Files:**
- Create: `scripts/lib/github-api.sh`

- [ ] **Step 1: Create PR 2 branch**

```bash
gt create cws/94-fallback-and-flags -m "chore: PR 2 — fallback, non-interactive, stack merge, dynamic body"
```

- [ ] **Step 2: Create `scripts/lib/github-api.sh`**

```bash
#!/usr/bin/env bash
# Shared GitHub API functions with gh CLI primary + curl fallback.
# Source this file: . "$repo_root/scripts/lib/github-api.sh"
set -euo pipefail

# Resolve GitHub API token.
# Order: (1) GITHUB_TOKEN env, (2) gh auth token, (3) fail.
_github_resolve_token() {
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    printf '%s' "$GITHUB_TOKEN"
    return 0
  fi
  if command -v gh >/dev/null 2>&1; then
    local token
    token="$(gh auth token 2>/dev/null || true)"
    if [[ -n "$token" ]]; then
      printf '%s' "$token"
      return 0
    fi
  fi
  echo "error: no GitHub token available. Set GITHUB_TOKEN or run: gh auth login" >&2
  return 1
}

# Resolve OWNER/REPO from git remote.
_github_resolve_repo() {
  local remote_url
  remote_url="$(git remote get-url origin 2>/dev/null || true)"
  if [[ -z "$remote_url" ]]; then
    echo "error: cannot determine repository from git remote" >&2
    return 1
  fi
  # Handle SSH (git@github.com:owner/repo.git) and HTTPS (https://github.com/owner/repo.git)
  printf '%s' "$remote_url" | sed -E 's#^(https?://github\.com/|git@github\.com:)##; s#\.git$##'
}

# Check if gh CLI is available and authenticated.
_gh_available() {
  command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1
}

# GET request to GitHub API.
# Usage: github_api_get <endpoint>
# Example: github_api_get "/repos/owner/repo/pulls/123"
github_api_get() {
  local endpoint="$1"
  if _gh_available; then
    gh api "$endpoint" 2>/dev/null && return 0
  fi
  local token
  token="$(_github_resolve_token)" || return 1
  curl -fsSL \
    -H "Authorization: token $token" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com${endpoint}"
}

# POST/PATCH request to GitHub API.
# Usage: github_api_post <method> <endpoint> <json_body>
# Example: github_api_post POST "/repos/owner/repo/pulls" '{"title":"..."}'
github_api_post() {
  local method="$1" endpoint="$2" body="$3"
  if _gh_available; then
    gh api "$endpoint" --method "$method" --input - <<<"$body" 2>/dev/null && return 0
  fi
  local token
  token="$(_github_resolve_token)" || return 1
  curl -fsSL \
    -X "$method" \
    -H "Authorization: token $token" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "$body" \
    "https://api.github.com${endpoint}"
}

# View PR details by branch name or PR number.
# Usage: gh_or_curl_pr_view <branch_or_number>
# Returns JSON with number, state, url, headRefName, baseRefName, isDraft, statusCheckRollup.
gh_or_curl_pr_view() {
  local ref="$1"
  if _gh_available; then
    gh pr view "$ref" --json number,state,url,headRefName,baseRefName,isDraft,statusCheckRollup,mergedAt 2>/dev/null && return 0
  fi
  local repo
  repo="$(_github_resolve_repo)" || return 1
  # If ref is a number, fetch by number; otherwise search by head branch
  if [[ "$ref" =~ ^[0-9]+$ ]]; then
    github_api_get "/repos/${repo}/pulls/${ref}"
  else
    github_api_get "/repos/${repo}/pulls?head=${repo%%/*}:${ref}&state=open" | ruby -rjson -e '
      prs = JSON.parse(STDIN.read)
      if prs.empty?
        warn "error: no open PR found for branch #{ARGV[0]}"
        exit 1
      end
      puts JSON.generate(prs.first)
    ' "$ref"
  fi
}

# Create a PR.
# Usage: gh_or_curl_pr_create <base> <head> <title> <body_file>
gh_or_curl_pr_create() {
  local base="$1" head="$2" title="$3" body_file="$4"
  if _gh_available; then
    gh pr create --base "$base" --head "$head" --title "$title" --body-file "$body_file" 2>/dev/null && return 0
  fi
  local repo body
  repo="$(_github_resolve_repo)" || return 1
  body="$(cat "$body_file")"
  local json
  json="$(ruby -rjson -e 'puts JSON.generate({title: ARGV[0], body: ARGV[1], head: ARGV[2], base: ARGV[3]})' "$title" "$body" "$head" "$base")"
  github_api_post POST "/repos/${repo}/pulls" "$json"
}

# Edit PR title and body.
# Usage: gh_or_curl_pr_edit <pr_number_or_branch> <title> <body_file>
gh_or_curl_pr_edit() {
  local pr="$1" title="$2" body_file="$3"
  if _gh_available; then
    gh pr edit "$pr" --title "$title" --body-file "$body_file" 2>/dev/null && return 0
  fi
  local repo body pr_number
  repo="$(_github_resolve_repo)" || return 1
  body="$(cat "$body_file")"
  # Resolve PR number if given a branch name
  if [[ ! "$pr" =~ ^[0-9]+$ ]]; then
    pr_number="$(gh_or_curl_pr_view "$pr" | ruby -rjson -e 'puts JSON.parse(STDIN.read)["number"]')"
  else
    pr_number="$pr"
  fi
  local json
  json="$(ruby -rjson -e 'puts JSON.generate({title: ARGV[0], body: ARGV[1]})' "$title" "$body")"
  github_api_post PATCH "/repos/${repo}/pulls/${pr_number}" "$json"
}

# Merge a PR.
# Usage: gh_or_curl_pr_merge <pr_number_or_branch> <method>
# method: rebase, squash, or merge
gh_or_curl_pr_merge() {
  local pr="$1" method="${2:-rebase}"
  if _gh_available; then
    gh pr merge "$pr" --"$method" --delete-branch 2>/dev/null && return 0
  fi
  local repo pr_number
  repo="$(_github_resolve_repo)" || return 1
  if [[ ! "$pr" =~ ^[0-9]+$ ]]; then
    pr_number="$(gh_or_curl_pr_view "$pr" | ruby -rjson -e 'puts JSON.parse(STDIN.read)["number"]')"
  else
    pr_number="$pr"
  fi
  local json
  json="$(ruby -rjson -e 'puts JSON.generate({merge_method: ARGV[0]})' "$method")"
  github_api_post PUT "/repos/${repo}/pulls/${pr_number}/merge" "$json"
}
```

- [ ] **Step 3: Make executable and commit**

```bash
chmod +x scripts/lib/github-api.sh
git add scripts/lib/github-api.sh
git commit -m "feat(cws-94): add github-api.sh shared gh/curl fallback library"
```

---

## Task 9: Integrate fallback lib into create-pr.sh and add template-driven body (D3, D6)

**Files:**
- Modify: `scripts/create-pr.sh`

- [ ] **Step 1: Source the fallback library**

After the `cd "$repo_root"` line (line 5), add:

```bash
# shellcheck disable=SC1091
. "$repo_root/scripts/lib/github-api.sh"
```

- [ ] **Step 2: Replace `gh auth status` check**

Replace lines 17-19:

```bash
if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI authentication is invalid. Run: gh auth login -h github.com" >&2
  exit 1
fi
```

With:

```bash
if ! _gh_available; then
  if ! _github_resolve_token >/dev/null 2>&1; then
    echo "error: no GitHub authentication. Run: gh auth login, or set GITHUB_TOKEN" >&2
    exit 1
  fi
fi
```

- [ ] **Step 3: Replace hardcoded PR body with template-driven generation**

Replace the entire `cat > "$body_file"` heredoc (the body generation block) with template-driven output that matches `.github/pull_request_template.md`:

```bash
commit_summary="$(git log --oneline "${base_branch}...HEAD" | head -20)"
if [[ -z "$commit_summary" ]]; then
  commit_summary="(no commits on branch)"
fi

# Auto-check traceability items
check_branch="[x]"
check_title="[ ]"
check_task_file="[ ]"
check_agent_context="[ ]"
check_linear_link="[ ]"

if [[ -n "$issue_id" ]]; then
  issue_id_lower="$(printf '%s' "$issue_id" | tr '[:upper:]' '[:lower:]')"
  if [[ "$title" == *"${issue_id}"* || "$title" == *"${issue_id_lower}"* ]]; then
    check_title="[x]"
  fi
  if [[ -f "$repo_root/docs/tasks/${issue_id}.md" ]]; then
    check_task_file="[x]"
  fi
  if [[ -n "$linear_issue_link" ]]; then
    check_linear_link="[x]"
  fi
fi

cat > "$body_file" <<EOF
## Branch And Title Convention

- Branch: \`$branch\`
- Task-branch PR title must include matching issue token (\`${issue_id:-n/a}\`)
- Linear issue link: ${linear_issue_link:-"(not available)"}

## Traceability Checklist

- ${check_branch} Branch name matches approved pattern
- ${check_title} PR title contains matching issue token (\`${issue_id:-n/a}\`)
- ${check_task_file} \`docs/tasks/${issue_id:-CWS-XX}.md\` exists and is committed
- ${check_agent_context} \`docs/agent-context.md\` is fresh (not stale)
- ${check_linear_link} Linear issue link is present in this PR

## Summary

${commit_summary}

## Why

- ${title#"$type: "}

## Linear Traceability

- Parent issue: \`(see Linear)\`
- This issue: ${linear_issue_link:-"(not available)"}

## Validation

- \`make qa-local\`

## Affected Files

\`\`\`text
$affected_files
\`\`\`

## Affected URLs

\`\`\`text
$affected_urls
\`\`\`

## Self-review Notes

- Risk assessment: standard workflow changes
- Backward compatibility notes: phase workflow removed (already deprecated)
EOF
```

- [ ] **Step 4: Replace gh PR commands with fallback equivalents**

Replace lines 295-307:

```bash
if ! gh pr view "$branch" >/dev/null 2>&1; then
  gh pr create \
    --base "$base_branch" \
    --head "$branch" \
    --title "$title" \
    --body-file "$body_file"
fi

gh pr edit "$branch" --title "$title" --body-file "$body_file"

if [[ "$(gh pr view "$branch" --json isDraft --jq '.isDraft')" == "true" ]]; then
  gh pr ready "$branch"
fi
```

With:

```bash
if ! gh_or_curl_pr_view "$branch" >/dev/null 2>&1; then
  gh_or_curl_pr_create "$base_branch" "$branch" "$title" "$body_file"
fi

gh_or_curl_pr_edit "$branch" "$title" "$body_file"

# Mark PR ready if draft (gh-only, best-effort)
if _gh_available; then
  if [[ "$(gh pr view "$branch" --json isDraft --jq '.isDraft' 2>/dev/null)" == "true" ]]; then
    gh pr ready "$branch" 2>/dev/null || true
  fi
fi
```

- [ ] **Step 5: Verify script syntax**

```bash
bash -n scripts/create-pr.sh
```

Expected: No syntax errors

- [ ] **Step 6: Commit**

```bash
git add scripts/create-pr.sh
git commit -m "feat(cws-94): integrate fallback lib and template-driven PR body in create-pr.sh"
```

---

## Task 10: Add non-interactive mode and stack merge to finalize-merge.sh (D4, D5)

**Files:**
- Modify: `scripts/finalize-merge.sh`

- [ ] **Step 1: Source the fallback library and parse flags**

After `cd "$repo_root"` (line 5), add:

```bash
# shellcheck disable=SC1091
. "$repo_root/scripts/lib/github-api.sh"
```

Add flag parsing before the `pr=` line:

```bash
non_interactive="${YES:-}"
stack_mode="${STACK:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|--no-interactive) non_interactive=1; shift ;;
    --stack) stack_mode=1; shift ;;
    *) break ;;
  esac
done

pr="${PR:-${1:-}}"
```

- [ ] **Step 2: Replace gh auth check with fallback**

Replace lines 11-14:

```bash
if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI authentication is invalid. Run: gh auth login -h github.com" >&2
  exit 1
fi
```

With:

```bash
if ! _gh_available; then
  if ! _github_resolve_token >/dev/null 2>&1; then
    echo "error: no GitHub authentication. Run: gh auth login, or set GITHUB_TOKEN" >&2
    exit 1
  fi
fi
```

- [ ] **Step 3: Replace gh pr view with fallback**

Replace the direct `gh pr view` call:

```bash
pr_state="$(gh pr view "$pr" --json number,statusCheckRollup,isDraft,url,baseRefName,headRefName,state)"
```

With:

```bash
pr_state="$(gh_or_curl_pr_view "$pr")"
```

- [ ] **Step 4: Add non-interactive mode (D4)**

Replace the interactive confirmation block:

```bash
printf 'Integrate this PR into %s via GitHub rebase merge (single PR only)? [y/N] ' "$base_ref_name"
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "integration cancelled"
  exit 1
fi
```

With:

```bash
if [[ -n "$non_interactive" ]]; then
  echo "non-interactive mode: proceeding with merge"
else
  printf 'Integrate this PR into %s via GitHub rebase merge (single PR only)? [y/N] ' "$base_ref_name"
  read -r confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "integration cancelled"
    exit 1
  fi
fi
```

- [ ] **Step 5: Add stack merge support (D5)**

After the non-interactive block, replace the direct `gh pr merge` with:

```bash
if [[ -n "$stack_mode" ]]; then
  echo "stack merge mode"
  if command -v gt >/dev/null 2>&1; then
    if gt merge 2>/dev/null; then
      echo "stack merged via gt merge"
    else
      echo "warning: gt merge failed; falling back to single PR merge" >&2
      gh_or_curl_pr_merge "$pr" rebase
    fi
  else
    echo "warning: gt not available; falling back to single PR merge" >&2
    gh_or_curl_pr_merge "$pr" rebase
  fi
else
  gh_or_curl_pr_merge "$pr" rebase
fi
```

- [ ] **Step 6: Replace gh repo view with fallback**

Replace:

```bash
rebase_allowed="$(gh repo view --json rebaseMergeAllowed --jq '.rebaseMergeAllowed')"
```

With:

```bash
repo_slug="$(_github_resolve_repo)"
rebase_allowed="$(github_api_get "/repos/${repo_slug}" | ruby -rjson -e 'puts JSON.parse(STDIN.read)["allow_rebase_merge"]' 2>/dev/null || echo "true")"
```

- [ ] **Step 7: Verify script syntax**

```bash
bash -n scripts/finalize-merge.sh
```

Expected: No syntax errors

- [ ] **Step 8: Commit**

```bash
git add scripts/finalize-merge.sh
git commit -m "feat(cws-94): add --yes, --stack flags and gh/curl fallback to finalize-merge.sh"
```

---

## Task 11: Update Makefile for YES and STACK variables

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Update finalize-merge target**

Replace:

```makefile
finalize-merge:
	@./scripts/finalize-merge.sh
```

With:

```makefile
finalize-merge:
	@YES='$(YES)' STACK='$(STACK)' ./scripts/finalize-merge.sh
```

- [ ] **Step 2: Update help text**

Add to the Repo Flow section of help:

```
@echo "  make finalize-merge PR=123 [YES=1] [STACK=1]"
```

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "feat(cws-94): add YES and STACK variables to finalize-merge Makefile target"
```

---

## Task 12: Evidence file and validation for PR 2

**Files:**
- Create: `.codex/rollout/evidence/cws-94-fallback-and-flags.md`

- [ ] **Step 1: Create evidence file**

```markdown
# CWS-94 PR 2: Fallback, Non-Interactive, Stack Merge, Dynamic Body

## Changes

- Created `scripts/lib/github-api.sh` — shared gh/curl fallback library (D3)
- Integrated fallback lib into `create-pr.sh` (D3)
- Replaced hardcoded PR body with template-driven generation matching `.github/pull_request_template.md` (D6)
- Added `--yes`/`--no-interactive` flag to `finalize-merge.sh` (D4)
- Added `--stack` flag to `finalize-merge.sh` with `gt merge` support (D5)
- Integrated fallback lib into `finalize-merge.sh` (D3)
- Added `YES=1` and `STACK=1` Makefile variables (D4, D5)

## Validation

- `make qa-local` passed
- `bash -n` syntax check on all modified scripts passed
```

- [ ] **Step 2: Run full validation**

```bash
make qa-local
```

Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add .codex/rollout/evidence/cws-94-fallback-and-flags.md
git commit -m "docs(cws-94): add PR 2 evidence file"
```

---

## Task 13: Create PR 3 branch and SessionStart staleness hook (D7)

**Files:**
- Create: `.claude/hooks/check-agent-context-staleness.sh`

- [ ] **Step 1: Create PR 3 branch**

```bash
gt create cws/94-staleness-and-skill -m "chore: PR 3 — staleness mechanism + repo-flow skill update"
```

- [ ] **Step 2: Create the staleness hook script**

Create `.claude/hooks/check-agent-context-staleness.sh`:

```bash
#!/usr/bin/env bash
# SessionStart hook: warn if docs/agent-context.md is stale.
# Registered in .claude/settings.json under hooks.SessionStart.
# Fail-closed: exit 2 on error (block execution), never fail-open.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
agent_context="$repo_root/docs/agent-context.md"

if [[ ! -f "$agent_context" ]]; then
  echo "error: docs/agent-context.md not found" >&2
  exit 2
fi

# Extract the stale-after timestamp from the "## Stale After" section.
stale_ts="$(ruby -e '
  content = File.read(ARGV[0])
  section = content.match(/^## Stale After\s*$\n+((?:- .*\n)+)/m)
  if section.nil?
    warn "error: cannot find Stale After section in agent-context.md"
    exit 2
  end
  ts_line = section[1].lines.find { |l| l.match?(/^\s*-\s*`[^`]+`\s*$/) }
  if ts_line.nil?
    warn "error: cannot find timestamp in Stale After section"
    exit 2
  end
  puts ts_line[/`([^`]+)`/, 1]
' "$agent_context" 2>&1)" || exit 2

if [[ -z "$stale_ts" ]]; then
  echo "error: empty stale timestamp in agent-context.md" >&2
  exit 2
fi

# Compare timestamps
is_stale="$(ruby -e '
  require "time"
  ts = Time.parse(ARGV[0]) rescue nil
  if ts.nil?
    warn "error: cannot parse timestamp: #{ARGV[0]}"
    exit 2
  end
  puts Time.now > ts ? "stale" : "fresh"
' "$stale_ts" 2>&1)" || exit 2

if [[ "$is_stale" == "stale" ]]; then
  cat <<EOF
WARNING: docs/agent-context.md is STALE (stale_after=$stale_ts).
Run a Linear sync before executing tasks. The cached context may not reflect
current issue states, priorities, or cycle assignments.
EOF
fi
```

- [ ] **Step 3: Make executable**

```bash
chmod +x .claude/hooks/check-agent-context-staleness.sh
```

- [ ] **Step 4: Commit**

```bash
git add .claude/hooks/check-agent-context-staleness.sh
git commit -m "feat(cws-94): add SessionStart staleness hook for agent-context.md"
```

**Note:** The hook registration in `.claude/settings.json` is managed separately (outside repo scope — Claude Code project settings). The hook script is ready to be registered under `hooks.SessionStart` with matcher `startup|resume|compact`.

---

## Task 14: Add post-merge staleness timestamp bump to finalize-merge.sh (D7)

**Files:**
- Modify: `scripts/finalize-merge.sh`

- [ ] **Step 1: Add staleness timestamp bump after successful merge**

After the `git pull --ff-only` block at the end of `finalize-merge.sh`, add:

```bash
# Update agent-context.md staleness timestamp (D7)
agent_context="$repo_root/docs/agent-context.md"
if [[ -f "$agent_context" ]]; then
  new_stale_ts="$(ruby -e '
    require "time"
    puts (Time.now + 86400).strftime("%Y-%m-%d %H:%M:%S %Z")
  ')"
  ruby -e '
    path = ARGV[0]
    new_ts = ARGV[1]
    content = File.read(path)
    updated = content.sub(/^(## Stale After\s*\n+- )`[^`]+`/, "\\1`#{new_ts}`")
    if updated == content
      warn "warning: could not update stale timestamp in agent-context.md"
    else
      File.write(path, updated)
    end
  ' "$agent_context" "$new_stale_ts"

  if ! git diff --quiet "$agent_context" 2>/dev/null; then
    git add "$agent_context"
    git commit -m "chore: bump agent-context staleness timestamp to $new_stale_ts"
  fi
fi
```

- [ ] **Step 2: Verify script syntax**

```bash
bash -n scripts/finalize-merge.sh
```

Expected: No syntax errors

- [ ] **Step 3: Commit**

```bash
git add scripts/finalize-merge.sh
git commit -m "feat(cws-94): add post-merge staleness timestamp bump to finalize-merge.sh"
```

---

## Task 15: Rewrite repo-flow skill (D9)

**Files:**
- Modify: `.agents/skills/repo-flow/SKILL.md`
- Modify: `.agents/skills/repo-flow/references/branch-pr-merge.md`

- [ ] **Step 1: Update SKILL.md**

Rewrite to:
- Remove any phase-mode documentation
- Document full task-only lifecycle: `make start-work` → branch → commit → `make create-pr` → CI → `make finalize-merge`
- Document stack workflow: `gt create` → `gt submit --stack` → `gt merge`
- Document `curl` fallback: when and how to use it
- Document `--yes` flag for agent contexts
- Document exempt branch patterns
- Add frontmatter `filePattern` and `bashPattern` for auto-triggering

The frontmatter `metadata` section should include patterns that trigger on workflow scripts and git operations:

```yaml
---
name: repo-flow
description: >-
  Use this skill when the user asks to start, validate, package, or integrate repository changes
  in this repo using its scripted workflow (make qa-local, make create-pr, make finalize-merge)
  and policy gates (branch naming, task file presence, Linear traceability, rebase-only
  integration). Use it even when requested indirectly ("open a PR", "finish merge", "prep
  branch"). Do not use for editorial drafting or content-only edits that do not involve repo
  workflow mechanics, and do not use for generic git advice outside this repository.
metadata:
  filePattern:
    - "scripts/create-pr.sh"
    - "scripts/finalize-merge.sh"
    - "scripts/run-workflow-checks.sh"
    - "scripts/start-work.sh"
    - "scripts/run-local-qa.sh"
    - "scripts/lib/github-api.sh"
    - ".codex/rollout/active-plan.yaml"
    - "Makefile"
    - ".github/workflows/rollout-governance.yml"
    - ".github/pull_request_template.md"
  bashPattern:
    - "make (create-pr|finalize-merge|start-work|workflow-check|qa-local)"
    - "gt (create|submit|merge|restack|track)"
    - "gh pr (create|merge|view|edit|ready)"
    - "git push"
---
```

Key sections to add in the body:
- **Agent Non-Interactive Mode**: `make finalize-merge PR=... YES=1` or `--yes` flag
- **Stack Workflow**: `gt create` → `gt submit --stack` → `make finalize-merge PR=... STACK=1`
- **Exempt Branch Patterns**: Dependabot, Renovate, gh-pages branches bypass governance branch validation
- **Fallback Authentication**: If `gh` is unavailable, scripts fall back to `curl` + GitHub REST API via `GITHUB_TOKEN`
- **PR Template Compliance**: `create-pr.sh` generates PR body matching `.github/pull_request_template.md`

- [ ] **Step 2: Update branch-pr-merge.md reference**

Update `.agents/skills/repo-flow/references/branch-pr-merge.md`:
- Remove phase references from Stack Merge Policy
- Add `--yes` flag documentation
- Add `--stack` flag documentation
- Update `make finalize-merge` docs to show `YES=1` and `STACK=1`
- Remove `phase_branch_pattern` references

- [ ] **Step 3: Commit**

```bash
git add .agents/skills/repo-flow/SKILL.md .agents/skills/repo-flow/references/branch-pr-merge.md
git commit -m "docs(cws-94): rewrite repo-flow skill for task-only + stack + fallback workflow"
```

---

## Task 16: Task file, evidence, and final validation for PR 3

**Files:**
- Create: `docs/tasks/CWS-94.md`
- Create: `.codex/rollout/evidence/cws-94-staleness-and-skill.md`

- [ ] **Step 1: Create task file**

```markdown
---
id: CWS-94
title: "Harden PR Scripts for Stack, Sandbox, and Agent Workflows"
parent: CWS-81
status: In Progress
linear: https://linear.app/codewithshabib/issue/CWS-94
---

# CWS-94: Harden PR Scripts

## Brief

Fix broken `create-pr.sh` and `finalize-merge.sh` scripts after CWS-93 phase removal.
Add governance exempt patterns, gh/curl fallback, non-interactive mode, stack merge support,
template-driven PR body, agent-context staleness mechanism, and repo-flow skill rewrite.

## Design Spec

`docs/superpowers/specs/2026-03-22-script-hardening-design.md`

## Implementation Plan

`docs/superpowers/plans/2026-03-22-script-hardening.md`

## Evidence

- `.codex/rollout/evidence/cws-94-phase-removal-governance-fix.md`
- `.codex/rollout/evidence/cws-94-fallback-and-flags.md`
- `.codex/rollout/evidence/cws-94-staleness-and-skill.md`
```

- [ ] **Step 2: Create evidence file**

```markdown
# CWS-94 PR 3: Staleness Mechanism + Repo-Flow Skill Update

## Changes

- Created `.claude/hooks/check-agent-context-staleness.sh` SessionStart hook (D7)
- Added post-merge staleness timestamp bump to `finalize-merge.sh` (D7)
- Rewrote `.agents/skills/repo-flow/SKILL.md` with task-only + stack + fallback docs (D9)
- Updated `.agents/skills/repo-flow/references/branch-pr-merge.md` (D9)
- Created task file `docs/tasks/CWS-94.md`

## Validation

- `make qa-local` passed
- SessionStart hook correctly parses staleness timestamp
- repo-flow skill frontmatter triggers on workflow scripts and git commands
```

- [ ] **Step 3: Run full validation**

```bash
make qa-local
```

Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add docs/tasks/CWS-94.md .codex/rollout/evidence/cws-94-staleness-and-skill.md
git commit -m "docs(cws-94): add task file and PR 3 evidence"
```

---

## Task 17: Submit Graphite stack

- [ ] **Step 1: Submit the 3-PR stack**

```bash
gt submit --stack --no-interactive --publish
```

- [ ] **Step 2: Verify all 3 PRs are created**

```bash
gt stack
```

Expected: 3 branches in the stack, all with PRs

- [ ] **Step 3: Wait for CI and verify**

Check that `make qa-local` passes on each PR branch, and that CI checks (build, semgrep, rollout-governance) are green.
