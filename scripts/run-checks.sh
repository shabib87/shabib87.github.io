#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"

export BUNDLE_PATH="$repo_root/vendor/bundle"
export BUNDLE_FROZEN="true"

validator="$repo_root/.agents/skills/jekyll-post-publisher/scripts/validate-post.sh"

common_ancestor="$(repo_common_ancestor)"
tracked_changed="$(if [[ -n "$common_ancestor" ]]; then git diff --name-only --diff-filter=ACMR "$common_ancestor"...HEAD -- '_posts/*.md'; fi)"
untracked_changed="$(git ls-files --others --exclude-standard -- '_posts/*.md')"

while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  "$validator" "$file"
done < <(printf '%s\n%s\n' "$tracked_changed" "$untracked_changed" | awk 'NF' | sort -u)

if ! bundle check >/dev/null 2>&1; then
  echo "error: bundle dependencies are missing. Run: bundle install" >&2
  exit 1
fi

bundle exec jekyll build
