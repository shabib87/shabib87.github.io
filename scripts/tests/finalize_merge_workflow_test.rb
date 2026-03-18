#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class FinalizeMergeWorkflowTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../finalize-merge.sh", __dir__)

  def script_body
    @script_body ||= File.read(SCRIPT_PATH)
  end

  def test_allows_rollout_stack_base_branches
    assert_match(/base_is_stack_branch = task_branch_pattern\.match\?\(base_ref\) \|\| phase_branch_pattern\.match\?\(base_ref\)/, script_body)
    assert_includes(script_body, "or a rollout stack branch")
  end

  def test_still_merges_with_rebase_and_deletes_branch
    assert_match(/gh pr merge "\$pr" --rebase --delete-branch/, script_body)
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
end
