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
required_checks = data["required_checks"].is_a?(Array) ? data["required_checks"] : []

if plan_id.empty? || base_branch.empty? || task_branch_pattern.empty?
  warn "error: active rollout plan is missing plan_id/base_branch/task_branch_pattern"
  exit 1
end

task_match = Regexp.new(task_branch_pattern).match(branch)
if task_match.nil?
  warn "error: branch #{branch.inspect} does not match task pattern #{task_branch_pattern.inspect}"
  exit 1
end

puts "#{plan_id}\t#{base_branch}\t#{required_checks.join(',')}"
RUBY
)"

base_branch="$(printf '%s' "$plan_info" | awk -F '\t' 'NR==1 {print $2}')"

if ! ruby - "$repo_root/docs/agent-context.md" <<'RUBY'
require "time"

path = ARGV.fetch(0)
unless File.file?(path)
  warn "error: missing docs/agent-context.md"
  exit 1
end

content = File.read(path)
stale_section = content.match(/^## Stale After\s*$\n+((?:- .*\n)+)/m)
if stale_section.nil?
  warn "error: docs/agent-context.md is missing a parseable 'Stale After' section"
  exit 1
end

ts_line = stale_section[1].lines.find { |line| line.match?(/^\s*-\s*`[^`]+`\s*$/) }
if ts_line.nil?
  warn "error: docs/agent-context.md is missing stale timestamp in 'Stale After' section"
  exit 1
end

ts = ts_line[/`([^`]+)`/, 1]
begin
  stale_at = Time.parse(ts)
rescue ArgumentError
  warn "error: could not parse stale timestamp #{ts.inspect} in docs/agent-context.md"
  exit 1
end

if Time.now > stale_at
  warn "error: docs/agent-context.md is stale (stale_after=#{stale_at.strftime("%Y-%m-%d %H:%M:%S %Z")})"
  exit 1
end
RUBY
then
  exit 1
fi

issue_id=""
linear_issue_link=""
if [[ "$branch" =~ ^cws/([0-9]+)-[a-z0-9-]+$ ]]; then
  issue_id="CWS-${BASH_REMATCH[1]}"
  linear_issue_link="https://linear.app/codewithshabib/issue/${issue_id}"
else
  echo "error: unable to derive issue id from task branch: $branch" >&2
  exit 1
fi

# Task files are local context snapshots. Gate only on existence; mutable status stays in Linear.
task_file="$repo_root/docs/tasks/${issue_id}.md"
if [[ ! -f "$task_file" ]]; then
  echo "error: missing required task file: docs/tasks/${issue_id}.md" >&2
  exit 1
fi


title_line="$("$repo_root/.agents/skills/repo-flow/scripts/infer-pr-metadata.sh" "$type")"
title="${title_line#TITLE=}"
if [[ -n "$issue_id" ]]; then
  issue_id_lower="$(printf '%s' "$issue_id" | tr '[:upper:]' '[:lower:]')"
  if [[ "$title" != *"${issue_id}"* && "$title" != *"${issue_id_lower}"* ]]; then
    echo "error: inferred PR title must include ${issue_id} for traceability" >&2
    echo "error: current inferred title: $title" >&2
    exit 1
  fi
fi

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

## Linear Traceability

- Issue: ${linear_issue_link}

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
  if ! gt submit --stack --no-interactive --publish >"$gt_log_file" 2>&1; then
    if grep -q "untracked branch" "$gt_log_file"; then
      if ! gt track --parent "$base_branch" >>"$gt_log_file" 2>&1; then
        echo "warning: gt branch tracking failed; falling back to gh PR flow" >&2
        cat "$gt_log_file" >&2
      elif ! gt submit --stack --no-interactive --publish >>"$gt_log_file" 2>&1; then
        echo "warning: gt submit failed after tracking branch; falling back to gh PR flow" >&2
        cat "$gt_log_file" >&2
      fi
    elif grep -q "must restack before submitting this stack" "$gt_log_file"; then
      if ! gt restack >>"$gt_log_file" 2>&1; then
        echo "warning: gt restack failed; falling back to gh PR flow" >&2
        cat "$gt_log_file" >&2
      elif ! gt submit --stack --no-interactive --publish >>"$gt_log_file" 2>&1; then
        echo "warning: gt submit failed after restack; falling back to gh PR flow" >&2
        cat "$gt_log_file" >&2
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
