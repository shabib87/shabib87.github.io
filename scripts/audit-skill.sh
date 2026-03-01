#!/usr/bin/env bash
set -euo pipefail

name="${NAME:-${1:-}}"
source_url="${SOURCE:-${2:-}}"

if [[ -z "$name" ]]; then
  echo "error: provide NAME or pass it as the first argument" >&2
  exit 1
fi

cat <<EOF
Skill audit template: $name

- Source: ${source_url:-"(not provided)"}
- Fit for this repo's writing workflow:
- Overlap with existing repo-local skills:
- Hidden dependencies or auth requirements:
- Maintenance burden:
- Needs official-doc verification:
- Recommendation: vendor / adapt / reject
EOF
