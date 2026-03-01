#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

. "$repo_root/scripts/lib/tooling.sh"

draft_path="${DRAFT_PATH:-${1:-}}"

if [[ -z "$draft_path" ]]; then
  echo "error: provide PATH=_drafts/your-post.md or pass the path as the first argument" >&2
  exit 1
fi

if [[ ! -f "$draft_path" ]]; then
  echo "error: draft file not found: $draft_path" >&2
  exit 1
fi

case "$draft_path" in
  _drafts/*|./_drafts/*|"${repo_root}/_drafts/"*)
    ;;
  *)
    echo "error: draft validation only supports files under _drafts/" >&2
    exit 1
    ;;
esac

"$repo_root/.agents/skills/jekyll-post-publisher/scripts/validate-post.sh" "$draft_path"

if grep -Ein '\b(TODO|TBD|FIXME)\b|lorem ipsum' "$draft_path" >/dev/null 2>&1; then
  echo "error: unresolved placeholders found in $draft_path" >&2
  grep -Ein '\b(TODO|TBD|FIXME)\b|lorem ipsum' "$draft_path" >&2 || true
  exit 1
fi

pre_commit_bin="$(require_repo_pre_commit)"

"$pre_commit_bin" run markdownlint-cli2 --files "$draft_path"

echo "draft validation passed: $draft_path"
