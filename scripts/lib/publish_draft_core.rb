#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"

module PublishDraft
  module_function

  def run(argv)
    repo_root = File.expand_path("../..", __dir__)
    Dir.chdir(repo_root)

    draft_path = ENV.fetch("DRAFT_PATH", argv[0].to_s)
    publish_date = ENV.fetch("DATE", argv[1].to_s)
    slug_override = ENV.fetch("SLUG", argv[2].to_s)
    keep_draft = ENV["KEEP_DRAFT"].to_s == "1"

    usage! if draft_path.empty? || publish_date.empty?
    date_format!(publish_date)
    draft_path_guard!(repo_root, draft_path)

    run_script!(File.join(repo_root, "scripts", "qa-publish.sh"), draft_path)

    target_path = create_post(repo_root, draft_path, publish_date, slug_override)

    run_script!(
      File.join(repo_root, ".agents", "skills", "jekyll-post-publisher", "scripts", "validate-post.sh"),
      target_path,
      { "STRICT_POST_METADATA" => "1" }
    )

    if keep_draft
      puts "kept source draft: #{draft_path}"
    else
      draft_path_guard!(repo_root, draft_path)
      File.delete(draft_path)
      puts "deleted source draft: #{draft_path}"
    end

    puts "published draft to: #{target_path}"
    puts "next: make qa-local"
  end

  def usage!
    abort("usage: make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD [KEEP_DRAFT=1]")
  end

  def date_format!(publish_date)
    return if publish_date.match?(/^\d{4}-\d{2}-\d{2}$/)

    abort("error: DATE must be in YYYY-MM-DD format")
  end

  def draft_path_guard!(repo_root, draft_path)
    draft_root = File.join(repo_root, "_drafts")
    expanded = File.expand_path(draft_path, repo_root)
    return if expanded.start_with?("#{draft_root}/")

    abort("error: publish-draft only supports files under _drafts/")
  end

  def run_script!(script_path, path_arg, extra_env = {})
    success = system(extra_env, script_path, path_arg)
    return if success

    status = $?.exitstatus || 1
    exit(status)
  end

  def create_post(repo_root, draft_path, publish_date, slug_override)
    content = File.read(draft_path)
    match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
    abort("error: missing YAML front matter in #{draft_path}") unless match

    data = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
    body = content.sub(match[0], "")

    slug = if !slug_override.empty?
      slug_override
    else
      data.fetch("title").to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").gsub(/-+/, "-")
    end
    abort("error: could not derive a slug from #{draft_path}") if slug.empty?

    data["date"] = publish_date
    yaml = YAML.dump(data).sub(/\A---\s*\n/, "").sub(/\n\.\.\.\s*\z/, "")
    expanded_draft_path = File.expand_path(draft_path, repo_root)
    target_path = File.expand_path(File.join(File.dirname(expanded_draft_path), "..", "_posts", "#{publish_date}-#{slug}.md"))
    abort("error: target post already exists: #{target_path}") if File.exist?(target_path)

    File.write(target_path, "---\n#{yaml}---\n\n#{body}")
    target_path
  end
end
