# Design: Session Chronicle & Self-Improvement Loop (CWS-96)

## Problem

Two related gaps in the current agentic workflow:

1. **Session learnings are lost.** Claude Code sessions are ephemeral — errors, pivots, decisions,
   and insights evaporate between sessions. Linear backlog, git history, and task files capture
   *what* was done, but not the *why*, the *surprises*, or the *mistakes*. This material is needed
   for a planned multi-part blog series on AI-assisted development learnings.

2. **Claude repeats mistakes.** The memory system is reactive (saves what you tell it to) rather
   than proactive. Feedback memories exist but aren't reliably enforced — Claude keeps suggesting
   `gt merge` despite a memory saying not to. No mechanism exists to detect, log, or strengthen
   memory from session experience.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Event format | Structured tags + session summary | Machine-parseable for self-improvement, human-scannable for blog |
| Self-improvement model | Session-end retrospective (`/session-retro`) + human-approved memory updates | Automate capture, human-gate learning — no auto-apply |
| Storage | Private `~/.claude/projects/<project-dir>/chronicle/` | Not in repo; avoids git clutter; can migrate later |
| File structure | One file per session | Most flexible for blog research; easy to grep, delete, group |
| Event capture timing | Real-time (Claude writes as events happen) | Nothing lost on crash or context compression |
| Memory update authority | Claude proposes, human approves | Memory is the instruction set; edits need oversight |
| Trigger model | SessionStart hook (auto) + SessionEnd hook (auto) + `/session-retro` skill (manual) |

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   DURING SESSION                     │
│                                                      │
│  Notable event occurs (error, pivot, decision, etc.) │
│           │                                          │
│           ▼                                          │
│  Claude appends structured entry to chronicle file   │
│  (~/.claude/projects/<project-dir>/chronicle/               │
│   YYYY-MM-DD-<branch-slug>.md)                       │
│                                                      │
└──────────────┬──────────────────┬────────────────────┘
               │                  │
       ┌───────▼──────┐   ┌──────▼───────────┐
       │  SessionEnd   │   │  /session-retro  │
       │  hook (auto)  │   │  skill (manual)  │
       │               │   │                  │
       │ • Machine-    │   │ • Reviews events │
       │   generated   │   │   against memory │
       │   summary if  │   │ • Proposes memory│
       │   missing     │   │   updates (diff) │
       │ • Safety net  │   │ • Human approves │
       │               │   │ • Blog-ready     │
       │               │   │   narrative      │
       └───────────────┘   └──────────────────┘
                                    │
                                    ▼
                          ┌──────────────────┐
                          │  Memory Updates   │
                          │  (human-approved) │
                          └──────────────────┘
```

## Enforcement Layers

```
Hooks (code, runs always)      ████████████  ← SessionStart creates file + injects reminder
AGENTS.md (contract)           ████████░░░░  ← Read every session, rules for event logging
/session-retro (deliberate)    ████████░░░░  ← Deep analysis when user invokes it
SessionEnd (safety net)        ██████░░░░░░  ← Machine summary if Claude forgot
```

No single layer is sufficient alone. The hooks guarantee the file exists and context is injected.
AGENTS.md tells Claude what to log. The skill provides the deep analysis. SessionEnd catches
sessions where Claude forgot to summarize.

## Components

### 1. Chronicle File Schema

**Location:** `~/.claude/projects/<project-dir>/chronicle/YYYY-MM-DD-<branch-slug>.md`

**Project directory derivation:** Claude Code stores per-project data under
`~/.claude/projects/` using a directory name derived from the absolute project path with `/`
replaced by `-`. For example, `/Users/shabibhossain/Projects/CodeWithShabib/shabib87.github.io`
becomes `-Users-shabibhossain-Projects-CodeWithShabib-shabib87-github-io`. The hook derives
this by finding the matching directory under `~/.claude/projects/` that contains a `memory/`
subdirectory, or by transforming `$PWD` with `sed 's|/|-|g'`.

**Format (locked headers — nothing else at H2 level):**

```markdown
---
session_id: <from SessionStart hook>
date: 2026-03-24
branch: cws/96-session-chronicle
task: CWS-96
started: 2026-03-24T14:00:00Z
---

## Events

- [DECISION] Remove curl fallback — gh CLI is in sandbox allowlist, curl was 332 LOC for zero benefit
- 14:32 [ERROR] bash 3.2 heredoc inside $() corrupted quote state in validate-post.sh
- 14:45 [PIVOT] Switched all scripts to temp-file pattern → CWS-94 evidence confirmed
- [INSIGHT] Fail-closed hooks (exit 2) prevent silent failures — codified as memory
- [MEMORY-HIT] TDD/DRY/KISS from feedback_quality_principles.md → reused existing pattern
- [MEMORY-MISS] No memory about gt merge restriction → Claude suggested it anyway
- [USER-CORRECTION] "Never bypass make finalize-merge" → strengthened memory
- [BLOCKED] Linear MCP doesn't expose cycle date mutations → deferred to backlog

