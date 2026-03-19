#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"
activate_repo_ruby
require_repo_ruby || exit 1

phase="${PHASE:-}"
if [[ -z "$phase" ]]; then
  branch="$(git branch --show-current 2>/dev/null || true)"
  if [[ "$branch" =~ ^codex/phase-([0-9]+)(-|$) ]]; then
    phase="${BASH_REMATCH[1]}"
  fi
fi

export PHASE="$phase"

ruby - "$repo_root" <<'RUBY'
require "date"
require "set"
require "yaml"

repo_root = ARGV.fetch(0)
errors = []

skill_paths = Dir[File.join(repo_root, ".agents", "skills", "*")].select { |path| File.directory?(path) }.sort
if skill_paths.empty?
  errors << "no skill directories found under .agents/skills"
end

skill_paths.each do |skill_path|
  skill_md = File.join(skill_path, "SKILL.md")
  skill_label = skill_path.delete_prefix("#{repo_root}/")

  unless File.file?(skill_md)
    errors << "missing SKILL.md in #{skill_label}"
    next
  end

  content = File.read(skill_md)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  if match.nil?
    errors << "missing YAML front matter in #{skill_label}/SKILL.md"
  else
    data = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
    errors << "missing name in #{skill_label}/SKILL.md" if data["name"].to_s.strip.empty?
    errors << "missing description in #{skill_label}/SKILL.md" if data["description"].to_s.strip.empty?
  end

  openai_yaml = File.join(skill_path, "agents", "openai.yaml")
  unless File.file?(openai_yaml)
    errors << "missing agents/openai.yaml in #{skill_label}"
    next
  end

  openai = YAML.safe_load(File.read(openai_yaml), permitted_classes: [Time, Date], aliases: true) || {}
  interface = openai["interface"]
  unless interface.is_a?(Hash)
    errors << "missing interface block in #{skill_label}/agents/openai.yaml"
    next
  end

  %w[display_name short_description default_prompt].each do |field|
    errors << "missing interface.#{field} in #{skill_label}/agents/openai.yaml" if interface[field].to_s.strip.empty?
  end
end

makefile = File.read(File.join(repo_root, "Makefile"))
%w[site-audit codex-check qa-local start-phase rollout-audit].each do |target|
  errors << "missing #{target} target in Makefile" unless makefile.match?(/^#{Regexp.escape(target)}:/)
end

docs_index = File.read(File.join(repo_root, ".codex", "docs", "README.md"))
{
  "[Codex Usage](./codex-usage.md)" => ".codex/docs/codex-usage.md",
  "[Site Quality](./site-quality.md)" => ".codex/docs/site-quality.md"
}.each do |needle, path|
  errors << "missing docs index entry for #{path}" unless docs_index.include?(needle)
end

prompt_dir = File.join(repo_root, ".codex", "prompts")
errors << "missing .codex/prompts directory" unless Dir.exist?(prompt_dir)

required_prompts = %w[
  editorial-workflow.md
  site-quality.md
  repo-workflow.md
  official-docs.md
  site-workflow.md
  preserve-existing-post.md
  orchestrator-site-workflow.md
  orchestrator-editorial-workflow.md
  orchestrator-preserve-existing-post.md
]

required_prompts.each do |prompt|
  prompt_path = File.join(prompt_dir, prompt)
  errors << "missing #{prompt_path.delete_prefix("#{repo_root}/")}" unless File.file?(prompt_path)
end

codex_usage_path = File.join(repo_root, ".codex", "docs", "codex-usage.md")
docs_readme_path = File.join(repo_root, ".codex", "docs", "README.md")
if File.file?(codex_usage_path) && File.file?(docs_readme_path)
  codex_usage = File.read(codex_usage_path)
  docs_readme = File.read(docs_readme_path)

  starter_needles = [
    "@.codex/prompts/orchestrator-site-workflow.md",
    "@.codex/prompts/orchestrator-editorial-workflow.md",
    "@.codex/prompts/orchestrator-preserve-existing-post.md"
  ]

  starter_needles.each do |needle|
    errors << "missing #{needle} in .codex/docs/codex-usage.md" unless codex_usage.include?(needle)
    errors << "missing #{needle} in .codex/docs/README.md" unless docs_readme.include?(needle)
  end
end

medium_skill_exists = Dir.exist?(File.join(repo_root, ".agents", "skills", "medium-porter"))
if !medium_skill_exists
  retired_tokens = [
    /medium-porter/i,
    /medium-to-blog/i,
    /@\.codex\/prompts\/medium-to-blog\.md/
  ]

  [
    ".codex/docs/codex-usage.md",
    ".codex/docs/workflows.md",
    ".codex/docs/prompt-recipes.md",
    ".codex/prompts/editorial-workflow.md",
    "AGENTS.md"
  ].each do |path|
    full_path = File.join(repo_root, path)
    next unless File.file?(full_path)

    body = File.read(full_path)
    retired_tokens.each do |token|
      errors << "retired token #{token.inspect} found in #{path}" if body.match?(token)
    end
  end
end

common_ancestor = `git -C "#{repo_root}" merge-base main HEAD 2>/dev/null`.strip
changed = Set.new
if !common_ancestor.empty?
  `git -C "#{repo_root}" diff --name-only --diff-filter=ACMRD #{common_ancestor}...HEAD`.each_line do |line|
    value = line.strip
    changed << value unless value.empty?
  end
end
`git -C "#{repo_root}" diff --name-only --diff-filter=ACMRD`.each_line do |line|
  value = line.strip
  changed << value unless value.empty?
end
`git -C "#{repo_root}" diff --name-only --cached --diff-filter=ACMRD`.each_line do |line|
  value = line.strip
  changed << value unless value.empty?
end
`git -C "#{repo_root}" ls-files --others --exclude-standard`.each_line do |line|
  value = line.strip
  changed << value unless value.empty?
end

governance_change = changed.any? do |path|
  path.match?(%r{\Ascripts/(validate-rollout-governance\.rb|create-pr\.sh|finalize-merge\.sh|start-phase\.sh|rollout-audit\.sh|run-codex-checks\.sh)\z}) ||
    path == ".github/workflows/rollout-governance.yml"
end

test_or_evidence_change = changed.any? do |path|
  path.start_with?("scripts/tests/") ||
    path == "scripts/run-rollout-governance-tests.sh" ||
    path.start_with?(".codex/rollout/evidence/")
end

if governance_change && !test_or_evidence_change
  errors << "governance script changes require matching test/evidence updates (scripts/tests/* and .codex/rollout/evidence/*)"
end

if errors.empty?
  puts "codex workflow checks passed"
  puts "validated skills: #{skill_paths.length}"
else
  errors.each { |error| warn "error: #{error}" }
  exit 1
end
RUBY

"$repo_root/scripts/validate-multi-agent-contracts.rb"
"$repo_root/scripts/run-rollout-governance-tests.sh"
ruby "$repo_root/scripts/validate-rollout-governance.rb"
