---
name: obsidian-session-summary
description: >
  Lightweight mid-session or quick-close summary to the Obsidian vault. Captures what's been
  done, decisions in flight, and open threads — without the full reflection and analysis of
  /obsidian-summary. Use when context is filling, before a pivot, for a short session not worth
  a full summary, or when handing off mid-session.
allowed-tools: Bash, Read, Write
---

Lighter than `/obsidian-summary`. No reflection, no routing trace, no sources analysis. Saves current session state so nothing is lost to compaction or a session that doesn't get a full summary.

## When to use this vs obsidian-summary

| | session-summary | obsidian-summary |
|---|---|---|
| Session complete | No | Yes |
| Full reflection needed | No | Yes |
| Agent performance analysis | No | Yes |
| Mid-session state save | Yes | No |
| Quick close (brief session) | Yes | No |
| Pre-compaction save | Yes | No |
| Feed into session-review | Yes | Yes |

## Steps

1. **Derive label**: read git branch. If ambiguous, ask.
2. **Derive project**: current working directory basename.
3. **Resolve vault path**: `OBSIDIAN_VAULT` env var or `$OBSIDIAN_VAULT`.
4. **Build output path**: `<vault>/AI Sessions/<project>/<label>/<YYYY-MM-DD>-session.md`
5. **Check if file exists**: if it does, update in place (overwrite with current state). Do not append `-2`.
6. **Generate summary** using template below — extract from conversation context.
7. **Write file**.
8. **Confirm**: print path.

## Template

```markdown
---
date: <YYYY-MM-DD>
project: <project>
label: <label>
branch: <git branch>
status: in-progress
tags: [ai, session, <project>, <label>]
---

# <label> — <YYYY-MM-DD>

## What We Were Doing
<1–2 sentences. The task or problem, framed for someone reading cold.>

## Decisions
- <decision>: <rationale>

%%Omit section if no decisions made yet%%

## Task Status
| Task | Status | Notes |
|---|---|---|
| <task> | <done/in-progress/blocked> | <notes> |

%%Omit section if no task tracking active%%

## Changes Made
- <file or system>: <what changed>

%%Omit if nothing written yet%%

## Open Threads
- <unresolved question, decision in flight, or next step>

## Picked Up Next Session
%%Fill this in when the session resumes or closes%%
- <what to restore context from — key state, open file, last decision>
```

## Rules

- **Not a transcript.** One line per item. Structured reference only.
- **Overwrite, don't append.** If called again mid-session, update in place with current state.
- **status: in-progress** until the session ends. If the session ends without a full `/obsidian-summary`, change status to `complete` and fill "Picked Up Next Session" with a close note.
- **Omit empty sections.** Don't include a section if there's nothing to put in it.
- **No reflection.** That belongs in `/obsidian-summary` at end of session.
- **No routing trace.** That belongs in `/obsidian-summary`.
- **session-review can read these.** They live at the same path pattern as full session notes and are picked up by session-review's glob. The `status: in-progress` frontmatter distinguishes them.
