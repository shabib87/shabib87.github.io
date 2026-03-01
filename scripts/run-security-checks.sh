#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"

pre_commit_bin="$(require_repo_pre_commit)"
export SEMGREP_ENABLE_VERSION_CHECK=0
export SEMGREP_SEND_METRICS=off

semgrep_targets=()

if command -v rg >/dev/null 2>&1; then
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    semgrep_targets+=("$target")
  done < <(rg --files scripts .agents .github/workflows -g '*.sh' -g '*.yml' -g '*.yaml')
else
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    semgrep_targets+=("${target#./}")
  done < <(
    find scripts .agents .github/workflows \
      \( -name '*.sh' -o -name '*.yml' -o -name '*.yaml' \) \
      -type f \
      | sort
  )
fi

semgrep_targets=(.semgrep.yml "${semgrep_targets[@]}")

"$pre_commit_bin" run semgrep --files "${semgrep_targets[@]}"
