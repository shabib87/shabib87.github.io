#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/lib/tooling.sh"

pre_commit_bin="$(require_repo_pre_commit)"

"$pre_commit_bin" install --hook-type pre-commit --hook-type pre-push
"$pre_commit_bin" install-hooks

cat <<'EOF'
Installed git hooks.

Useful commands:
- make qa-local
- ./.venv-tools/bin/pre-commit run --all-files
- ./.venv-tools/bin/pre-commit run --hook-stage pre-push --all-files
EOF