## Summary

Removed redundant remember plugin. Hit bash 3.2 compat across 3 scripts,
established temp-file as canonical. Identified memory enforcement gap.
```

**Rules:**
- Only `## Events` and `## Summary` allowed as H2 headers (locked schema)
- Events are always `- [TAG] description` or `- HH:MM [TAG] description`
- Timestamp prefix is optional — use for errors and pivots where chronology matters
- One-line events preferred; indented detail lines only when rationale isn't obvious
- No routine actions (file reads, tool calls, simple edits) — only decisions, failures,
  surprises, and corrections

**Naming:**
- Branch slug derived from current git branch: `cws/96-session-chronicle` → `cws-96-session-chronicle`
- If session resumes or context compacts, reuse the same file (one file per session)
- If multiple sessions same day on same branch: the hook reads the `session_id` from the
  existing file's frontmatter and compares it to the current `session_id` from stdin. If they
  match (or the source is `resume`/`compact`), reuse the file. If they differ, this is a new
  session — append `-2`, `-3` suffix to the filename. Scan existing files to find the next
  available suffix.

### 2. Event Taxonomy (8 categories)

| Tag | When to Log | Blog Value |
|-----|------------|------------|
| `[DECISION]` | Chose between alternatives with tradeoffs | Shows reasoning process |
| `[ERROR]` | Code or reasoning mistake; something broke | Debugging stories |
| `[PIVOT]` | Changed direction; abandoned previous approach | Narrative tension |
| `[INSIGHT]` | Surprising/non-obvious discovery | Key teaching moments |
| `[MEMORY-HIT]` | Memory file prevented a mistake | Shows system working |
| `[MEMORY-MISS]` | Memory failed to prevent mistake, or gap found | Self-improvement fuel |
| `[USER-CORRECTION]` | Human corrected Claude's approach | Honest learning moments |
| `[BLOCKED]` | Environmental/tooling obstacle preventing progress | Problem-solving stories |

**Category boundaries:**
- `[ERROR]` = Claude's mistake (code bug, wrong assumption). `[BLOCKED]` = external obstacle (API timeout, missing tool, permission issue)
- `[DECISION]` = fresh choice. `[PIVOT]` = abandoning a previous commitment
- `[INSIGHT]` = discovery that doesn't lead to immediate action. If it does → `[DECISION]`
- `[MEMORY-HIT]` = memory prevented a mistake. `[MEMORY-MISS]` = memory should have but didn't

### 3. SessionStart Hook (`chronicle-init.sh`)

**Location:** `.claude/hooks/chronicle-init.sh`
**Config:** `.claude/settings.json` → `hooks.SessionStart`
**Matcher:** `startup|resume|compact|clear`

The `compact` matcher is critical — when context compresses, SessionStart fires with
`source: "compact"`. This re-injects the chronicle reminder into Claude's fresh context.
The `clear` matcher ensures the reminder persists when a user runs `/clear`.

**Logic:**

```
1. Read session_id and source from stdin JSON (jq -r '.session_id, .source')
2. Derive project dir: transform $PWD with sed 's|/|-|g' to get the Claude project dir name
   Chronicle dir: ~/.claude/projects/<project-dir>/chronicle/
3. Create dir if needed (mkdir -p)
4. Derive filename: YYYY-MM-DD-<branch-slug>.md
   - Get branch: git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached"
   - Sanitize: tr '/' '-'
   - If file exists and source is resume/compact: reuse it
   - If file exists and source is startup/clear: compare session_id in frontmatter
     to current session_id. Same → reuse. Different → create with -2/-3 suffix.
5. If new file: write frontmatter + locked headers using bare heredoc
   (bare heredocs are safe per CLAUDE.md; NOT inside $())
   Register any temp files with trap cleanup EXIT
6. Set CHRONICLE_PATH env var via CLAUDE_ENV_FILE (for Claude's in-session use)
7. Output JSON to stdout:
   {
     "hookSpecificOutput": {
       "hookEventName": "SessionStart",
       "additionalContext": "Session chronicle active at <path>.\nLog notable events: [DECISION], [ERROR], [PIVOT], [INSIGHT], [MEMORY-HIT], [MEMORY-MISS], [USER-CORRECTION], [BLOCKED].\nWrite a ## Summary before ending substantive sessions.\nDo NOT log routine actions — only decisions, failures, surprises, and corrections."
     }
   }
```

