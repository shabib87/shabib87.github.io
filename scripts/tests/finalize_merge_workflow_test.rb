#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class FinalizeMergeWorkflowTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../finalize-merge.sh", __dir__)

  def script_body
    @script_body ||= File.read(SCRIPT_PATH)
  end

  def test_allows_rollout_stack_base_branches
    assert_match(/base_is_stack_branch = task_branch_pattern\.match\?\(base_ref\)/, script_body)
    assert_includes(script_body, "or a rollout stack branch")
  end

  def test_still_merges_with_rebase_and_deletes_branch
    assert_match(/gh_or_curl_pr_merge "\$pr" rebase/, script_body)
  end

  def test_self_review_checklist_prints_pr_base_branch
    assert_match(/- base branch: \$base_ref_name/, script_body)
  end

  def test_prompt_targets_pr_base_for_single_pr_merge
    assert_match(/Integrate this PR into %s via GitHub rebase merge \(single PR only\)\? \[y\/N\]/, script_body)
  end

  def test_stack_note_points_to_graphite_stack_merge
    assert_includes(script_body, "to merge the full stack, use Graphite web \"Merge stack\" or run: gt merge")
  end

  def test_does_not_gate_on_task_file_status_text
    refute_match(/task file status/i, script_body)
    refute_match(/Completion Evidence/, script_body)
  end

  def test_accepts_yes_flag_for_non_interactive_mode
    assert_match(/--yes\|--no-interactive\) non_interactive=1/, script_body)
    assert_match(/non_interactive="\$\{YES:-\}"/, script_body)
  end

  def test_accepts_stack_flag_for_stack_merge
    assert_match(/--stack\) stack_mode=1/, script_body)
    assert_match(/stack_mode="\$\{STACK:-\}"/, script_body)
  end

  def test_uses_fallback_library_for_pr_view
    assert_match(/gh_or_curl_pr_view "\$pr"/, script_body)
  end

  def test_sources_github_api_library
    assert_match(%r{scripts/lib/github-api\.sh}, script_body)
  end

  def test_uses_fallback_auth_check
    assert_match(/_gh_available/, script_body)
    assert_match(/_github_resolve_token/, script_body)
  end

  def test_stack_mode_uses_gt_merge
    assert_match(/gt merge/, script_body)
  end
end
