#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

pr="${PR:-${1:-}}"

"$repo_root/.agents/skills/repo-flow/scripts/ensure-clean-tree.sh"

if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI authentication is invalid. Run: gh auth login -h github.com" >&2
  exit 1
fi

if [[ -z "$pr" ]]; then
  branch="$(git branch --show-current)"
  pr="$branch"
fi

"$repo_root/scripts/run-local-qa.sh"

plan_info="$(
  ruby - "$repo_root" <<'RUBY'
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
branch_pattern = data["branch_pattern"].to_s.strip
required_checks = data["required_checks"].is_a?(Array) ? data["required_checks"] : []

if plan_id.empty? || base_branch.empty? || branch_pattern.empty?
  warn "error: active rollout plan is missing plan_id/base_branch/branch_pattern"
  exit 1
end

if required_checks.empty?
  warn "error: active rollout plan missing required_checks"
  exit 1
end

puts "#{plan_id}\t#{base_branch}\t#{branch_pattern}\t#{required_checks.join(',')}"
RUBY
)"

plan_id="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $1}')"
base_branch="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $2}')"
branch_pattern="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $3}')"
required_checks_csv="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $4}')"

pr_state="$(gh pr view "$pr" --json number,statusCheckRollup,isDraft,url,baseRefName,headRefName,state)"

validation="$(
  ruby - "$pr_state" "$base_branch" "$branch_pattern" "$required_checks_csv" <<'RUBY'
require "json"

pr = JSON.parse(ARGV.fetch(0))
base_branch = ARGV.fetch(1)
branch_pattern = Regexp.new(ARGV.fetch(2))
required_checks = ARGV.fetch(3).split(",").map(&:strip).reject(&:empty?)

errors = []
errors << "PR is still a draft" if pr["isDraft"] == true
errors << "PR base #{pr["baseRefName"].inspect} must be #{base_branch.inspect}" if pr["baseRefName"] != base_branch

head = pr["headRefName"].to_s
match = branch_pattern.match(head)
if match.nil?
  errors << "PR head branch #{head.inspect} does not match required phase pattern"
else
  phase = match[1].to_i
  errors << "phase extracted from branch must be >= 1" if phase <= 0
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

phase = match[1].to_i
puts [pr["url"], phase, head].join("\t")
RUBY
)"

pr_url="$(printf '%s' "$validation" | awk -F '\t' 'NR==1 {print $1}')"
phase="$(printf '%s' "$validation" | awk -F '\t' 'NR==1 {print $2}')"
head_branch="$(printf '%s' "$validation" | awk -F '\t' 'NR==1 {print $3}')"

if [[ "$phase" -gt 1 ]]; then
  pr_index="$(gh pr list --state all --base "$base_branch" --limit 200 --json number,state,mergedAt,headRefName)"
  ruby - "$pr_index" "$branch_pattern" "$phase" <<'RUBY'
require "json"

prs = JSON.parse(ARGV.fetch(0))
branch_pattern = Regexp.new(ARGV.fetch(1))
phase = ARGV.fetch(2).to_i

by_phase = Hash.new { |hash, key| hash[key] = [] }
prs.each do |pr|
  match = branch_pattern.match(pr["headRefName"].to_s)
  next if match.nil?

  by_phase[match[1].to_i] << pr
end

errors = []
(1...phase).each do |required_phase|
  entries = by_phase[required_phase]
  merged = entries.any? { |entry| entry["state"] == "MERGED" || !entry["mergedAt"].nil? }
  open = entries.any? { |entry| entry["state"] == "OPEN" }
  errors << "phase #{required_phase} is not merged yet" unless merged
  errors << "phase #{required_phase} still has an open PR" if open
end

if errors.any?
  errors.each { |error| warn "error: #{error}" }
  exit 1
end
RUBY
fi

rebase_allowed="$(gh repo view --json rebaseMergeAllowed --jq '.rebaseMergeAllowed')"
if [[ "$rebase_allowed" != "true" ]]; then
  echo "error: repository is not configured for rebase merges; refusing to pick a different strategy silently" >&2
  exit 1
fi

checks_lines="$(
  ruby - "$pr_state" <<'RUBY'
require "json"

state = JSON.parse(ARGV.fetch(0))
checks = state["statusCheckRollup"] || []
checks.each do |entry|
  name = entry["name"] || entry["context"] || "unnamed-check"
  conclusion = entry["conclusion"] || entry["state"]
  puts "#{name}: #{conclusion}"
end
RUBY
)"

if [[ -n "$checks_lines" ]]; then
  echo "reported CI checks:"
  printf '%s\n' "$checks_lines"
else
  echo "warning: no CI status checks reported for this PR; required checks may not be configured in rulesets."
fi

cat <<EOF
Self-review checklist for $pr_url
- plan: $plan_id
- phase: $phase
- head branch: $head_branch
- full local QA gate passed (\`make qa-local\`)
- diff reviewed
- no private drafts or secrets included
- PR title/body look correct
- changed files and URLs are expected
EOF
printf 'Integrate this PR to %s with rebase? [y/N] ' "$base_branch"
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "integration cancelled"
  exit 1
fi

gh pr merge "$pr" --rebase --delete-branch

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
