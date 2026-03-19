#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class StartBranchTrackingTest < Minitest::Test
  START_WORK_SCRIPT_PATH = File.expand_path("../start-work.sh", __dir__)
  START_PHASE_SCRIPT_PATH = File.expand_path("../start-phase.sh", __dir__)

  def start_work_body
    @start_work_body ||= File.read(START_WORK_SCRIPT_PATH)
  end

  def start_phase_body
    @start_phase_body ||= File.read(START_PHASE_SCRIPT_PATH)
  end

  def test_start_work_tracks_graphite_parent_main_when_gt_available
    assert_match(/if command -v gt >/, start_work_body)
    assert_match(/gt track --parent "main"/, start_work_body)
    assert_match(/failed to track branch in Graphite with parent=main/, start_work_body)
  end

  def test_start_phase_tracks_graphite_parent_base_branch_when_gt_available
    assert_match(/if command -v gt >/, start_phase_body)
    assert_match(/gt track --parent "\$base_branch"/, start_phase_body)
    assert_match(/failed to track phase branch in Graphite with parent=\$base_branch/, start_phase_body)
  end
end
