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

```text
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
