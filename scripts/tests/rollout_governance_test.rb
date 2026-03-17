#!/usr/bin/env ruby
# frozen_string_literal: true
require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"
class RolloutGovernanceTest < Minitest::Test
  VALIDATOR = File.expand_path("../validate-rollout-governance.rb", __dir__)
  CORE_PLAN_PATTERNS = [
    ".codex/rollout/active-plan.yaml",
    ".codex/rollout/plans/governance-v3/phase-*.txt"
  ].freeze
  def with_repo(branch: "codex/phase-1-test")
    Dir.mktmpdir("rollout-governance-test") do |dir|
      Dir.chdir(dir) do
        system!("git", "init")
        system!("git", "config", "user.name", "Test User")
        system!("git", "config", "user.email", "test@example.com")
        FileUtils.mkdir_p(".codex/rollout/plans/governance-v3")
        File.write("README.md", "baseline\n")
        system!("git", "add", "README.md")
        system!("git", "commit", "-m", "baseline")
        system!("git", "checkout", "-b", branch)
        yield dir
      end
    end
  end
  def write_active_plan(overrides = {})
    plan = {
      "version" => 1,
      "plan_id" => "governance-v3",
      "apply_to_all_prs" => true,
      "mode" => "sequential",
      "base_branch" => "main",
      "task_branch_pattern" => "^codex/cws-\\d+-[a-z0-9-]+$",
      "phase_branch_pattern" => "^codex/phase-(\\d+)-[a-z0-9-]+$",
      "limits" => {
        "max_changed_files_non_content" => 25,
        "max_changed_lines_non_content" => 1200,
        "ignore_paths_for_size_caps" => ["_posts/**", "_pages/**", "_drafts/**"]
      },
      "required_checks" => ["build", "semgrep", "rollout-governance"]
    }
    deep_merge!(plan, overrides)
    File.write(".codex/rollout/active-plan.yaml", plan.to_yaml)
  end
  def write_phase(number, lines)
    path = ".codex/rollout/plans/governance-v3/phase-#{number}.txt"
    body = lines.join("\n")
    File.write(path, "#{body}\n")
  end
  def write_contiguous_phases(max, lines = CORE_PLAN_PATTERNS + ["README.md"])
    (1..max).each { |n| write_phase(n, lines) }
  end
  def write_evidence(phase = 1)
    path = ".codex/rollout/evidence/governance-v3/phase-#{phase}.md"
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, <<~MD)
      RED
      - failing tests recorded
      GREEN
      - tests pass after implementation
    MD
  end
  def run_validator(branch: nil, env: {})
    cmd = ["ruby", VALIDATOR, "--repo-root", Dir.pwd]
    cmd += ["--branch", branch] if branch
    Open3.capture3(env, *cmd)
  end
  def test_dynamic_phase_count_accepts_contiguous_manifests
    with_repo(branch: "codex/phase-7-large-plan") do
      write_active_plan
      write_contiguous_phases(7)
      write_phase(7, CORE_PLAN_PATTERNS + ["README.md", ".codex/rollout/evidence/governance-v3/phase-7.md"])
      write_evidence(7)
      stdout, stderr, status = run_validator(env: { "GITHUB_HEAD_REF" => "codex/phase-1-unrelated" })
      assert status.success?, "expected success, got stderr: #{stderr}\nstdout: #{stdout}"
    end
  end
  def test_accepts_valid_cws_branch_without_phase_enforcement
    with_repo(branch: "codex/cws-16-branch-policy") do
      write_active_plan
      write_contiguous_phases(1)
      write_evidence(1)
      stdout, stderr, status = run_validator
      assert status.success?, "expected success, got stderr: #{stderr}\nstdout: #{stdout}"
      assert_match(/branch_mode=task/, stdout)
    end
  end
  def test_rejects_invalid_non_matching_branch
    with_repo(branch: "feature/cws-16-branch-policy") do
      write_active_plan
      write_contiguous_phases(1)
      write_evidence(1)
      _stdout, stderr, status = run_validator
      refute status.success?
      assert_match(/does not match task pattern/i, stderr)
    end
  end
  def test_dynamic_phase_count_accepts_single_phase_plan
    with_repo(branch: "codex/phase-1-single-phase") do
      write_active_plan
      write_phase(1, CORE_PLAN_PATTERNS + ["README.md", ".codex/rollout/evidence/governance-v3/phase-1.md"])
      write_evidence(1)
      stdout, stderr, status = run_validator
      assert status.success?, "expected success, got stderr: #{stderr}\nstdout: #{stdout}"
    end
  end
  def test_dynamic_phase_count_accepts_large_contiguous_manifests
    with_repo(branch: "codex/phase-50-large-plan") do
      write_active_plan("limits" => { "max_changed_files_non_content" => 100, "max_changed_lines_non_content" => 10_000 })
      write_contiguous_phases(50)
      write_phase(50, CORE_PLAN_PATTERNS + ["README.md", ".codex/rollout/evidence/governance-v3/phase-50.md"])
      write_evidence(50)
      stdout, stderr, status = run_validator
      assert status.success?, "expected success, got stderr: #{stderr}\nstdout: #{stdout}"
    end
  end
  def test_missing_intermediate_phase_manifest_fails
    with_repo(branch: "codex/phase-4-gap-case") do
      write_active_plan
      write_phase(1, ["README.md"])
      write_phase(2, ["README.md"])
      write_phase(4, ["README.md"])
      write_evidence(4)
      _stdout, stderr, status = run_validator
      refute status.success?
      assert_match(/missing phase manifest/i, stderr)
    end
  end
  def test_ignored_content_paths_are_excluded_from_size_caps_only
    with_repo do
      write_active_plan(
        "limits" => {
          "max_changed_files_non_content" => 10,
          "max_changed_lines_non_content" => 200
        }
      )
      write_phase(
        1,
        CORE_PLAN_PATTERNS + [
          ".codex/rollout/evidence/governance-v3/phase-1.md",
          "scripts/demo.sh",
          "_posts/2026-03-14-long-post.md"
        ]
      )
      write_evidence(1)
      FileUtils.mkdir_p("scripts")
      File.write("scripts/demo.sh", "#!/usr/bin/env bash\necho hi\n")
      FileUtils.mkdir_p("_posts")
      File.write("_posts/2026-03-14-long-post.md", ("x\n" * 5000))
      stdout, stderr, status = run_validator
      assert status.success?, "expected success, got stderr: #{stderr}\nstdout: #{stdout}"
    end
  end
  def test_non_content_size_cap_failure
    with_repo do
      write_active_plan(
        "limits" => {
          "max_changed_files_non_content" => 10,
          "max_changed_lines_non_content" => 10
        }
      )
      write_phase(
        1,
        CORE_PLAN_PATTERNS + [
          ".codex/rollout/evidence/governance-v3/phase-1.md",
          "scripts/demo.sh"
        ]
      )
      write_evidence(1)
      FileUtils.mkdir_p("scripts")
      File.write("scripts/demo.sh", ("line\n" * 50))
      _stdout, stderr, status = run_validator
      refute status.success?
      assert_match(/changed lines exceed/i, stderr)
    end
  end
  def test_scope_failure_even_for_ignored_paths
    with_repo do
      write_active_plan
      write_phase(
        1,
        CORE_PLAN_PATTERNS + [
          ".codex/rollout/evidence/governance-v3/phase-1.md",
          "scripts/demo.sh"
        ]
      )
      write_evidence(1)
      FileUtils.mkdir_p("_posts")
      File.write("_posts/2026-03-14-long-post.md", "hello\n")
      _stdout, stderr, status = run_validator
      refute status.success?
      assert_match(/outside phase-1 scope/i, stderr)
    end
  end
  def test_broad_content_wildcard_in_manifest_is_blocked
    with_repo do
      write_active_plan
      write_phase(1, CORE_PLAN_PATTERNS + [".codex/rollout/evidence/governance-v3/phase-1.md", "_posts/*"])
      write_evidence(1)
      FileUtils.mkdir_p("_posts")
      File.write("_posts/2026-03-14-long-post.md", "hello\n")
      _stdout, stderr, status = run_validator
      refute status.success?
      assert_match(/broad content wildcard/i, stderr)
    end
  end
  private
  def deep_merge!(target, updates)
    updates.each_pair do |key, value|
      if target[key].is_a?(Hash) && value.is_a?(Hash)
        deep_merge!(target[key], value)
      else
        target[key] = value
      end
    end
  end
  def system!(*args)
    ok = system(*args)
    return if ok
    raise "command failed: #{args.join(' ')}"
  end
end