**Note on CLAUDE_ENV_FILE:** Variables set via `CLAUDE_ENV_FILE` persist for all Bash tool
calls within the session. They are available to Claude (via `$CHRONICLE_PATH` in Bash
commands) but are NOT guaranteed to be available in SessionEnd hooks. The SessionEnd hook
must derive the path independently (see Component 4).

**Note on SessionEnd timeout:** `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=5000` should ideally
be set as a startup environment variable (`CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=5000 claude`)
rather than via `CLAUDE_ENV_FILE`, as it is unclear whether runtime-set env vars affect the
SessionEnd timeout budget. Document this as a setup requirement in the AGENTS.md section or
the user's shell profile. If the default 1.5s proves insufficient, this is the fallback.

**Error handling:** `set -euo pipefail` + `trap 'exit 2' ERR` (fail-closed, consistent with
existing hooks in this repo).

**Bash 3.2 safety:** Use bare heredocs for writing the frontmatter template (safe per CLAUDE.md).
Do NOT place heredocs inside `$()` substitutions. Register any temp files with
`trap cleanup EXIT` per CLAUDE.md.

### 4. SessionEnd Hook (`chronicle-end.sh`)

**Location:** `.claude/hooks/chronicle-end.sh`
**Config:** `.claude/settings.json` → `hooks.SessionEnd`
**Matcher:** none (fires on all session exits)

**Constraints:**
- Cannot block session termination (fire-and-forget)
- Default timeout: 1.5s (see SessionStart note about extending to 5s)
- Must be fast — read file, check for summary, generate if missing

**Logic:**

```
1. Derive chronicle file path INDEPENDENTLY (do not rely on CHRONICLE_PATH env var):
   - Get project dir: transform $PWD with sed 's|/|-|g'
   - Get branch: git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached"
   - Sanitize branch: tr '/' '-'
   - Find today's chronicle file: ls ~/.claude/projects/<project-dir>/chronicle/$(date +%Y-%m-%d)-<branch-slug>*.md
   - If multiple files match (suffixed sessions), use the most recently modified
2. If file doesn't exist or has no events (grep -c '^\- \[' returns 0): exit 0
3. If ## Summary section is empty or missing:
   - Count events by category using grep -c for each tag
   - Generate machine summary:
     "Auto-generated: N events (X decisions, Y errors, Z insights, ...)"
   - Append to ## Summary section using sed or printf >> (no heredoc in $())
4. Exit 0
```

**Why independent path derivation:** `CLAUDE_ENV_FILE` variables are for Claude's in-session
Bash commands. They are not guaranteed to propagate to SessionEnd hooks, which run in a
separate process during session teardown. The SessionEnd hook must be fully self-contained.

**Note:** Machine-generated summaries are intentionally terse — they're a safety net, not the
primary summary. Claude should write a proper summary before ending (per AGENTS.md contract).
The `/session-retro` skill produces the rich analysis.

### 5. `/session-retro` Skill

**Location:** `.claude/skills/session-retro/SKILL.md`
**Invocation:** `/session-retro` (user-triggered only)

**Frontmatter:**

```yaml
---
name: session-retro
description: >-
  Deep session retrospective — reviews chronicle events against memory files,
  proposes memory updates, generates blog-ready narrative. Invoke at session
  end for meaningful sessions. Manual only — never auto-triggered.
disable-model-invocation: true
allowed-tools: Read Grep Glob Write Bash(git:*)
---
```

