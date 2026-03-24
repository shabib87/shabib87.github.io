#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

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

"$repo_root/.agents/skills/repo-flow/scripts/ensure-clean-tree.sh"

if ! gh auth status >/dev/null 2>&1; then
  echo "error: no GitHub authentication. Run: gh auth login" >&2
  exit 1
fi

if [[ -z "$pr" ]]; then
  branch="$(git branch --show-current)"
  pr="$branch"
fi

"$repo_root/scripts/run-local-qa.sh"

_plan_ruby="$(mktemp)"
cat > "$_plan_ruby" <<'RUBY'
require "date"
require "yaml"

repo_root = ARGV.fetch(0)
active_plan = File.join(repo_root, ".codex", "rollout", "active-plan.yaml")
unless File.file?(active_plan)
  warn "error: missing active rollout plan at .codex/rollout/active-plan.yaml"
  exit 1
end

data = YAML.safe_load(File.read(active_plan), permitted_classes: [Date, Time], aliases: false) || {}
plan_id = data["plan_id"].to_s.strip
base_branch = data["base_branch"].to_s.strip
task_branch_pattern = data["task_branch_pattern"].to_s.strip
required_checks = data["required_checks"].is_a?(Array) ? data["required_checks"] : []

if plan_id.empty? || base_branch.empty? || task_branch_pattern.empty?
  warn "error: active rollout plan is missing plan_id/base_branch/task_branch_pattern"
  exit 1
end

if required_checks.empty?
  warn "error: active rollout plan missing required_checks"
  exit 1
end

puts "#{plan_id}\t#{base_branch}\t#{task_branch_pattern}\t#{required_checks.join(',')}"
RUBY
plan_info="$(ruby "$_plan_ruby" "$repo_root")"
rm -f "$_plan_ruby"

plan_id="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $1}')"
base_branch="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $2}')"
task_branch_pattern="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $3}')"
required_checks_csv="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $4}')"

pr_state="$(gh pr view "$pr" --json number,state,url,headRefName,baseRefName,isDraft,statusCheckRollup,mergedAt)"

_validate_ruby="$(mktemp)"
cat > "$_validate_ruby" <<'RUBY'
require "json"

pr = JSON.parse(ARGV.fetch(0))
base_branch = ARGV.fetch(1)
task_branch_pattern = Regexp.new(ARGV.fetch(2))
required_checks = ARGV.fetch(3).split(",").map(&:strip).reject(&:empty?)

errors = []
errors << "PR is still a draft" if pr["isDraft"] == true
base_ref = pr["baseRefName"].to_s
base_is_trunk = base_ref == base_branch
base_is_stack_branch = task_branch_pattern.match?(base_ref)
unless base_is_trunk || base_is_stack_branch
  errors << "PR base #{base_ref.inspect} must be #{base_branch.inspect} or a rollout stack branch"
end

head = pr["headRefName"].to_s
unless task_branch_pattern.match(head)
  errors << "PR head branch #{head.inspect} does not match task branch pattern"
end

checks = pr["statusCheckRollup"] || []
check_map = {}
checks.each do |entry|
  name = entry["name"] || entry["context"]
  next if name.to_s.strip.empty?

  check_map[name] = entry["conclusion"] || entry["state"]
end

missing_required = required_checks.reject { |name| check_map.key?(name) }
failed_required = required_checks.select do |name|
  value = check_map[name]
  !["SUCCESS", "SKIPPED", "SUCCESSFUL"].include?(value)
end

errors << "missing required checks: #{missing_required.join(', ')}" if missing_required.any?
errors << "required checks not successful: #{failed_required.join(', ')}" if failed_required.any?

bad = check_map.any? do |_name, value|
  !["SUCCESS", "SKIPPED", "SUCCESSFUL", nil].include?(value)
end
errors << "one or more reported checks are failing" if bad

if errors.any?
  errors.each { |error| warn "error: #{error}" }
  exit 1
end

puts [pr["url"], head, base_ref].join("\t")
RUBY
validation="$(ruby "$_validate_ruby" "$pr_state" "$base_branch" "$task_branch_pattern" "$required_checks_csv")"
rm -f "$_validate_ruby"

pr_url="$(printf '%s' "$validation" | awk -F '\t' 'NR==1 {print $1}')"
head_branch="$(printf '%s' "$validation" | awk -F '\t' 'NR==1 {print $2}')"
base_ref_name="$(printf '%s' "$validation" | awk -F '\t' 'NR==1 {print $3}')"
is_stack_base="false"
if [[ "$base_ref_name" != "$base_branch" ]]; then
  is_stack_base="true"
fi

