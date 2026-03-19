#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

ruby "$repo_root/scripts/tests/rollout_governance_test.rb"
ruby "$repo_root/scripts/tests/create_pr_workflow_test.rb"
ruby "$repo_root/scripts/tests/start_branch_tracking_test.rb"
