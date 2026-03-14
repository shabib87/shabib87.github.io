#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "optparse"
require "set"
require "yaml"

options = {
  repo_root: File.expand_path("..", __dir__)
}

OptionParser.new do |parser|
  parser.on("--repo-root PATH", "Repository root path") do |value|
    options[:repo_root] = File.expand_path(value)
  end
  parser.on("--branch NAME", "Branch name override") do |value|
    options[:branch] = value
  end
end.parse!(ARGV)

repo_root = options[:repo_root]
errors = []

def command_output(repo_root, command)
  output = `git -C "#{repo_root}" #{command} 2>/dev/null`
  [($? && $?.success?), output]
end

def changed_files(repo_root, base_branch)
  files = Set.new
  untracked_files = Set.new

  merge_base_ok, merge_base = command_output(repo_root, "merge-base #{base_branch} HEAD")
  merge_base = merge_base.strip

  if merge_base_ok && !merge_base.empty?
    _, committed = command_output(repo_root, "diff --name-only --diff-filter=ACMRD #{merge_base}...HEAD")
    committed.each_line { |line| files << line.strip unless line.strip.empty? }
  end

  _, working = command_output(repo_root, "diff --name-only --diff-filter=ACMRD")
  working.each_line { |line| files << line.strip unless line.strip.empty? }

  _, staged = command_output(repo_root, "diff --name-only --cached --diff-filter=ACMRD")
  staged.each_line { |line| files << line.strip unless line.strip.empty? }

  _, untracked = command_output(repo_root, "ls-files --others --exclude-standard")
  untracked.each_line do |line|
    value = line.strip
    next if value.empty?

    files << value
    untracked_files << value
  end

  [files.to_a.sort, merge_base, untracked_files.to_a.sort]
end

def add_numstat(output, line_counts)
  output.each_line do |line|
    added, deleted, file = line.strip.split("\t", 3)
    next if file.to_s.empty?

    next if added == "-" || deleted == "-"

    total = added.to_i + deleted.to_i
    line_counts[file] = [line_counts[file], total].max
  end
end

def changed_line_counts(repo_root, base_branch, merge_base, untracked_files)
  counts = Hash.new(0)

  if !merge_base.empty?
    _, committed = command_output(repo_root, "diff --numstat --diff-filter=ACMRD #{merge_base}...HEAD")
    add_numstat(committed, counts)
  end

  _, working = command_output(repo_root, "diff --numstat --diff-filter=ACMRD")
  add_numstat(working, counts)

  _, staged = command_output(repo_root, "diff --numstat --cached --diff-filter=ACMRD")
  add_numstat(staged, counts)

  untracked_files.each do |file|
    next unless File.file?(File.join(repo_root, file))

    line_count = File.foreach(File.join(repo_root, file)).count
    counts[file] = [counts[file], line_count].max
  end

  counts
end

def glob_match?(pattern, value)
  File.fnmatch?(pattern, value, File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB)
end

active_plan_path = File.join(repo_root, ".codex", "rollout", "active-plan.yaml")
unless File.file?(active_plan_path)
  warn "error: missing active rollout plan #{active_plan_path.delete_prefix("#{repo_root}/")}"
  exit 1
end

plan = YAML.safe_load(File.read(active_plan_path), permitted_classes: [Date, Time], aliases: false) || {}

plan_id = plan["plan_id"].to_s.strip
apply_to_all_prs = plan["apply_to_all_prs"] == true
mode = plan["mode"].to_s.strip
base_branch = plan["base_branch"].to_s.strip
branch_pattern = plan["branch_pattern"].to_s.strip
limits = plan["limits"].is_a?(Hash) ? plan["limits"] : {}
max_changed_files_non_content = limits["max_changed_files_non_content"]
max_changed_lines_non_content = limits["max_changed_lines_non_content"]
ignore_paths_for_size_caps = limits["ignore_paths_for_size_caps"].is_a?(Array) ? limits["ignore_paths_for_size_caps"] : []

errors << "active-plan.yaml missing plan_id" if plan_id.empty?
errors << "active-plan.yaml must set apply_to_all_prs=true" unless apply_to_all_prs
errors << "active-plan.yaml mode must be sequential" unless mode == "sequential"
errors << "active-plan.yaml missing base_branch" if base_branch.empty?
errors << "active-plan.yaml missing branch_pattern" if branch_pattern.empty?
errors << "active-plan.yaml limits.max_changed_files_non_content must be a positive integer" unless max_changed_files_non_content.is_a?(Integer) && max_changed_files_non_content.positive?
errors << "active-plan.yaml limits.max_changed_lines_non_content must be a positive integer" unless max_changed_lines_non_content.is_a?(Integer) && max_changed_lines_non_content.positive?
errors << "active-plan.yaml limits.ignore_paths_for_size_caps must be a non-empty list" if ignore_paths_for_size_caps.empty?