rebase_allowed="$(gh api 'repos/{owner}/{repo}' --jq '.allow_rebase_merge' 2>/dev/null || echo "true")"
if [[ "$rebase_allowed" != "true" ]]; then
  echo "error: repository is not configured for rebase merges; refusing to pick a different strategy silently" >&2
  exit 1
fi

_checks_ruby="$(mktemp)"
cat > "$_checks_ruby" <<'RUBY'
require "json"

state = JSON.parse(ARGV.fetch(0))
checks = state["statusCheckRollup"] || []
checks.each do |entry|
  name = entry["name"] || entry["context"] || "unnamed-check"
  conclusion = entry["conclusion"] || entry["state"]
  puts "#{name}: #{conclusion}"
end
RUBY
checks_lines="$(ruby "$_checks_ruby" "$pr_state")"
rm -f "$_checks_ruby"

if [[ -n "$checks_lines" ]]; then
  echo "reported CI checks:"
  printf '%s\n' "$checks_lines"
else
  echo "warning: no CI status checks reported for this PR; required checks may not be configured in rulesets."
fi

cat <<EOF
Self-review checklist for $pr_url
- plan: $plan_id
- head branch: $head_branch
- base branch: $base_ref_name
- merge engine: gh (single PR rebase merge)
- full local QA gate passed (\`make qa-local\`)
- diff reviewed
- no private drafts or secrets included
- PR title/body look correct
- changed files and URLs are expected
EOF
if [[ "$is_stack_base" == "true" ]]; then
  cat <<EOF
stacked PR note:
- this script merges only the current PR into its base branch ($base_ref_name).
- to merge the full stack, use Graphite web "Merge stack" or run: gt merge
EOF
fi

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

# If agent-context.md is stale, bump timestamp on the feature branch before
# merging so the bump lands on the base branch through the normal PR flow.
# This respects branch protection — no direct push to main.
agent_context="$repo_root/docs/agent-context.md"
if [[ -f "$agent_context" ]]; then
  # shellcheck disable=SC2016
  is_stale="$(ruby -e '
    require "time"
    path = ARGV.fetch(0)
    content = File.read(path)
    section = content.match(/^## Stale After\s*\n+((?:- .*\n)+)/)
    exit 0 unless section
    ts_line = section[1].lines.find { |l| l.match?(/^\s*-\s*`[^`]+`\s*$/) }
    exit 0 unless ts_line
    ts = ts_line[/`([^`]+)`/, 1]
    stale_at = Time.parse(ts) rescue nil
    exit 0 unless stale_at
    puts "stale" if Time.now > stale_at
  ' "$agent_context" 2>/dev/null || true)"

  if [[ "$is_stale" == "stale" ]]; then
    echo "agent-context.md is stale; bumping timestamp on $head_branch before merge"

    current_branch="$(git branch --show-current)"
    if [[ "$current_branch" != "$head_branch" ]]; then
      git checkout "$head_branch"
    fi

    # shellcheck disable=SC2016
    new_stale_ts="$(ruby -e '
      require "time"
      puts (Time.now + 86400).strftime("%Y-%m-%d %H:%M:%S %Z")
    ')"
    # shellcheck disable=SC2016
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

      push_remote="origin"
      if push_upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"; then
        push_remote="${push_upstream%%/*}"
      fi
      git push "$push_remote" "$head_branch"

      echo "waiting for CI checks after staleness bump..."
      if ! gh pr checks "$pr" --watch --fail-level error; then
        echo "error: CI checks failed after staleness bump; aborting merge" >&2
        exit 1
      fi
    fi
  fi
fi

if [[ -n "$stack_mode" ]]; then
  echo "stack merge mode"
  if command -v gt >/dev/null 2>&1; then
    if gt merge 2>/dev/null; then
      echo "stack merged via gt merge"
    else
      echo "warning: gt merge failed; falling back to single PR merge" >&2
      gh pr merge "$pr" --rebase --delete-branch
    fi
  else
    echo "warning: gt not available; falling back to single PR merge" >&2
    gh pr merge "$pr" --rebase --delete-branch
  fi
else
  gh pr merge "$pr" --rebase --delete-branch
fi

main_remote="origin"
main_remote_branch="$base_branch"
if upstream_ref="$(git rev-parse --abbrev-ref --symbolic-full-name "${base_branch}@{upstream}" 2>/dev/null)"; then
  main_remote="${upstream_ref%%/*}"
  main_remote_branch="${upstream_ref#*/}"
fi

if ! git remote get-url "$main_remote" >/dev/null 2>&1; then
  echo "error: remote $main_remote is not configured for local $base_branch" >&2
  exit 1
fi

git checkout "$base_branch"
git pull --ff-only "$main_remote" "$main_remote_branch"
