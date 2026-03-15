#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "securerandom"
require "tmpdir"

SOURCE_ROOT = File.expand_path("../..", __dir__)
COVERAGE_DIR = Dir.mktmpdir("publish-draft-coverage")

Minitest.after_run do
  dumps = Dir.glob(File.join(COVERAGE_DIR, "*.dump"))
  raise "missing coverage dumps for publish workflow tests" if dumps.empty?

  merged = []
  dumps.each do |dump_path|
    result = Marshal.load(File.binread(dump_path))
    result.each do |path, metrics|
      next unless path.end_with?("/scripts/lib/publish_draft_core.rb")

      lines = metrics.fetch(:lines)
      lines.each_with_index do |count, idx|
        if count.nil?
          merged[idx] = nil if merged[idx].nil?
        else
          merged[idx] = 0 if merged[idx].nil?
          merged[idx] += count
        end
      end
    end
  end

  executable = merged.each_index.select { |idx| !merged[idx].nil? }
  covered = executable.select { |idx| merged[idx].positive? }
  uncovered = executable - covered

  if executable.empty?
    raise "missing line coverage data for scripts/lib/publish_draft_core.rb"
  end
  unless uncovered.empty?
    line_list = uncovered.map { |idx| idx + 1 }.join(", ")
    raise "publish workflow coverage is below 100%; uncovered lines: #{line_list}"
  end
ensure
  FileUtils.rm_rf(COVERAGE_DIR)
end

class PublishDraftTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("publish-draft-test")
    @repo_root = File.join(@tmpdir, "repo")
    FileUtils.mkdir_p(@repo_root)
    setup_repo
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_successful_publish_deletes_draft_by_default
    draft_path = write_draft("success-default.md", "Default Delete Draft")

    stdout, stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14"
    )

    assert status.success?, "expected success, stderr: #{stderr}\nstdout: #{stdout}"
    refute File.exist?(File.join(@repo_root, draft_path))
    assert File.exist?(File.join(@repo_root, "_posts", "2026-03-14-default-delete-draft.md"))
    assert_match(/deleted source draft:/, stdout)
  end

  def test_keep_draft_override_preserves_source_file
    draft_path = write_draft("keep-draft.md", "Keep This Draft")

    stdout, stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14",
      "KEEP_DRAFT" => "1"
    )

    assert status.success?, "expected success, stderr: #{stderr}\nstdout: #{stdout}"
    assert File.exist?(File.join(@repo_root, draft_path))
    assert File.exist?(File.join(@repo_root, "_posts", "2026-03-14-keep-this-draft.md"))
    assert_match(/kept source draft:/, stdout)
  end

  def test_slug_override_is_used_for_target_path
    draft_path = write_draft("slug-override.md", "Ignored Title For Slug")

    _stdout, stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14",
      "SLUG" => "custom-slug"
    )

    assert status.success?, "expected success, stderr: #{stderr}"
    assert File.exist?(File.join(@repo_root, "_posts", "2026-03-14-custom-slug.md"))
  end

  def test_missing_required_inputs_fails_with_usage
    _stdout, stderr, status = run_publish("DRAFT_PATH" => "", "DATE" => "")

    refute status.success?
    assert_match(/usage: make publish-draft/, stderr)
  end

  def test_invalid_date_format_fails
    draft_path = write_draft("bad-date.md", "Bad Date")

    _stdout, stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026/03/14"
    )

    refute status.success?
    assert_match(/DATE must be in YYYY-MM-DD format/, stderr)
    assert File.exist?(File.join(@repo_root, draft_path))
  end

  def test_non_drafts_path_is_rejected
    notes_dir = File.join(@repo_root, "notes")
    FileUtils.mkdir_p(notes_dir)
    other_path = "notes/not-a-draft.md"
    File.write(File.join(@repo_root, other_path), "# note\n")

    _stdout, stderr, status = run_publish(
      "DRAFT_PATH" => other_path,
      "DATE" => "2026-03-14"
    )

    refute status.success?
    assert_match(/only supports files under _drafts\//, stderr)
    assert File.exist?(File.join(@repo_root, other_path))
  end

  def test_qa_failure_keeps_draft_untouched
    draft_path = write_draft("qa-failure.md", "QA Fails")

    _stdout, _stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14",
      "QA_FAIL" => "1"
    )

    refute status.success?
    assert File.exist?(File.join(@repo_root, draft_path))
    refute File.exist?(File.join(@repo_root, "_posts", "2026-03-14-qa-fails.md"))
  end

  def test_target_exists_failure_keeps_draft
    draft_path = write_draft("target-exists.md", "Target Exists")
    File.write(File.join(@repo_root, "_posts", "2026-03-14-target-exists.md"), "already here\n")

    _stdout, stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14"
    )

    refute status.success?
    assert_match(/target post already exists/, stderr)
    assert File.exist?(File.join(@repo_root, draft_path))
  end

  def test_validate_failure_keeps_draft_and_fails
    draft_path = write_draft("validate-fails.md", "Validate Fails")

    _stdout, _stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14",
      "VALIDATE_FAIL" => "1"
    )

    refute status.success?
    assert File.exist?(File.join(@repo_root, draft_path))
    assert File.exist?(File.join(@repo_root, "_posts", "2026-03-14-validate-fails.md"))
  end

  def test_missing_front_matter_fails_and_keeps_draft
    draft_path = "_drafts/no-frontmatter.md"
    File.write(File.join(@repo_root, draft_path), "plain text\n")

    _stdout, stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14"
    )

    refute status.success?
    assert_match(/missing YAML front matter/, stderr)
    assert File.exist?(File.join(@repo_root, draft_path))
  end

  def test_blank_slug_from_title_is_rejected
    draft_path = "_drafts/blank-slug.md"
    File.write(File.join(@repo_root, draft_path), <<~MD)
      ---
      title: "!!!"
      description: "A long enough description for validation checks."
      fact_check_status: complete
      categories: [blog]
      ---

      ## Section
      body
    MD

    _stdout, stderr, status = run_publish(
      "DRAFT_PATH" => draft_path,
      "DATE" => "2026-03-14"
    )

    refute status.success?
    assert_match(/could not derive a slug/, stderr)
    assert File.exist?(File.join(@repo_root, draft_path))
  end

  private

  def setup_repo
    copy_source("scripts/publish-draft.sh")
    copy_source("scripts/lib/publish_draft.rb")
    copy_source("scripts/lib/publish_draft_core.rb")
    write_executable(
      "scripts/qa-publish.sh",
      <<~SH
        #!/usr/bin/env bash
        set -euo pipefail
        if [[ "${QA_FAIL:-0}" == "1" ]]; then
          echo "error: qa failed" >&2
          exit 1
        fi
      SH
    )
    write_executable(
      ".agents/skills/jekyll-post-publisher/scripts/validate-post.sh",
      <<~SH
        #!/usr/bin/env bash
        set -euo pipefail
        if [[ "${VALIDATE_FAIL:-0}" == "1" ]]; then
          echo "error: validate failed" >&2
          exit 1
        fi
      SH
    )
    FileUtils.mkdir_p(File.join(@repo_root, "_drafts"))
    FileUtils.mkdir_p(File.join(@repo_root, "_posts"))
  end

  def write_draft(name, title)
    path = "_drafts/#{name}"
    File.write(File.join(@repo_root, path), <<~MD)
      ---
      title: "#{title}"
      description: "A long enough description for publish checks."
      fact_check_status: complete
      categories: [blog]
      ---

      ## Section
      body
    MD
    path
  end

  def run_publish(env_overrides)
    coverage_file = File.join(COVERAGE_DIR, "cov-#{SecureRandom.hex(8)}.dump")
    env = {
      "PUBLISH_DRAFT_COVERAGE" => coverage_file
    }.merge(env_overrides)
    Open3.capture3(
      env,
      File.join(@repo_root, "scripts/publish-draft.sh"),
      chdir: @repo_root
    )
  end

  def copy_source(relative_path)
    source = File.join(SOURCE_ROOT, relative_path)
    destination = File.join(@repo_root, relative_path)
    FileUtils.mkdir_p(File.dirname(destination))
    FileUtils.cp(source, destination)
    FileUtils.chmod(0o755, destination)
  end

  def write_executable(relative_path, content)
    destination = File.join(@repo_root, relative_path)
    FileUtils.mkdir_p(File.dirname(destination))
    File.write(destination, content)
    FileUtils.chmod(0o755, destination)
  end
end
