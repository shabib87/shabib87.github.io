#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

source_input="${SOURCE:-${1:-}}"
name="${NAME:-${2:-}}"
ref="${REF:-main}"

if [[ -z "$source_input" ]]; then
  echo "error: provide SOURCE or pass it as the first argument" >&2
  exit 1
fi

temp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$temp_dir"
}
trap cleanup EXIT

local_path=""
upstream_url="$source_input"

if [[ -d "$source_input" ]]; then
  local_path="$source_input"
  [[ -n "$name" ]] || name="$(basename "$source_input")"
elif [[ "$source_input" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
  owner="${BASH_REMATCH[1]}"
  repo="${BASH_REMATCH[2]}"
  ref="${BASH_REMATCH[3]}"
  skill_path="${BASH_REMATCH[4]}"
  [[ -n "$name" ]] || name="$(basename "$skill_path")"
  git clone --depth 1 --branch "$ref" --filter=blob:none --sparse "https://github.com/$owner/$repo.git" "$temp_dir/repo" >/dev/null 2>&1
  (
    cd "$temp_dir/repo"
    git sparse-checkout set "$skill_path" >/dev/null 2>&1
  )
  local_path="$temp_dir/repo/$skill_path"
else
  echo "error: SOURCE must be a local path or a GitHub tree URL" >&2
  exit 1
fi

target_dir="$repo_root/.agents/skills/$name"
if [[ -e "$target_dir" ]]; then
  echo "error: target already exists: $target_dir" >&2
  exit 1
fi

cp -R "$local_path" "$target_dir"

ruby <<'RUBY' "$repo_root/.codex/manifests/external-skills.lock.yml" "$name" "$upstream_url" "$ref"
require "yaml"

manifest_path, name, upstream_url, ref = ARGV
manifest = YAML.load_file(manifest_path) || {}
manifest["skills"] ||= []
manifest["skills"] << {
  "name" => name,
  "upstream_url" => upstream_url,
  "upstream_ref" => ref,
  "review_status" => "approved",
  "imported_at" => Time.now.utc.strftime("%Y-%m-%d"),
  "rationale" => "Vendored via scripts/vendor-skill.sh",
  "local_path" => ".agents/skills/#{name}",
  "notes" => ""
}
File.write(manifest_path, YAML.dump(manifest))
RUBY

echo "vendored skill into .agents/skills/$name"
