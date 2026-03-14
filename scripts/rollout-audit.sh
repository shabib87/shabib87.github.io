#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

active_plan_path="$repo_root/.codex/rollout/active-plan.yaml"
if [[ ! -f "$active_plan_path" ]]; then
  echo "error: missing active rollout plan at .codex/rollout/active-plan.yaml" >&2
  exit 1
fi

plan_info="$(
  ruby - "$active_plan_path" <<'RUBY'
require "yaml"

path = ARGV.fetch(0)
data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: false) || {}
base_branch = data["base_branch"].to_s.strip
required_checks = data["required_checks"].is_a?(Array) ? data["required_checks"] : []

if base_branch.empty?
  warn "error: active rollout plan missing base_branch"
  exit 1
end

if required_checks.empty?
  warn "error: active rollout plan missing required_checks"
  exit 1
end

puts "#{base_branch}\t#{required_checks.join(',')}"
RUBY
)"

base_branch="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $1}')"
required_checks_csv="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $2}')"

if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI authentication is invalid. Run: gh auth login -h github.com" >&2
  exit 1
fi

repo_slug="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
ruleset_ids="$(gh api "repos/$repo_slug/rulesets" --jq '.[].id')"
if [[ -z "$ruleset_ids" ]]; then
  echo "error: no repository rulesets found for $repo_slug" >&2
  exit 1
fi

rulesets_json="[]"
while IFS= read -r ruleset_id; do
  [[ -n "$ruleset_id" ]] || continue
  ruleset_json="$(gh api "repos/$repo_slug/rulesets/$ruleset_id")"
  rulesets_json="$(
    ruby - "$rulesets_json" "$ruleset_json" <<'RUBY'
require "json"

all = JSON.parse(ARGV.fetch(0))
entry = JSON.parse(ARGV.fetch(1))
all << entry
puts all.to_json
RUBY
  )"
done <<< "$ruleset_ids"

ruby - "$rulesets_json" "$base_branch" "$required_checks_csv" <<'RUBY'
require "json"

rulesets = JSON.parse(ARGV.fetch(0))
base_branch = ARGV.fetch(1)
required = ARGV.fetch(2).split(",").map(&:strip).reject(&:empty?)

active_default = rulesets.find do |ruleset|
  next false unless ruleset["enforcement"] == "active"
  next false unless ruleset["target"] == "branch"

  include_refs = ruleset.dig("conditions", "ref_name", "include") || []
  include_refs.include?("~DEFAULT_BRANCH") || include_refs.include?(base_branch)
end

if active_default.nil?
  warn "error: no active default-branch ruleset found for #{base_branch}"
  exit 1
end

status_rule = (active_default["rules"] || []).find { |rule| rule["type"] == "required_status_checks" }
if status_rule.nil?
  warn "error: ruleset #{active_default["name"].inspect} missing required_status_checks rule"
  exit 1
end

configured = status_rule.dig("parameters", "required_status_checks") || []
contexts = configured.map do |entry|
  case entry
  when Hash
    entry["context"].to_s.strip
  else
    entry.to_s.strip
  end
end.reject(&:empty?)

missing = required - contexts
if missing.any?
  warn "error: ruleset missing required checks: #{missing.join(', ')}"
  warn "configured checks: #{contexts.sort.join(', ')}"
  exit 1
end

puts "rollout audit passed for ruleset=#{active_default["name"]} base_branch=#{base_branch}"
RUBY