branch = options[:branch] || ENV["ROLLOUT_BRANCH"] || ENV["GITHUB_HEAD_REF"]
if branch.to_s.strip.empty?
  ok, branch_output = command_output(repo_root, "branch --show-current")
  branch = ok ? branch_output.strip : ""
end

phase = nil
if branch == base_branch
  puts "rollout governance check skipped for base branch #{base_branch}"
  exit 0 if errors.empty?
elsif branch.empty?
  errors << "unable to detect current branch"
else
  match = Regexp.new(branch_pattern).match(branch) rescue nil
  if match.nil?
    errors << "branch #{branch.inspect} does not match required phase pattern #{branch_pattern.inspect}" if apply_to_all_prs
  else
    phase = match[1].to_i
    errors << "phase extracted from branch must be >= 1" if phase <= 0
  end
end

plan_dir = File.join(repo_root, ".codex", "rollout", "plans", plan_id)
phase_files = Dir[File.join(plan_dir, "phase-*.txt")]
phase_numbers = phase_files.filter_map do |path|
  match = path.match(/phase-(\d+)\.txt$/)
  match && match[1].to_i
end.sort

if phase_numbers.empty?
  errors << "no phase manifests found under #{plan_dir.delete_prefix("#{repo_root}/")}"
else
  highest = phase_numbers.max
  (1..highest).each do |number|
    manifest = File.join(plan_dir, "phase-#{number}.txt")
    errors << "missing phase manifest #{manifest.delete_prefix("#{repo_root}/")}" unless File.file?(manifest)
  end
end

if phase && !phase_numbers.empty?
  highest = phase_numbers.max
  if phase > highest
    errors << "branch phase #{phase} exceeds highest configured phase #{highest}"
  end
end

if errors.any?
  errors.each { |error| warn "error: #{error}" }
  exit 1
end

manifest_path = File.join(plan_dir, "phase-#{phase}.txt")
unless File.file?(manifest_path)
  warn "error: missing phase manifest #{manifest_path.delete_prefix("#{repo_root}/")}"
  exit 1
end

manifest_patterns = File.readlines(manifest_path, chomp: true).map(&:strip).reject { |line| line.empty? || line.start_with?("#") }
if manifest_patterns.empty?
  warn "error: no file patterns declared in #{manifest_path.delete_prefix("#{repo_root}/")}"
  exit 1
end

content_roots = ignore_paths_for_size_caps.filter_map do |pattern|
  match = pattern.to_s.match(%r{\A(_posts|_pages|_drafts)/\*\*\z})
  match && "#{match[1]}/"
end.uniq

manifest_patterns.each do |pattern|
  content_roots.each do |root|
    if pattern.start_with?("#{root}*")
      warn "error: broad content wildcard #{pattern.inspect} is not allowed in #{manifest_path.delete_prefix("#{repo_root}/")}"
      exit 1
    end
  end
end

evidence_path = File.join(repo_root, ".codex", "rollout", "evidence", plan_id, "phase-#{phase}.md")
unless File.file?(evidence_path)
  warn "error: missing TDD evidence file #{evidence_path.delete_prefix("#{repo_root}/")}"
  exit 1
end

evidence = File.read(evidence_path)
unless evidence.match?(/^\s*RED\b/i) && evidence.match?(/^\s*GREEN\b/i)
  warn "error: TDD evidence file must include RED and GREEN sections (#{evidence_path.delete_prefix("#{repo_root}/")})"
  exit 1
end

changed, merge_base, untracked_files = changed_files(repo_root, base_branch)
if changed.empty?
  puts "rollout governance check passed (no changed files)"
  exit 0
end

scope_violations = changed.reject do |file|
  manifest_patterns.any? { |pattern| glob_match?(pattern, file) }
end

if scope_violations.any?
  warn "error: files outside phase-#{phase} scope:"
  scope_violations.each { |path| warn "  - #{path}" }
  exit 1
end

line_counts = changed_line_counts(repo_root, base_branch, merge_base, untracked_files)
non_content = changed.reject do |path|
  ignore_paths_for_size_caps.any? { |pattern| glob_match?(pattern, path) }
end

non_content_changed_files = non_content.length
non_content_changed_lines = non_content.sum { |path| line_counts[path].to_i }

if non_content_changed_files > max_changed_files_non_content
  warn "error: changed files exceed limit (#{non_content_changed_files} > #{max_changed_files_non_content}) for non-content paths"
  exit 1
end

if non_content_changed_lines > max_changed_lines_non_content
  warn "error: changed lines exceed limit (#{non_content_changed_lines} > #{max_changed_lines_non_content}) for non-content paths"
  exit 1
end

puts "rollout governance check passed for plan=#{plan_id} phase=#{phase}"
