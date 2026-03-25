# Session Chronicle & Self-Improvement Loop (CWS-96) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build infrastructure to capture structured session events (errors, pivots, decisions, insights) in real-time for blog research and self-improvement, enforced via Claude Code hooks and a manual retrospective skill.

**Architecture:** Defense-in-depth — SessionStart hook creates the chronicle file and injects a context reminder on every session event (startup, resume, compact, clear). Claude logs events in real-time per AGENTS.md contract. SessionEnd hook writes a machine summary safety net. `/session-retro` skill provides deep analysis with human-approved memory updates. Chronicle files live in `~/.claude/projects/<project-dir>/chronicle/` (private, not in repo).

**Tech Stack:** Bash (hooks), Ruby (Minitest tests), Markdown (skill docs, AGENTS.md, spec)

**Spec:** `docs/superpowers/specs/2026-03-24-session-chronicle-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `docs/superpowers/specs/2026-03-24-session-chronicle-design.md` | Create (copy from `/private/tmp/claude-501/`) | Design spec |
| `docs/tasks/CWS-96.md` | Create | Task context snapshot |
| `AGENTS.md` | Modify (after line 143, before ## Instruction-Based) | Add `## Session Chronicle` section |
| `.claude/settings.json` | Modify | Add chronicle hook config entries |
| `.claude/hooks/chronicle-init.sh` | Create | SessionStart hook — create file, inject context |
| `.claude/hooks/chronicle-end.sh` | Create | SessionEnd hook — machine summary safety net |
| `scripts/tests/chronicle_init_test.rb` | Create | TDD tests for SessionStart hook |
| `scripts/tests/chronicle_end_test.rb` | Create | TDD tests for SessionEnd hook |
| `scripts/tests/session_retro_skill_test.rb` | Create | TDD tests for /session-retro skill |
| `.claude/skills/session-retro/SKILL.md` | Create | `/session-retro` skill definition |
| `.claude/skills/session-retro/references/chronicle-format.md` | Create | Chronicle schema reference |
| `.claude/skills/session-retro/references/memory-update-protocol.md` | Create | Memory update rules |
| `.claude/skills/session-retro/references/narrative-template.md` | Create | Blog narrative template |

## Stacked PR Strategy

```
PR 1: Foundation (cws/96-session-chronicle)          ← base branch from main
├── PR 2: SessionStart hook (cws/96-chronicle-init)  ← branches from PR 1
├── PR 3: SessionEnd hook (cws/96-chronicle-end)     ← branches from PR 1
└── PR 4: /session-retro skill (cws/96-session-retro) ← branches from PR 1
```

PRs 2-4 are independent of each other. After PR 1 is committed, PRs 2-4 can be implemented in parallel via subagent dispatch.

---

## Task 1: Branch setup and foundation files (PR 1)

**Files:**
- Create: `docs/superpowers/specs/2026-03-24-session-chronicle-design.md`
- Create: `docs/tasks/CWS-96.md`

- [ ] **Step 1: Create branch from main**

```bash
git checkout main && git pull
gt create cws/96-session-chronicle -a -m "chore(cws-96): foundation — spec, task file, AGENTS.md, hook config"
```

- [ ] **Step 2: Copy spec from backup**

```bash
cp /private/tmp/claude-501/2026-03-24-session-chronicle-design.md docs/superpowers/specs/
```

Verify: `head -5 docs/superpowers/specs/2026-03-24-session-chronicle-design.md` should show the `# Design: Session Chronicle` header.

- [ ] **Step 3: Create task file**

Create `docs/tasks/CWS-96.md`:

```markdown
# CWS-96: Session chronicle & self-improvement loop

- **Linear:** [CWS-96](https://linear.app/codewithshabib/issue/CWS-96)
- **Branch:** `cws/96-session-chronicle`
- **Priority:** Urgent
- **Type:** infra

## Context

Claude Code sessions are ephemeral — learnings evaporate between sessions. The memory system
is reactive rather than proactive. Mistakes repeat because feedback memories aren't reliably
enforced.

## Scope

1. SessionStart hook (`chronicle-init.sh`) — creates chronicle file, injects context reminder
2. SessionEnd hook (`chronicle-end.sh`) — machine-generated summary safety net
3. `/session-retro` skill — deep retrospective with memory update proposals
4. AGENTS.md `## Session Chronicle` section — contract for event logging
5. Hook configuration in `.claude/settings.json`

## Acceptance Criteria

- SessionStart hook creates `~/.claude/projects/<project-dir>/chronicle/YYYY-MM-DD-<branch>.md`
  with correct frontmatter on startup, resume, compact, and clear events
