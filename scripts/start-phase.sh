#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plan="${PLAN:-${1:-}}"
phase="${PHASE:-${2:-}}"
topic="${TOPIC:-${3:-}}"
type="${TYPE:-${4:-chore}}"

if [[ -z "$phase" ]]; then
  echo "error: provide PHASE or pass it as the second argument" >&2
  exit 1
fi

if [[ -z "$topic" ]]; then
  echo "error: provide TOPIC or pass it as the third argument" >&2
  exit 1
fi

if ! [[ "$phase" =~ ^[0-9]+$ ]] || [[ "$phase" -lt 1 ]]; then
  echo "error: PHASE must be a positive integer" >&2
  exit 1
fi

active_plan_path="$repo_root/.codex/rollout/active-plan.yaml"
if [[ ! -f "$active_plan_path" ]]; then
  echo "error: missing active rollout plan at .codex/rollout/active-plan.yaml" >&2
  exit 1
fi

active_info="$(
  ruby - "$active_plan_path" <<'RUBY'
require "yaml"

path = ARGV.fetch(0)
data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: false) || {}
plan_id = data["plan_id"].to_s.strip
base_branch = data["base_branch"].to_s.strip
branch_pattern = data["branch_pattern"].to_s.strip

if plan_id.empty? || base_branch.empty? || branch_pattern.empty?
  warn "error: active rollout plan missing required keys (plan_id/base_branch/branch_pattern)"
  exit 1
end

puts "#{plan_id}\t#{base_branch}\t#{branch_pattern}"
RUBY
)"

active_plan_id="$(printf '%s' "$active_info" | awk -F '\t' 'NR==1 {print $1}')"
base_branch="$(printf '%s' "$active_info" | awk -F '\t' 'NR==1 {print $2}')"
branch_pattern="$(printf '%s' "$active_info" | awk -F '\t' 'NR==1 {print $3}')"

if [[ -z "$plan" ]]; then
  plan="$active_plan_id"
elif [[ "$plan" != "$active_plan_id" ]]; then
  echo "error: PLAN=$plan does not match active plan_id=$active_plan_id" >&2
  exit 1
fi

manifest="$repo_root/.codex/rollout/plans/$plan/phase-$phase.txt"
if [[ ! -f "$manifest" ]]; then
  echo "error: missing phase manifest .codex/rollout/plans/$plan/phase-$phase.txt" >&2
  exit 1
fi

current_branch="$(git branch --show-current)"
if [[ "$current_branch" != "$base_branch" ]]; then
  echo "error: start-phase must run from $base_branch; current branch is $current_branch" >&2
  exit 1
fi

"$repo_root/.agents/skills/repo-flow/scripts/ensure-clean-tree.sh"

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

if ! git fetch "$main_remote" "$main_remote_branch" --quiet; then
  echo "error: failed to fetch $main_remote/$main_remote_branch before creating phase branch" >&2
  exit 1
fi

git rebase "$main_remote/$main_remote_branch" >/dev/null

inferred="$("$repo_root/.agents/skills/repo-flow/scripts/infer-branch-name.sh" "$type" "$topic")"
suffix="${inferred#codex/"${type}"-}"
branch_name="codex/phase-${phase}-${suffix}"

ruby - "$branch_name" "$branch_pattern" <<'RUBY'
branch_name = ARGV.fetch(0)
branch_pattern = ARGV.fetch(1)

match = Regexp.new(branch_pattern).match(branch_name)
if match.nil?
  warn "error: generated branch #{branch_name.inspect} does not match branch_pattern #{branch_pattern.inspect}"
  exit 1
end
RUBY

git checkout -b "$branch_name"

echo "created phase branch: $branch_name"
echo "plan: $plan"
echo "phase: $phase"
echo "next: implement phase scope, run make qa-local, then make create-pr TYPE=$type"
