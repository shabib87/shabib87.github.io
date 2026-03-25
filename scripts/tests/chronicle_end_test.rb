#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class ChronicleEndTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../../.claude/hooks/chronicle-end.sh", __dir__)

  def script_body
    @script_body ||= begin
      assert File.exist?(SCRIPT_PATH), "chronicle-end.sh must exist at #{SCRIPT_PATH}"
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

  # --- Independent path derivation ---

  def test_derives_project_dir_independently
    assert_match(/PWD/, script_body)
    # Must NOT rely on CHRONICLE_PATH env var
    refute_match(/\$CHRONICLE_PATH/, script_body)
    refute_match(/\$\{CHRONICLE_PATH/, script_body)
  end

  def test_derives_branch_slug
    assert_match(/git rev-parse --abbrev-ref HEAD/, script_body)
  end

  # --- Graceful exit when nothing to do ---

  def test_exits_cleanly_when_no_chronicle_dir
    assert_match(/exit 0/, script_body)
  end

  # --- Event detection ---

  def test_counts_events
    assert_match(/grep -c/, script_body)
    # Pattern must handle both "- [TAG]" and "- HH:MM [TAG]" formats
    assert_match(/\^\- \.\*\\\[/, script_body)
  end

  # --- Summary generation ---

  def test_checks_for_existing_summary
    assert_match(/Summary/, script_body)
  end

  def test_generates_auto_summary
    assert_match(/Auto-generated/, script_body)
  end

  def test_counts_individual_categories
    assert_match(/DECISION/, script_body)
    assert_match(/ERROR/, script_body)
    assert_match(/PIVOT/, script_body)
    assert_match(/INSIGHT/, script_body)
  end

  # --- Bash 3.2 safety ---

  def test_no_heredoc_inside_command_substitution
    refute_match(/\$\(.*<</, script_body)
  end
end