- SessionEnd hook appends machine summary when `## Summary` section is empty
- `/session-retro` appears in Claude Code skill menu
- AGENTS.md documents the 8 event taxonomy tags
- `make qa-local` passes
```

- [ ] **Step 4: Commit foundation files**

```bash
git add docs/superpowers/specs/2026-03-24-session-chronicle-design.md docs/tasks/CWS-96.md
git commit -m "docs(cws-96): add design spec and task file"
```

---

## Task 2: Add Session Chronicle section to AGENTS.md (PR 1)

**Files:**
- Modify: `AGENTS.md` (insert after the code quality principles block, before `## Instruction-Based Boundary Caveat`)

- [ ] **Step 1: Add the Session Chronicle section**

Insert after line 143 (after the YAGNI bullet, before the blank line preceding `## Instruction-Based Boundary Caveat`):

```markdown

## Session Chronicle

- Log notable events to the chronicle file in real-time during sessions.
- Use only these tags: `[DECISION]`, `[ERROR]`, `[PIVOT]`, `[INSIGHT]`,
  `[MEMORY-HIT]`, `[MEMORY-MISS]`, `[USER-CORRECTION]`, `[BLOCKED]`.
- Each event is one line: `- [TAG] brief description`.
  Add indented detail lines only when the rationale is not obvious.
  Optional timestamp prefix: `- HH:MM [TAG] description`.
- Write a `## Summary` section before ending substantive sessions.
- The SessionStart hook creates the chronicle file and injects its path.
- Invoke `/session-retro` for deep retrospective on meaningful sessions.
- Do not log routine actions (file reads, tool calls, simple edits).
  Log decisions, failures, surprises, and corrections.
```

- [ ] **Step 2: Verify placement**

```bash
grep -n "## Session Chronicle" AGENTS.md
grep -n "## Instruction-Based" AGENTS.md
```

The Session Chronicle section should appear before the Instruction-Based Boundary Caveat section.

- [ ] **Step 3: Commit**

```bash
git add AGENTS.md
git commit -m "docs(cws-96): add Session Chronicle contract to AGENTS.md"
```

---

## Task 3: Add hook configuration to settings.json (PR 1)

**Files:**
- Modify: `.claude/settings.json`

The existing file has one SessionStart entry. We need to add the chronicle-init entry and a new SessionEnd section.

- [ ] **Step 1: Update settings.json**

Replace the entire file content with:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/check-agent-context-staleness.sh"
          }
        ]
      },
      {
        "matcher": "startup|resume|compact|clear",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/chronicle-init.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/chronicle-end.sh"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Validate JSON**

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('valid')"
```

Expected: `valid`

- [ ] **Step 3: Commit**

```bash
git add .claude/settings.json
git commit -m "config(cws-96): register chronicle hooks in settings.json"
```

---

## Task 4: Create PR 1 (Foundation)

- [ ] **Step 1: Run qa-local**

```bash
make qa-local
```

Expected: pass (no code changes, only docs and config)

- [ ] **Step 2: Create PR**

```bash
make create-pr TYPE=infra
```

PR title: `chore(cws-96): foundation — spec, task file, AGENTS.md chronicle section, hook config`

---

## Task 5: Write failing tests for chronicle-init.sh (PR 2 — TDD red phase)

**Files:**
- Create: `scripts/tests/chronicle_init_test.rb`

This follows the repo's existing test pattern: static analysis of script body via `assert_match` / `refute_match` on the script source (see `scripts/tests/create_pr_workflow_test.rb`).

- [ ] **Step 1: Create branch for PR 2**

```bash
gt create cws/96-chronicle-init -a -m "feat(cws-96): SessionStart chronicle hook"
```

- [ ] **Step 2: Write the test file**

