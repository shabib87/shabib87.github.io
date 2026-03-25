#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class SessionRetroSkillTest < Minitest::Test
  SKILL_DIR = File.expand_path("../../.agents/skills/session-retro", __dir__)
  SKILL_PATH = File.join(SKILL_DIR, "SKILL.md")
  REFS_DIR = File.join(SKILL_DIR, "references")

  def skill_body
    @skill_body ||= begin
      assert File.exist?(SKILL_PATH), "SKILL.md must exist at #{SKILL_PATH}"
      File.read(SKILL_PATH)
    end
  end

  def test_skill_file_exists
    assert File.exist?(SKILL_PATH)
  end

  def test_chronicle_format_reference_exists
    assert File.exist?(File.join(REFS_DIR, "chronicle-format.md"))
  end

  def test_memory_update_protocol_reference_exists
    assert File.exist?(File.join(REFS_DIR, "memory-update-protocol.md"))
  end

  def test_narrative_template_reference_exists
    assert File.exist?(File.join(REFS_DIR, "narrative-template.md"))
  end

  def test_has_name_field
    assert_match(/^name: session-retro$/, skill_body)
  end

  def test_has_description_field
    assert_match(/^description:/, skill_body)
  end

  def test_has_allowed_tools
    assert_match(/^allowed-tools:/, skill_body)
  end

  def test_disables_model_invocation
    assert_match(/^disable-model-invocation: true$/, skill_body)
  end

  def test_references_all_eight_event_tags
    %w[DECISION ERROR PIVOT INSIGHT MEMORY-HIT MEMORY-MISS USER-CORRECTION BLOCKED].each do |tag|
      assert_match(/\[#{Regexp.escape(tag)}\]/, skill_body, "Missing event tag: [#{tag}]")
    end
  end

  def test_references_memory_update_protocol
    assert_match(/memory-update-protocol/, skill_body)
  end

  def test_references_narrative_template
    assert_match(/narrative-template/, skill_body)
  end

  def test_warns_against_auto_applying_memory
    assert_match(/human|approval|approve/i, skill_body)
  end
end
