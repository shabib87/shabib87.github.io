#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

name="${NAME:-${1:-}}"
source_input="${SOURCE:-${2:-}}"
ref="${REF:-main}"

if [[ -z "$name" && -z "$source_input" ]]; then
  echo "error: provide NAME, SOURCE, or pass the skill name as the first argument" >&2
  exit 1
fi

temp_dir=""
cleanup() {
  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir"
  fi
}
trap cleanup EXIT

skill_path=""
source_label="${source_input:-"(not provided)"}"

if [[ -n "$source_input" && -d "$source_input" ]]; then
  skill_path="$(cd "$source_input" && pwd)"
  [[ -n "$name" ]] || name="$(basename "$skill_path")"
  source_label="$skill_path"
elif [[ -n "$source_input" && "$source_input" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
  owner="${BASH_REMATCH[1]}"
  repo="${BASH_REMATCH[2]}"
  ref="${BASH_REMATCH[3]}"
  skill_subpath="${BASH_REMATCH[4]}"
  [[ -n "$name" ]] || name="$(basename "$skill_subpath")"
  temp_dir="$(mktemp -d)"
  git clone --depth 1 --branch "$ref" --filter=blob:none --sparse "https://github.com/$owner/$repo.git" "$temp_dir/repo" >/dev/null 2>&1
  (
    cd "$temp_dir/repo"
    git sparse-checkout set "$skill_subpath" >/dev/null 2>&1
  )
  skill_path="$temp_dir/repo/$skill_subpath"
  source_label="$source_input"
elif [[ -n "$name" && -d "$repo_root/.agents/skills/$name" ]]; then
  skill_path="$repo_root/.agents/skills/$name"
  source_label="$repo_root/.agents/skills/$name"
elif [[ -n "$source_input" ]]; then
  echo "error: SOURCE must be a local path or a GitHub tree URL" >&2
  exit 1
else
  echo "error: could not find local skill: $name" >&2
  exit 1
fi

if [[ ! -f "$skill_path/SKILL.md" ]]; then
  echo "error: SKILL.md not found in $skill_path" >&2
  exit 1
fi

ruby - "$repo_root" "$skill_path" "$name" "$source_label" <<'RUBY'
require "date"
require "yaml"

repo_root, skill_path, skill_name, source_label = ARGV

STOPWORDS = %w[
  a an and are as at be before by do for from into is it its of on or that the this to use when with your
  user users work workflow skill site repo repository content article post posts blog writing draft drafts
]

CATEGORY_KEYWORDS = {
  "brainstorming" => %w[brainstorm idea ideas hook hooks angle backlog positioning topic topics outline outlines],
  "drafting" => %w[draft drafting article body restructure section sections transition transitions example examples voice thesis],
  "fact-checking" => %w[verify verification fact fact-check claims citation citations primary official docs source sources],
  "publishing" => %w[jekyll publish publishing metadata front matter permalink taxonomy _drafts _posts qa validation validate],
  "migration" => %w[medium migrate migration import imported canonical seo],
  "repo-flow" => %w[git github gh pr branch branches merge rebase checkout],
  "official-docs" => %w[context7 official docs first-party version api tool library libraries]
}.freeze

OFF_PLATFORM_PATTERNS = {
  "Claude Code workflow mention" => /claude code/i,
  "inference.sh dependency" => /inference\.sh/i,
  "auth requirement" => /\b(auth|login|token|api key|api_key)\b/i,
  "MCP tool dependency" => /\bmcp\b/i
}.freeze

def load_skill(path)
  skill_md = File.join(path, "SKILL.md")
  content = File.read(skill_md)
  match = content.match(/\A---\n(.*?)\n---\n/m)
  abort("error: missing YAML front matter in #{skill_md}") unless match

  frontmatter = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
  body = content.sub(match[0], "")

  openai_yaml = {}
  openai_path = File.join(path, "agents", "openai.yaml")
  if File.file?(openai_path)
    openai_yaml = YAML.safe_load(File.read(openai_path), permitted_classes: [Time, Date], aliases: true) || {}
  end

  references = Dir[File.join(path, "references", "**", "*")].select { |file| File.file?(file) }
  scripts = Dir[File.join(path, "scripts", "**", "*")].select { |file| File.file?(file) }

  {
    "path" => path,
    "name" => frontmatter["name"].to_s.strip,
    "description" => frontmatter["description"].to_s.strip,
    "body" => body,
    "openai" => openai_yaml,
    "references" => references,
    "scripts" => scripts
  }
end

def normalized_text(skill)
  [
    skill["name"],
    skill["description"],
    skill["body"],
    skill["references"].map { |path| File.basename(path, File.extname(path)) }.join(" "),
    skill["scripts"].map { |path| File.basename(path, File.extname(path)) }.join(" ")
  ].join("\n").downcase
end

def tokens_for(skill)
  normalized_text(skill)
    .scan(/[a-z0-9][a-z0-9\-]+/)
    .reject { |token| token.length < 4 || STOPWORDS.include?(token) }
    .uniq
end

def categories_for(skill)
  text = normalized_text(skill)
  CATEGORY_KEYWORDS.each_with_object([]) do |(category, keywords), matches|
    matches << category if keywords.any? { |word| text.match?(/\b#{Regexp.escape(word)}\b/) }
  end
end

def overlap_items(target_skill, local_skills)
  target_tokens = tokens_for(target_skill)
  target_categories = categories_for(target_skill)

  local_skills.filter_map do |skill|
    next if skill["path"] == target_skill["path"]

    other_tokens = tokens_for(skill)
    shared_tokens = (target_tokens & other_tokens)
    category_overlap = target_categories & categories_for(skill)
    next if shared_tokens.empty? && category_overlap.empty?

    {
      "name" => skill["name"],
      "shared_tokens" => shared_tokens.first(6),
      "shared_categories" => category_overlap
    }
  end.sort_by { |item| [-(item["shared_categories"].length), -(item["shared_tokens"].length), item["name"]] }
end

def fit_assessment(skill)
  categories = categories_for(skill)
  editorial_overlap = categories & %w[brainstorming drafting fact-checking publishing migration]
  notes = []

  if editorial_overlap.empty?
    level = "low"
    notes << "little alignment with the repo's editorial workflow"
  elsif categories.include?("drafting") || categories.include?("publishing")
    level = "high"
    notes << "maps directly to the repo's editorial pipeline"
  else
    level = "medium"
    notes << "touches the writing workflow but is not a central drafting/publish stage"
  end

  if normalized_text(skill).match?(/_drafts|_posts|jekyll|front matter|taxonomy/)
    notes << "speaks the repo's Jekyll publishing model"
  end

  if normalized_text(skill).match?(/voice|hook|outline|example|thesis/)
    notes << "supports the site's authority-first technical writing style"
  end

  [level, notes.uniq]
end

def hidden_dependencies(skill)
  findings = []
  text = normalized_text(skill)

  OFF_PLATFORM_PATTERNS.each do |label, pattern|
    findings << label if text.match?(pattern)
  end

  openai = skill["openai"].is_a?(Hash) ? skill["openai"] : {}
  deps = openai.dig("dependencies", "tools")
  if deps.is_a?(Array) && !deps.empty?
    findings << "tool dependencies declared in agents/openai.yaml"
  end

  findings.uniq
end

def official_doc_need(skill)
  text = normalized_text(skill)
  return "yes: skill mentions official docs or version-sensitive tool behavior" if text.match?(/official docs|context7|version|api|library|tool/)
  "no: mostly editorial guidance with no strong tool-version surface"
end

def maintenance_assessment(skill, hidden_deps)
  score = 0
  score += 2 unless hidden_deps.empty?
  score += 1 unless skill["scripts"].empty?
  score += 1 if skill["references"].length >= 4
  score += 1 if normalized_text(skill).match?(/github|openai|jekyll|context7|anthropic|claude|api|tool/)

  if score >= 4
    ["high", "external dependencies or product-specific behavior increase upkeep"]
  elsif score >= 2
    ["medium", "some repo or tool-specific guidance will need occasional review"]
  else
    ["low", "mostly static editorial guidance with limited moving parts"]
  end
end

def recommendation_for(fit_level, overlap, hidden_deps)
  overlap_names = overlap.map { |item| item["name"] }
  overlap_size = overlap_names.length
  off_platform = hidden_deps.any? { |item| item.match?(/Claude|inference\.sh|auth|MCP/) }

  if fit_level == "low"
    ["reject", "weak fit for this repo's workflow"]
  elsif off_platform || overlap_size >= 3
    ["adapt", "useful ideas exist, but overlap or hidden dependencies make direct vendoring noisy"]
  elsif overlap_size >= 1
    ["adapt", "fits the workflow but should be narrowed to avoid duplicating existing skills"]
  else
    ["vendor", "clean fit with limited overlap"]
  end
end

target_skill = load_skill(skill_path)
local_skills = Dir[File.join(repo_root, ".agents", "skills", "*")]
  .select { |path| File.directory?(path) }
  .map { |path| load_skill(path) }

fit_level, fit_notes = fit_assessment(target_skill)
overlap = overlap_items(target_skill, local_skills)
hidden_deps = hidden_dependencies(target_skill)
maintenance_level, maintenance_note = maintenance_assessment(target_skill, hidden_deps)
official_doc_note = official_doc_need(target_skill)
recommendation, recommendation_reason = recommendation_for(fit_level, overlap, hidden_deps)

overlap_summary =
  if overlap.empty?
    "none detected"
  else
    overlap.first(3).map do |item|
      details = []
      details << "shared categories: #{item["shared_categories"].join(', ')}" unless item["shared_categories"].empty?
      details << "shared terms: #{item["shared_tokens"].join(', ')}" unless item["shared_tokens"].empty?
      "#{item["name"]} (#{details.join('; ')})"
    end.join("; ")
  end

hidden_dep_summary =
  if hidden_deps.empty?
    "none detected from SKILL.md or agents/openai.yaml"
  else
    hidden_deps.join("; ")
  end

puts <<~OUTPUT
Skill audit: #{target_skill["name"].empty? ? skill_name : target_skill["name"]}

- Source: #{source_label}
- Skill path: #{skill_path}
- Fit for this repo's writing workflow: #{fit_level}#{fit_notes.empty? ? '' : " - #{fit_notes.join('; ')}"}
- Overlap with existing repo-local skills: #{overlap_summary}
- Hidden dependencies or auth requirements: #{hidden_dep_summary}
- Maintenance burden: #{maintenance_level} - #{maintenance_note}
- Needs official-doc verification: #{official_doc_note}
- Recommendation: #{recommendation} - #{recommendation_reason}
OUTPUT
RUBY
