#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

type="${TYPE:-${1:-chore}}"
branch="$(git branch --show-current)"

if [[ "$branch" == "main" ]]; then
  echo "error: create-pr must be run from a feature branch" >&2
  exit 1
fi

"$repo_root/.agents/skills/repo-flow/scripts/ensure-clean-tree.sh"

if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI authentication is invalid. Run: gh auth login -h github.com" >&2
  exit 1
fi

"$repo_root/scripts/run-local-qa.sh"

plan_info="$(
  ruby - "$repo_root" "$branch" <<'RUBY'
require "date"
require "yaml"

repo_root = ARGV.fetch(0)
branch = ARGV.fetch(1)
active_plan = File.join(repo_root, ".codex", "rollout", "active-plan.yaml")
unless File.file?(active_plan)
  warn "error: missing active rollout plan at .codex/rollout/active-plan.yaml"
  exit 1
end

data = YAML.safe_load(File.read(active_plan), permitted_classes: [Date, Time], aliases: false) || {}
plan_id = data["plan_id"].to_s.strip
base_branch = data["base_branch"].to_s.strip
task_branch_pattern = data["task_branch_pattern"].to_s.strip
phase_branch_pattern = data["phase_branch_pattern"].to_s.strip
required_checks = data["required_checks"].is_a?(Array) ? data["required_checks"] : []

if plan_id.empty? || base_branch.empty? || task_branch_pattern.empty? || phase_branch_pattern.empty?
  warn "error: active rollout plan is missing plan_id/base_branch/task_branch_pattern/phase_branch_pattern"
  exit 1
end

branch_mode = nil
phase = nil

phase_match = Regexp.new(phase_branch_pattern).match(branch)
task_match = Regexp.new(task_branch_pattern).match(branch)
if !phase_match.nil?
  branch_mode = "phase"
  phase = phase_match[1].to_i
  if phase <= 0
    warn "error: extracted phase must be >= 1 for branch #{branch.inspect}"
    exit 1
  end
elsif !task_match.nil?
  branch_mode = "task"
else
  warn "error: branch #{branch.inspect} does not match task pattern #{task_branch_pattern.inspect} or phase pattern #{phase_branch_pattern.inspect}"
  exit 1
end

puts "#{plan_id}\t#{base_branch}\t#{branch_mode}\t#{phase}\t#{phase_branch_pattern}\t#{required_checks.join(',')}"
RUBY
)"

plan_id="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $1}')"
base_branch="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $2}')"
branch_mode="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $3}')"
phase="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $4}')"
phase_branch_pattern="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $5}')"
required_checks="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $6}')"

if [[ "$branch_mode" == "phase" && "$phase" -gt 1 ]]; then
  pr_index="$(gh pr list --state all --base "$base_branch" --limit 200 --json number,state,mergedAt,headRefName)"

  ruby - "$pr_index" "$phase_branch_pattern" "$phase" <<'RUBY'
require "json"

prs = JSON.parse(ARGV.fetch(0))
branch_pattern = Regexp.new(ARGV.fetch(1))
phase = ARGV.fetch(2).to_i

by_phase = Hash.new { |hash, key| hash[key] = [] }
prs.each do |pr|
  match = branch_pattern.match(pr["headRefName"].to_s)
  next if match.nil?

  phase_number = match[1].to_i
  by_phase[phase_number] << pr
end

errors = []
(1...phase).each do |required_phase|
  entries = by_phase[required_phase]
  merged = entries.any? { |pr| pr["state"] == "MERGED" || !pr["mergedAt"].nil? }
  open = entries.any? { |pr| pr["state"] == "OPEN" }
  errors << "phase #{required_phase} is not merged yet" unless merged
  errors << "phase #{required_phase} still has an open PR" if open
end

if errors.any?
  errors.each { |error| warn "error: #{error}" }
  exit 1
end
RUBY
fi

title_line="$("$repo_root/.agents/skills/repo-flow/scripts/infer-pr-metadata.sh" "$type")"
title="${title_line#TITLE=}"

affected_files="$(git diff --name-only "$base_branch"...HEAD | awk 'NF' || true)"
if [[ -z "$affected_files" ]]; then
  affected_files="(none identified)"
fi

affected_urls="$(ruby -e '
require "date"
require "yaml"
files = STDIN.read.split("\n")
urls = []
files.each do |file|
  next unless file.end_with?(".md")
  next unless File.file?(file)
  content = File.read(file)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  next unless match
  data = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
  permalink = data["permalink"].to_s.strip
  urls << permalink unless permalink.empty?
end
puts urls.uniq
' <<<"$affected_files")"
if [[ -z "$affected_urls" ]]; then
  affected_urls="(none identified)"
fi

body_file="$(mktemp)"
gt_log_file="$(mktemp)"
cleanup() {
  rm -f "$body_file" "$gt_log_file"
}
trap cleanup EXIT

cat > "$body_file" <<EOF
## Summary

- ${title#"$type: "}

## Why

- Standardize the change behind the repo's branch and PR workflow.

## Rollout Metadata

- plan_id: \`$plan_id\`
- branch_mode: \`$branch_mode\`
- phase: \`${phase:-n/a}\`
- required_checks: \`$required_checks\`

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

- Full local QA gate passed
- Diff reviewed
- No private drafts or secrets included
EOF

# Prefer Graphite for stack submission, then normalize metadata with gh.
if command -v gt >/dev/null 2>&1; then
  gt track --parent "$base_branch" >/dev/null 2>&1 || true
  if ! gt submit --stack --no-interactive >"$gt_log_file" 2>&1; then
    if grep -q "must restack before submitting this stack" "$gt_log_file"; then
      gt restack
      if ! gt submit --stack --no-interactive; then
        echo "warning: gt submit failed after restack; falling back to gh PR flow" >&2
      fi
    else
      echo "warning: gt submit failed; falling back to gh PR flow" >&2
      cat "$gt_log_file" >&2
    fi
  fi
fi

remote_name="origin"
if upstream_ref="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"; then
  remote_name="${upstream_ref%%/*}"
fi

if ! git ls-remote --exit-code --heads "$remote_name" "$branch" >/dev/null 2>&1; then
  echo "pushing branch $branch to $remote_name"
  git push -u "$remote_name" "$branch"
fi

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
