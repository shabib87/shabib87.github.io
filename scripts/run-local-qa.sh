#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"

run_step() {
  local label="$1"
  shift
  echo "==> $label"
  "$@"
}

run_step "Linting repo automation and docs" make lint
run_step "Running security checks" make security
run_step "Validating Codex skills, prompts, and docs" make codex-check
run_step "Running site SEO audit" make site-audit AUDIT=seo TARGET=site
run_step "Running site quality audit" make site-audit AUDIT=quality TARGET=site
run_step "Running site maintenance audit" make site-audit AUDIT=maintenance TARGET=site
run_step "Running tracked repo validation" make check

site_changes="$(repo_site_facing_changes)"
if [[ -n "$site_changes" ]]; then
  cat <<EOF
Manual preview required before commit because site-facing files changed:
$site_changes

Preview flow:
1. bundle exec jekyll serve
2. Open the affected pages in the browser
3. Spot-check layout, metadata-sensitive pages, and navigation
4. Commit only after the preview is clean
EOF
fi

echo "local QA gate passed"
