---
name: kickoff
description: >
  Morning kickoff — loads yesterday's context, open tasks, and stale items.
  Presents "here's where you left off" and helps set today's priorities.
  Use when user says "kickoff", "start day", "morning", "what's on my plate",
  or invokes /kickoff.
---

Generate a morning context briefing from the Obsidian vault.

## Steps

1. **Resolve date**: today is `YYYY-MM-DD`. Yesterday is the previous calendar day.
2. **Resolve vault path**: `$OBSIDIAN_VAULT` or default `$OBSIDIAN_VAULT`.
3. **Read yesterday's daily log**: `<vault>/Daily Log/<yesterday>.md`
   - Extract **Tomorrow** checklist (these were yesterday's planned priorities)
   - Extract **Blockers** (are they still relevant?)
   - Extract **Sign-off** (what was the last state of work?)
4. **Read open tasks**: glob `<vault>/AI Tasks/tasks/TASK-*.md`, read frontmatter, filter for status `open`, `claimed`, or `in-progress`.
5. **Check for stale tasks**: any `claimed` or `in-progress` tasks with `updated` >24h ago.
6. **Read recent session summaries**: check `<vault>/AI Sessions/` for files from the last 2 days. Pull key decisions and open questions.
7. **Present briefing** to user (don't write any files — this is read-only).

## Output format

```
## Morning Kickoff — <YYYY-MM-DD>

### Yesterday's Plan vs Reality
- [ ] <planned item from yesterday's Tomorrow> → <done/not done/partial>
- [x] <completed item>

### Carried Blockers
- <blocker from yesterday, if still relevant>
- None (if clear)

### Open Tasks
| ID | Title | Status | Priority | Last Updated |
|---|---|---|---|---|
| TASK-NNN | Title | status | priority | date |

### Stale Items ⚠️
- TASK-NNN: "<title>" — claimed <duration> ago, no updates

### Recent Decisions
- <decision from session summary, with [[wikilink]]>

### Open Questions
- <unresolved from recent sessions>

### Suggested Focus
Based on the above:
1. <highest priority recommendation>
2. <second priority>
3. <third priority>
```

## Rules

- **Read-only**. This skill never writes files. It presents context.
- **No fiction**. Only show data that exists. If no yesterday log exists, say "No daily log found for yesterday."
- **Stale threshold**: 24h for tasks, flag but don't auto-unclaim.
- **Suggested Focus**: synthesize from open tasks (by priority), yesterday's incomplete items, and carried blockers. Keep to 3 items max.
- **Quick**: this should run fast. User wants context in seconds, not a full analysis.
- After presenting, offer: "Want to `/signoff` plan for today, or dive into a task?"