**Note on Claude Code extensions:** `disable-model-invocation` and `allowed-tools` are
Claude Code-specific extensions to the agentskills.io base spec. They are documented in
the [official Claude Code skills reference](https://code.claude.com/docs/en/skills) and are
appropriate for skills consumed by Claude Code sessions. The base agentskills.io spec is
still the canonical format; these fields are additive.

**Skill discovery:** This skill lives at `.claude/skills/session-retro/SKILL.md` (Claude Code's
project-level discovery path), not at `.agents/skills/` (which is the cross-platform
agentskills.io location used by Codex). This means `/session-retro` will appear in Claude
Code's slash command menu but not in Codex sessions. This is intentional — the chronicle
system is Claude Code-specific infrastructure.

**Skill body (summary — full instructions in SKILL.md):**

1. **Read** current session's chronicle file (derive path from branch + date)
2. **Read** all memory files from `~/.claude/projects/<project-dir>/memory/`
3. **Review** events against memories:
   - Which memories were tested? (MEMORY-HIT events)
   - Which memories failed? (MEMORY-MISS events)
   - What new patterns emerged? (INSIGHT, USER-CORRECTION events)
4. **Propose** memory updates as a reviewable diff:
   ```
   PROPOSED MEMORY CHANGES:

   [NEW] feedback_precompact_no_context.md
     PreCompact hooks cannot inject context — use SessionStart with compact matcher.

   [STRENGTHEN] feedback_fail_closed_hooks.md
     Add: applies to chronicle hooks too — always trap ERR → exit 2

   [STALE?] project_current_state.md
     CWS-95 is now complete, CWS-96 in progress. Update.

   Apply? [review each / apply all / skip]
   ```
5. **Generate** blog-ready narrative (2-3 paragraphs) from events — not the full blog post,
   just the raw material with story beats identified
6. **Overwrite** the `## Summary` section with the richer narrative (replacing any
   machine-generated summary from SessionEnd)

**Supporting files:**
- `references/chronicle-format.md` — documents the locked schema (frontmatter fields,
  `## Events` / `## Summary` headers), all 8 event tags with examples, the optional
  timestamp prefix, and rules for when indented detail lines are appropriate
- `references/memory-update-protocol.md` — rules for proposing memory changes: when to
  propose `[NEW]` vs `[STRENGTHEN]` vs `[STALE?]` vs `[DELETE]`, the diff format shown to
  the user, how to verify memories against current file state before proposing, and the
  200-line MEMORY.md cap constraint
- `references/narrative-template.md` — structure for blog-ready narrative: opening hook
  (the problem), story beats (events with tension/resolution), key takeaways, and a
  "what I'd do differently" reflection. 2-3 paragraphs, not a full blog post.

### 6. AGENTS.md Section

Add to `AGENTS.md` after the existing "Code Quality" section:

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

### 7. Hook Configuration

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [{ "type": "command", "command": ".claude/hooks/check-agent-context-staleness.sh" }]
      },
      {
        "matcher": "startup|resume|compact|clear",
        "hooks": [{ "type": "command", "command": ".claude/hooks/chronicle-init.sh" }]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [{ "type": "command", "command": ".claude/hooks/chronicle-end.sh" }]
      }
    ]
  }
}
```

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Session crashes mid-work | SessionEnd may not fire. Chronicle has events but no summary. Next SessionStart detects orphaned file and reuses it. |
| Multiple sessions same day, same branch | Reuse same file if session resumes. New file with `-2` suffix if genuinely new session. |
| Context compresses mid-session | SessionStart fires with `source: "compact"`, re-injects chronicle reminder. Events already written to file survive. |
| Very short session (one question) | No events logged. SessionEnd writes "No notable events." or does nothing. |
| `/session-retro` with no events | Skill says "No events to review" and exits. |
| SessionEnd timeout (>5s) | Hook is killed. Chronicle file may lack machine summary. Not critical — the real summary comes from Claude or `/session-retro`. |

## Cost Estimate

| Component | Per Session | Notes |
|-----------|------------|-------|
| Real-time event logging | ~500-800 output tokens (~$0.06) | 3-8 Edit calls per session |
| SessionStart hook | <1s wall clock | Shell script, fast |
| SessionEnd hook | <2s wall clock | File read + grep + append |
| `/session-retro` (when invoked) | ~2-3K output tokens (~$0.20) | Full context review + proposals |

## Validation

Design validated against:
- [Official Claude Code hooks reference](https://code.claude.com/docs/en/hooks) (March 2026)
- [agentskills.io specification](https://agentskills.io/specification) (current)
- [OpenTelemetry GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-agent-spans/)
- [AgentOps observability framework](https://arxiv.org/html/2411.05285v2)
- [Ian Paterson's Claude Code memory architecture](https://ianlpaterson.com/blog/claude-code-memory-architecture/)
- [jngiam's self-improving system](https://jngiam.bearblog.dev/the-instruction-that-turns-claude-into-a-self-improving-system/)
- Community session logging patterns (AccidentalRebel, claude-mem, claudefa.st)

Key validation findings:
- PreCompact hook **cannot** inject context (observational only) → replaced with SessionStart `compact` matcher
- Skill must live at `.claude/skills/` for Claude Code discovery (not `.agents/skills/`)
- `MEMORY-HIT` and `MEMORY-MISS` are novel categories with no direct industry precedent but strong justification from metacognitive learning literature
- `[BLOCKED]` added based on AgentOps/OpenTelemetry precedent for environmental obstacles

## Out of Scope

- Memory rotation / weekly cleanup (separate concern; see Ian Paterson's architecture)
- Blog post generation (chronicle provides raw material; writing is a separate workflow)
- Cross-machine chronicle sync (local-only for now; backup is user responsibility)
- Automated memory strengthening without human approval (rejected for safety reasons)
