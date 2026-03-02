#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"

pre_commit_bin="$(require_repo_pre_commit)"
export SEMGREP_ENABLE_VERSION_CHECK=0
export SEMGREP_SEND_METRICS=off
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/tmp/semgrep-state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/semgrep-state}"
export SEMGREP_LOG_FILE="${SEMGREP_LOG_FILE:-/tmp/semgrep-state/semgrep.log}"
export SEMGREP_SETTINGS_FILE="${SEMGREP_SETTINGS_FILE:-/tmp/semgrep-state/settings.yml}"
export SEMGREP_VERSION_CACHE_PATH="${SEMGREP_VERSION_CACHE_PATH:-/tmp/semgrep-state/version-cache}"

mkdir -p "${XDG_CONFIG_HOME}" "${XDG_CACHE_HOME}"

"$pre_commit_bin" run semgrep --all-files