Create `scripts/tests/chronicle_init_test.rb`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class ChronicleInitTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../../.claude/hooks/chronicle-init.sh", __dir__)

  def script_body
    @script_body ||= begin
      assert File.exist?(SCRIPT_PATH), "chronicle-init.sh must exist at #{SCRIPT_PATH}"
      File.read(SCRIPT_PATH)
    end
  end

  # --- Fail-closed safety ---

  def test_uses_strict_mode
    assert_match(/^set -euo pipefail$/, script_body)
  end

  def test_traps_err_to_exit_2
    assert_match(/trap .* ERR/, script_body)
    assert_match(/exit 2/, script_body)
  end

  # --- Input parsing ---

  def test_reads_session_id_from_stdin_json
    assert_match(/jq\b.*session_id/, script_body)
  end

  def test_reads_source_from_stdin_json
    assert_match(/jq\b.*source/, script_body)
  end

  def test_fails_on_missing_session_id
    assert_match(/session_id/, script_body)
    assert_match(/exit 2/, script_body)
  end

  # --- Path derivation ---

  def test_derives_project_dir_from_pwd
    assert_match(/sed.*s\|\/\|-\|g/, script_body)
  end

  def test_creates_chronicle_directory
    assert_match(/mkdir -p/, script_body)
  end

  def test_derives_branch_slug
    assert_match(/git rev-parse --abbrev-ref HEAD/, script_body)
    assert_match(/tr '?\/'? '?-'?/, script_body)
  end

  # --- File creation ---

  def test_writes_frontmatter_with_session_id
    assert_match(/session_id:/, script_body)
  end

  def test_writes_frontmatter_with_date
    assert_match(/date:/, script_body)
  end

  def test_writes_frontmatter_with_branch
    assert_match(/branch:/, script_body)
  end

  def test_writes_events_header
    assert_match(/## Events/, script_body)
  end

  def test_writes_summary_header
    assert_match(/## Summary/, script_body)
  end

  # --- Session reuse logic ---

  def test_reuses_file_on_resume
    assert_match(/resume/, script_body)
  end

  def test_reuses_file_on_compact
    assert_match(/compact/, script_body)
  end

  def test_creates_suffixed_file_for_new_session
    assert_match(/-[0-9]/, script_body)
  end

  # --- Environment variable export ---

  def test_sets_chronicle_path_via_env_file
    assert_match(/CLAUDE_ENV_FILE/, script_body)
    assert_match(/CHRONICLE_PATH=/, script_body)
  end

  # --- JSON output ---

  def test_outputs_hook_specific_json
    assert_match(/hookSpecificOutput/, script_body)
    assert_match(/hookEventName/, script_body)
    assert_match(/SessionStart/, script_body)
    assert_match(/additionalContext/, script_body)
  end

  def test_context_includes_event_tags
    assert_match(/\[DECISION\]/, script_body)
    assert_match(/\[ERROR\]/, script_body)
    assert_match(/\[PIVOT\]/, script_body)
    assert_match(/\[INSIGHT\]/, script_body)
    assert_match(/\[MEMORY-HIT\]/, script_body)
    assert_match(/\[MEMORY-MISS\]/, script_body)
    assert_match(/\[USER-CORRECTION\]/, script_body)
    assert_match(/\[BLOCKED\]/, script_body)
  end

  def test_context_mentions_summary_requirement
    assert_match(/Summary/, script_body)
  end

  # --- Bash 3.2 safety ---

  def test_no_heredoc_inside_command_substitution
    # Bare heredocs are safe; heredocs inside $() break bash 3.2
    refute_match(/\$\(.*<</, script_body)
  end

  # --- Task extraction ---

  def test_extracts_task_id_from_branch
    assert_match(/CWS-/, script_body)
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
ruby scripts/tests/chronicle_init_test.rb
```

Expected: FAIL — `chronicle-init.sh must exist` (file doesn't exist yet)

- [ ] **Step 4: Commit failing tests**

```bash
git add scripts/tests/chronicle_init_test.rb
git commit -m "test(cws-96): add failing tests for chronicle-init.sh (TDD red)"
```

---

## Task 6: Implement chronicle-init.sh (PR 2 — TDD green phase)

**Files:**
- Create: `.claude/hooks/chronicle-init.sh`

- [ ] **Step 1: Write the hook script**

Create `.claude/hooks/chronicle-init.sh`:

```bash
#!/usr/bin/env bash
# SessionStart hook: initialize session chronicle file.
# Registered in .claude/settings.json under hooks.SessionStart.
# Matcher: startup|resume|compact|clear
# Fail-closed: exit 2 on error (block execution), never fail-open.
set -euo pipefail
trap 'exit 2' ERR

# --- Read input from stdin ---
input="$(cat)"
session_id="$(echo "$input" | jq -r '.session_id // empty')"
source_event="$(echo "$input" | jq -r '.source // empty')"

if [[ -z "$session_id" ]]; then
  echo "error: no session_id in SessionStart input" >&2
  exit 2
fi

# --- Derive chronicle file path ---
project_dir_name="$(echo "$PWD" | sed 's|/|-|g')"
chronicle_dir="$HOME/.claude/projects/$project_dir_name/chronicle"
mkdir -p "$chronicle_dir"

today="$(date +%Y-%m-%d)"
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")"
branch_slug="$(echo "$branch" | tr '/' '-')"
base_name="${today}-${branch_slug}"
chronicle_file="$chronicle_dir/${base_name}.md"

# --- Determine reuse vs create ---
if [[ -f "$chronicle_file" ]]; then
  if [[ "$source_event" == "resume" || "$source_event" == "compact" ]]; then
    # Always reuse on resume/compact — same session continuing
    :
  else
    # startup or clear — compare session_id to detect new session
    existing_id="$(sed -n 's/^session_id: *//p' "$chronicle_file" | head -1)"
    if [[ "$existing_id" != "$session_id" ]]; then
      # Different session same day same branch — suffix the filename
      suffix=2
      while [[ -f "$chronicle_dir/${base_name}-${suffix}.md" ]]; do
        suffix=$((suffix + 1))
      done
      chronicle_file="$chronicle_dir/${base_name}-${suffix}.md"
    fi
  fi
fi

# --- Create new chronicle file if needed ---
if [[ ! -f "$chronicle_file" ]]; then
  task=""
  if [[ "$branch" =~ cws/([0-9]+) ]]; then
    task="CWS-${BASH_REMATCH[1]}"
  fi

  cat > "$chronicle_file" <<FRONTMATTER
---
session_id: ${session_id}
date: ${today}
branch: ${branch}
task: ${task}
started: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

## Events

## Summary
FRONTMATTER
fi

# --- Export path for Claude's in-session use ---
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  echo "CHRONICLE_PATH=$chronicle_file" >> "$CLAUDE_ENV_FILE"
fi

# --- Output context injection ---
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Session chronicle active at ${chronicle_file}.\nLog notable events: [DECISION], [ERROR], [PIVOT], [INSIGHT], [MEMORY-HIT], [MEMORY-MISS], [USER-CORRECTION], [BLOCKED].\nWrite a ## Summary before ending substantive sessions.\nDo NOT log routine actions — only decisions, failures, surprises, and corrections."
  }
}
EOF
```

- [ ] **Step 2: Make executable**

```bash
chmod +x .claude/hooks/chronicle-init.sh
```

- [ ] **Step 3: Run tests to verify they pass**

```bash
ruby scripts/tests/chronicle_init_test.rb
```

Expected: all tests PASS

- [ ] **Step 4: Commit implementation**

```bash
git add .claude/hooks/chronicle-init.sh
git commit -m "feat(cws-96): implement chronicle-init.sh SessionStart hook"
```

---

## Task 7: Create PR 2 (SessionStart hook)

- [ ] **Step 1: Run qa-local**

```bash
make qa-local
```

- [ ] **Step 2: Create PR**

```bash
make create-pr TYPE=feat
```

PR title: `feat(cws-96): SessionStart chronicle hook`

---

## Task 8: Write failing tests for chronicle-end.sh (PR 3 — TDD red phase)

**Files:**
- Create: `scripts/tests/chronicle_end_test.rb`

- [ ] **Step 1: Create branch for PR 3 (from PR 1, not PR 2)**

```bash
gt checkout cws/96-session-chronicle
gt create cws/96-chronicle-end -a -m "feat(cws-96): SessionEnd chronicle hook"
```

- [ ] **Step 2: Write the test file**

Create `scripts/tests/chronicle_end_test.rb`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class ChronicleEndTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../../.claude/hooks/chronicle-end.sh", __dir__)

  def script_body
    @script_body ||= begin
      assert File.exist?(SCRIPT_PATH), "chronicle-end.sh must exist at #{SCRIPT_PATH}"
      File.read(SCRIPT_PATH)
    end
  end

  # --- Fail-closed safety ---

  def test_uses_strict_mode
    assert_match(/^set -euo pipefail$/, script_body)
  end

  def test_traps_err_to_exit_2
    assert_match(/trap .* ERR/, script_body)
    assert_match(/exit 2/, script_body)
  end

  # --- Independent path derivation ---

  def test_derives_project_dir_independently
    assert_match(/sed.*s\|\/\|-\|g/, script_body)
    # Must NOT rely on CHRONICLE_PATH env var
    refute_match(/\$CHRONICLE_PATH/, script_body)
    refute_match(/\$\{CHRONICLE_PATH/, script_body)
  end

  def test_derives_branch_slug
    assert_match(/git rev-parse --abbrev-ref HEAD/, script_body)
    assert_match(/tr '?\/'? '?-'?/, script_body)
  end

  # --- Graceful exit when nothing to do ---

  def test_exits_cleanly_when_no_chronicle_dir
    assert_match(/exit 0/, script_body)
  end

  # --- Event detection ---

  def test_counts_events
    assert_match(/grep -c/, script_body)
    # Pattern must handle both "- [TAG]" and "- HH:MM [TAG]" formats
    assert_match(/\^\- \.\*\\\[/, script_body)
  end

  # --- Summary generation ---

  def test_checks_for_existing_summary
    assert_match(/Summary/, script_body)
  end

  def test_generates_auto_summary
    assert_match(/Auto-generated/, script_body)
  end

  def test_counts_individual_categories
    assert_match(/DECISION/, script_body)
    assert_match(/ERROR/, script_body)
    assert_match(/PIVOT/, script_body)
    assert_match(/INSIGHT/, script_body)
  end

  # --- Bash 3.2 safety ---

  def test_no_heredoc_inside_command_substitution
    refute_match(/\$\(.*<</, script_body)
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
ruby scripts/tests/chronicle_end_test.rb
```

Expected: FAIL — `chronicle-end.sh must exist`

- [ ] **Step 4: Commit failing tests**

```bash
git add scripts/tests/chronicle_end_test.rb
git commit -m "test(cws-96): add failing tests for chronicle-end.sh (TDD red)"
```

---

## Task 9: Implement chronicle-end.sh (PR 3 — TDD green phase)

**Files:**
- Create: `.claude/hooks/chronicle-end.sh`

- [ ] **Step 1: Write the hook script**

Create `.claude/hooks/chronicle-end.sh`:

```bash
#!/usr/bin/env bash
# SessionEnd hook: append machine-generated summary if Claude forgot.
# Fire-and-forget — must complete quickly (<1.5s default timeout).
# Fail-closed: exit 2 on error, never fail-open.
set -euo pipefail
trap 'exit 2' ERR

# --- Derive path independently (CLAUDE_ENV_FILE not available in SessionEnd) ---
project_dir_name="$(echo "$PWD" | sed 's|/|-|g')"
chronicle_dir="$HOME/.claude/projects/$project_dir_name/chronicle"

if [[ ! -d "$chronicle_dir" ]]; then
  exit 0
fi

today="$(date +%Y-%m-%d)"
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")"
branch_slug="$(echo "$branch" | tr '/' '-')"

# Find today's chronicle file for this branch (most recently modified)
chronicle_file=""
for f in "$chronicle_dir/${today}-${branch_slug}"*.md; do
  [[ -f "$f" ]] || continue
  if [[ -z "$chronicle_file" || "$f" -nt "$chronicle_file" ]]; then
    chronicle_file="$f"
  fi
done

if [[ -z "$chronicle_file" ]]; then
  exit 0
fi

# Check if there are any events worth summarizing
# Pattern matches both "- [TAG]" and "- HH:MM [TAG]" (timestamped events)
event_count="$(grep -c '^- .*\[' "$chronicle_file" 2>/dev/null || echo "0")"
if [[ "$event_count" -eq 0 ]]; then
  exit 0
fi

# Check if summary already has content (any non-blank line after ## Summary)
has_summary=false
in_summary=false
while IFS= read -r line; do
  if [[ "$line" == "## Summary" ]]; then
    in_summary=true
    continue
  fi
  if $in_summary && [[ -n "$line" && ! "$line" =~ ^[[:space:]]*$ ]]; then
    has_summary=true
    break
  fi
done < "$chronicle_file"

if $has_summary; then
  exit 0
fi

# --- Count events by category ---
decisions="$(grep -c '^\- .*\[DECISION\]' "$chronicle_file" 2>/dev/null || echo "0")"
errors="$(grep -c '^\- .*\[ERROR\]' "$chronicle_file" 2>/dev/null || echo "0")"
pivots="$(grep -c '^\- .*\[PIVOT\]' "$chronicle_file" 2>/dev/null || echo "0")"
insights="$(grep -c '^\- .*\[INSIGHT\]' "$chronicle_file" 2>/dev/null || echo "0")"
mem_hits="$(grep -c '^\- .*\[MEMORY-HIT\]' "$chronicle_file" 2>/dev/null || echo "0")"
mem_misses="$(grep -c '^\- .*\[MEMORY-MISS\]' "$chronicle_file" 2>/dev/null || echo "0")"
corrections="$(grep -c '^\- .*\[USER-CORRECTION\]' "$chronicle_file" 2>/dev/null || echo "0")"
blocked="$(grep -c '^\- .*\[BLOCKED\]' "$chronicle_file" 2>/dev/null || echo "0")"

# --- Build summary ---
parts=()
[[ "$decisions" -gt 0 ]] && parts+=("${decisions} decision(s)")
[[ "$errors" -gt 0 ]] && parts+=("${errors} error(s)")
[[ "$pivots" -gt 0 ]] && parts+=("${pivots} pivot(s)")
[[ "$insights" -gt 0 ]] && parts+=("${insights} insight(s)")
[[ "$mem_hits" -gt 0 ]] && parts+=("${mem_hits} memory hit(s)")
[[ "$mem_misses" -gt 0 ]] && parts+=("${mem_misses} memory miss(es)")
[[ "$corrections" -gt 0 ]] && parts+=("${corrections} correction(s)")
[[ "$blocked" -gt 0 ]] && parts+=("${blocked} blocked")

summary_line="Auto-generated: ${event_count} events"
if [[ ${#parts[@]} -gt 0 ]]; then
  detail="$(IFS=', '; echo "${parts[*]}")"
  summary_line="${summary_line} (${detail})"
fi

# Append to file (## Summary is the last section, so appending to file = appending to summary)
printf '\n%s\n' "$summary_line" >> "$chronicle_file"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x .claude/hooks/chronicle-end.sh
```

- [ ] **Step 3: Run tests to verify they pass**

```bash
ruby scripts/tests/chronicle_end_test.rb
```

Expected: all tests PASS

- [ ] **Step 4: Commit implementation**

```bash
git add .claude/hooks/chronicle-end.sh
git commit -m "feat(cws-96): implement chronicle-end.sh SessionEnd hook"
```

---

## Task 10: Create PR 3 (SessionEnd hook)

- [ ] **Step 1: Run qa-local**

```bash
make qa-local
```

- [ ] **Step 2: Create PR**

```bash
make create-pr TYPE=feat
```

PR title: `feat(cws-96): SessionEnd chronicle hook`

---

## Task 11: Write failing tests and create /session-retro skill (PR 4 — TDD)

**Files:**
- Create: `scripts/tests/session_retro_skill_test.rb`
- Create: `.claude/skills/session-retro/SKILL.md`
- Create: `.claude/skills/session-retro/references/chronicle-format.md`
- Create: `.claude/skills/session-retro/references/memory-update-protocol.md`
- Create: `.claude/skills/session-retro/references/narrative-template.md`

- [ ] **Step 1: Create branch for PR 4 (from PR 1, not PR 2 or 3)**

```bash
gt checkout cws/96-session-chronicle
gt create cws/96-session-retro -a -m "feat(cws-96): /session-retro skill"
```

- [ ] **Step 2: Create skill directory**

```bash
mkdir -p .claude/skills/session-retro/references
```

- [ ] **Step 3: Write failing tests (TDD red phase)**

Create `scripts/tests/session_retro_skill_test.rb`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class SessionRetroSkillTest < Minitest::Test
  SKILL_DIR = File.expand_path("../../.claude/skills/session-retro", __dir__)
  SKILL_PATH = File.join(SKILL_DIR, "SKILL.md")
  REFS_DIR = File.join(SKILL_DIR, "references")

  def skill_body
    @skill_body ||= begin
      assert File.exist?(SKILL_PATH), "SKILL.md must exist at #{SKILL_PATH}"
      File.read(SKILL_PATH)
    end
  end

  # --- File existence ---

  def test_skill_file_exists
    assert File.exist?(SKILL_PATH)
  end

  def test_chronicle_format_reference_exists
    assert File.exist?(File.join(REFS_DIR, "chronicle-format.md"))
  end

  def test_memory_update_protocol_reference_exists
    assert File.exist?(File.join(REFS_DIR, "memory-update-protocol.md"))
  end

  def test_narrative_template_reference_exists
    assert File.exist?(File.join(REFS_DIR, "narrative-template.md"))
  end

  # --- Frontmatter ---

  def test_has_name_field
    assert_match(/^name: session-retro$/, skill_body)
  end

  def test_has_description_field
    assert_match(/^description:/, skill_body)
  end

  def test_has_allowed_tools
    assert_match(/^allowed-tools:/, skill_body)
  end

  def test_disables_model_invocation
    assert_match(/^disable-model-invocation: true$/, skill_body)
  end

  # --- Content coverage ---

  def test_references_all_eight_event_tags
    %w[DECISION ERROR PIVOT INSIGHT MEMORY-HIT MEMORY-MISS USER-CORRECTION BLOCKED].each do |tag|
      assert_match(/\[#{Regexp.escape(tag)}\]/, skill_body, "Missing event tag: [#{tag}]")
    end
  end

  def test_references_memory_update_protocol
    assert_match(/memory-update-protocol/, skill_body)
  end

  def test_references_narrative_template
    assert_match(/narrative-template/, skill_body)
  end

  def test_warns_against_auto_applying_memory
    assert_match(/human|approval|approve/i, skill_body)
  end
end
```

- [ ] **Step 4: Run tests to verify they fail**

```bash
ruby scripts/tests/session_retro_skill_test.rb
```

Expected: FAIL — `SKILL.md must exist`

- [ ] **Step 5: Commit failing tests**

```bash
git add scripts/tests/session_retro_skill_test.rb
git commit -m "test(cws-96): add failing tests for session-retro skill (TDD red)"
```

- [ ] **Step 6: Write SKILL.md**

Create `.claude/skills/session-retro/SKILL.md`:

```markdown
---
name: session-retro
description: >-
  Deep session retrospective — reviews chronicle events against memory files,
  proposes memory updates, generates blog-ready narrative. Invoke at session
  end for meaningful sessions. Manual only — never auto-triggered.
disable-model-invocation: true
allowed-tools: Read Grep Glob Write Bash(git:*)
---

# Session Retrospective

Run a deep retrospective on the current session's chronicle file. This skill is
manual-only — invoke it at the end of meaningful sessions, not every session.

## When to invoke

- Session had multiple [ERROR], [PIVOT], or [USER-CORRECTION] events
- You discovered something surprising ([INSIGHT]) worth preserving
- Memory gaps were exposed ([MEMORY-MISS])
- User asks for a session retrospective

## Steps

### 1. Find the chronicle file

Derive the path:

```
chronicle_dir=~/.claude/projects/<project-dir>/chronicle/
```

Where `<project-dir>` = `$PWD` with `/` replaced by `-`.

Find today's file for the current branch:

```bash
ls -t ~/.claude/projects/<project-dir>/chronicle/$(date +%Y-%m-%d)-<branch-slug>*.md | head -1
```

If no file exists, report "No chronicle file found for this session" and stop.

### 2. Read chronicle events

Read the `## Events` section. Count events by tag. If zero events, report
"No events to review" and stop.

### 3. Read memory files

Read all files in `~/.claude/projects/<project-dir>/memory/` (excluding MEMORY.md).
Build a mental map of what feedback, project, and reference memories exist.

### 4. Cross-reference events against memories

For each event, check:

- **[MEMORY-HIT]**: Which memory file prevented the mistake? Note it as evidence
  the memory is working.
- **[MEMORY-MISS]**: Should a memory have caught this? Propose a new memory or
  a strengthening of an existing one.
- **[USER-CORRECTION]**: Does a memory already cover this? If yes, it's a
  MEMORY-MISS (memory exists but wasn't followed). If no, propose a new feedback
  memory.
- **[ERROR]**: Was this caused by missing knowledge that should become a memory?
- **[INSIGHT]**: Is this worth preserving as a reference or project memory?
- **[DECISION]**, **[PIVOT]**, **[BLOCKED]**: Context for narrative, rarely need
  new memories.

### 5. Propose memory updates

Present proposed changes as a reviewable diff. See `references/memory-update-protocol.md`
for the exact format and rules.

**Critical:** Do NOT auto-apply memory changes. Present the diff and wait for
human approval. Memory is the instruction set — edits need oversight.

### 6. Generate blog-ready narrative

Write a 2-3 paragraph narrative from the session events. See
`references/narrative-template.md` for structure.

### 7. Update the summary

Overwrite the `## Summary` section in the chronicle file with the richer narrative
(replacing any machine-generated summary from the SessionEnd hook).
```

- [ ] **Step 7: Write chronicle-format.md reference**

Create `.claude/skills/session-retro/references/chronicle-format.md`:

```markdown
# Chronicle File Format Reference

## Location

`~/.claude/projects/<project-dir>/chronicle/YYYY-MM-DD-<branch-slug>.md`

## Frontmatter

```yaml
---
session_id: <uuid from SessionStart hook>
date: YYYY-MM-DD
branch: <git branch name>
task: CWS-<id> (extracted from branch, may be empty)
started: <ISO 8601 UTC timestamp>
---
```

## Locked headers

Only two H2 headers are allowed:

- `## Events` — structured event log
- `## Summary` — session narrative

No other H2 headers. No H1 headers (frontmatter serves as the title).

## Event format

```
- [TAG] brief description
- HH:MM [TAG] brief description (timestamp optional, use for chronology)
  Indented detail line (only when rationale is not obvious)
```

## Event tags (8 categories)

| Tag | When to log |
|-----|------------|
| `[DECISION]` | Chose between alternatives with tradeoffs |
| `[ERROR]` | Code or reasoning mistake; something broke |
| `[PIVOT]` | Changed direction; abandoned previous approach |
| `[INSIGHT]` | Surprising or non-obvious discovery |
| `[MEMORY-HIT]` | Memory file prevented a mistake |
| `[MEMORY-MISS]` | Memory failed to prevent mistake, or gap found |
| `[USER-CORRECTION]` | Human corrected Claude's approach |
| `[BLOCKED]` | Environmental/tooling obstacle preventing progress |

## Category boundaries

- `[ERROR]` = Claude's mistake. `[BLOCKED]` = external obstacle.
- `[DECISION]` = fresh choice. `[PIVOT]` = abandoning a previous commitment.
- `[INSIGHT]` = discovery without immediate action. If it leads to action → `[DECISION]`.
- `[MEMORY-HIT]` = memory prevented a mistake. `[MEMORY-MISS]` = it should have but didn't.

## What NOT to log

- Routine actions: file reads, tool calls, simple edits
- Obvious steps: "read the file", "ran the tests"
- Only log: decisions, failures, surprises, and corrections
```

- [ ] **Step 8: Write memory-update-protocol.md reference**

Create `.claude/skills/session-retro/references/memory-update-protocol.md`:

```markdown
# Memory Update Protocol

## Principles

1. Memory is an instruction set — changes need human oversight
2. Never auto-apply memory changes
3. Verify memories against current file state before proposing
4. Respect the 200-line MEMORY.md hard cap

## Proposal categories

| Action | When to use |
|--------|------------|
| `[NEW]` | Pattern emerged that no existing memory covers |
| `[STRENGTHEN]` | Existing memory exists but wasn't strong enough to prevent a mistake |
| `[STALE?]` | Memory references state that has changed (file moved, task completed) |
| `[DELETE]` | Memory is demonstrably wrong or fully superseded |

## Diff format

Present proposals to the user in this format:

```
PROPOSED MEMORY CHANGES:

[NEW] feedback_<topic>.md
  <One-line rule>
  Why: <reason from session evidence>
  How to apply: <when this kicks in>

[STRENGTHEN] feedback_<existing>.md
  Add: <additional guidance>
  Evidence: <what happened this session>

[STALE?] project_<existing>.md
  Current content: <what it says>
  Actual state: <what's true now>

[DELETE] reference_<existing>.md
  Reason: <why it's no longer needed>

Apply? [review each / apply all / skip]
```

## Rules

- Each proposal must cite session evidence (which event triggered it)
- Before proposing [NEW], check existing memories — maybe strengthen instead
- Before proposing [STALE?], verify by reading the referenced files/state
- [DELETE] requires strong evidence, not just "seems old"
- After applying, update MEMORY.md index (watch the 200-line cap)
```

- [ ] **Step 9: Write narrative-template.md reference**

Create `.claude/skills/session-retro/references/narrative-template.md`:

```markdown
# Blog-Ready Narrative Template

## Purpose

Generate raw material for blog posts — not the final post itself. The narrative
captures the session's story beats for later editorial work.

## Structure (2-3 paragraphs)

### Paragraph 1: The problem

What were we trying to do? What went wrong or was surprising? Lead with the
most interesting tension point.

Example opening beats:
- "Started with X, immediately hit Y"
- "Expected A to be straightforward, but B complicated everything"
- "Third time this week Claude suggested X despite a memory saying not to"

### Paragraph 2: The journey

How did we work through it? What decisions were made and why? Include the
pivots — they're the most interesting parts. Reference specific event tags
where they add credibility.

Key story elements:
- Errors → debugging stories (relatable, educational)
- Pivots → narrative tension (keeps readers engaged)
- User corrections → honest learning moments (builds trust)
- Memory hits/misses → meta-learning about AI collaboration

### Paragraph 3: The takeaway

What did we learn? What would we do differently? What's the transferable
insight for someone else working with AI tools?

## Tone

- First person plural ("we") — collaborative, not adversarial
- Honest about mistakes — readers learn more from failures
- Specific, not abstract — name the tool, the error, the file
- Brief — 2-3 paragraphs, not an essay. The blog post will expand later.

## Anti-patterns

- Don't editorialize ("This was a great session!")
- Don't list events mechanically ("First we did X, then Y, then Z")
- Don't write the blog post — write the raw material with story beats marked
```

- [ ] **Step 10: Run tests to verify they pass**

```bash
ruby scripts/tests/session_retro_skill_test.rb
```

Expected: all tests PASS

- [ ] **Step 11: Commit skill files**

```bash
git add .claude/skills/session-retro/ scripts/tests/session_retro_skill_test.rb
git commit -m "feat(cws-96): add /session-retro skill with reference docs"
```

---

## Task 12: Create PR 4 (/session-retro skill)

- [ ] **Step 1: Run qa-local**

```bash
make qa-local
```

- [ ] **Step 2: Create PR**

```bash
make create-pr TYPE=feat
```

PR title: `feat(cws-96): /session-retro skill and references`

---

## Task 13: Submit Graphite stack

- [ ] **Step 1: Submit all PRs**

```bash
gt checkout cws/96-session-chronicle
gt submit --stack --no-interactive --publish
```

- [ ] **Step 2: Verify stack on GitHub**

Check that 4 PRs exist with correct base branches:
- PR 1 → `main`
- PR 2 → `cws/96-session-chronicle`
- PR 3 → `cws/96-session-chronicle`
- PR 4 → `cws/96-session-chronicle`

---

## Task 14: Update agent-context.md and Linear

**Important:** This task runs on the PR 1 foundation branch.

- [ ] **Step 1: Switch to PR 1 branch**

```bash
gt checkout cws/96-session-chronicle
```

- [ ] **Step 2: Update agent-context.md**

Add CWS-96 to the Active Phase section and Next Actions.

- [ ] **Step 3: Update Linear issue status**

Set CWS-96 to `In Progress` on Linear.

- [ ] **Step 4: Commit and update stack**

```bash
git add docs/agent-context.md
git commit -m "chore(cws-96): update agent-context for chronicle implementation"
gt submit --stack --no-interactive --publish
```

---

## Parallel execution guidance

After Task 4 (PR 1 created), Tasks 5-7, 8-10, and 11-12 are independent and can be dispatched as 3 parallel subagents:

| Agent | Branch base | Tasks | Deliverable |
|-------|------------|-------|-------------|
| Agent A | `cws/96-session-chronicle` | 5, 6, 7 | PR 2: SessionStart hook |
| Agent B | `cws/96-session-chronicle` | 8, 9, 10 | PR 3: SessionEnd hook |
| Agent C | `cws/96-session-chronicle` | 11, 12 | PR 4: /session-retro skill |

Each agent should be given: this plan, the spec doc path, and their assigned tasks.
