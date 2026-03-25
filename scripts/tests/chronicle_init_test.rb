#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class ChronicleInitTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../../.claude/hooks/chronicle-init.sh", __dir__)

  def script_body
    @script_body ||= begin
      assert File.exist?(SCRIPT_PATH), "chronicle-init.sh must exist at #{SCRIPT_PATH}"
      File.read(SCRIPT_PATH)
    end
  end

  # --- Fail-closed safety ---

  def test_uses_strict_mode
    assert_match(/^set -euo pipefail$/, script_body)
  end

  def test_traps_err_to_exit_2
    assert_match(/trap .* ERR/, script_body)
    assert_match(/exit 2/, script_body)
  end

  # --- Input parsing ---

  def test_reads_session_id_from_stdin_json
    assert_match(/jq\b.*session_id/, script_body)
  end

  def test_reads_source_from_stdin_json
    assert_match(/jq\b.*source/, script_body)
  end

  def test_fails_on_missing_session_id
    assert_match(/session_id/, script_body)
    assert_match(/exit 2/, script_body)
  end

  # --- Path derivation ---

  def test_derives_project_dir_from_pwd
    assert_match(/sed.*s\|\/\|-\|g/, script_body)
  end

  def test_creates_chronicle_directory
    assert_match(/mkdir -p/, script_body)
  end

  def test_derives_branch_slug
    assert_match(/git rev-parse --abbrev-ref HEAD/, script_body)
    assert_match(/tr '?\/'? '?-'?/, script_body)
  end

  # --- File creation ---

  def test_writes_frontmatter_with_session_id
    assert_match(/session_id:/, script_body)
  end

  def test_writes_frontmatter_with_date
    assert_match(/date:/, script_body)
  end

  def test_writes_frontmatter_with_branch
    assert_match(/branch:/, script_body)
  end

  def test_writes_events_header
    assert_match(/## Events/, script_body)
  end

  def test_writes_summary_header
    assert_match(/## Summary/, script_body)
  end

  # --- Session reuse logic ---

  def test_reuses_file_on_resume
    assert_match(/resume/, script_body)
  end

  def test_reuses_file_on_compact
    assert_match(/compact/, script_body)
  end

  def test_creates_suffixed_file_for_new_session
    assert_match(/-[0-9]/, script_body)
  end

  # --- Environment variable export ---

  def test_sets_chronicle_path_via_env_file
    assert_match(/CLAUDE_ENV_FILE/, script_body)
    assert_match(/CHRONICLE_PATH=/, script_body)
  end

  # --- JSON output ---

  def test_outputs_hook_specific_json
    assert_match(/hookSpecificOutput/, script_body)
    assert_match(/hookEventName/, script_body)
    assert_match(/SessionStart/, script_body)
    assert_match(/additionalContext/, script_body)
  end

  def test_context_includes_event_tags
    assert_match(/\[DECISION\]/, script_body)
    assert_match(/\[ERROR\]/, script_body)
    assert_match(/\[PIVOT\]/, script_body)
    assert_match(/\[INSIGHT\]/, script_body)
    assert_match(/\[MEMORY-HIT\]/, script_body)
    assert_match(/\[MEMORY-MISS\]/, script_body)
    assert_match(/\[USER-CORRECTION\]/, script_body)
    assert_match(/\[BLOCKED\]/, script_body)
  end

  def test_context_mentions_summary_requirement
    assert_match(/Summary/, script_body)
  end

  # --- Bash 3.2 safety ---

  def test_no_heredoc_inside_command_substitution
    refute_match(/\$\(.*<</, script_body)
  end

  # --- Task extraction ---

  def test_extracts_task_id_from_branch
    assert_match(/CWS-/, script_body)
  end
end
