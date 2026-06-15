---
name: signoff
description: >
  End-of-day sign-off note. Reads git activity, task changes, and session summaries
  to pre-fill a daily log. Use when user says "sign off", "end of day", "daily log",
  "wrap up day", or invokes /signoff.
---

Generate an end-of-day daily log entry in the Obsidian vault.

## Steps

1. **Resolve date**: use today's date (`YYYY-MM-DD`).
2. **Resolve vault path**: `$OBSIDIAN_VAULT` or default `$OBSIDIAN_VAULT`.
3. **Build output path**: `<vault>/Daily Log/<YYYY-MM-DD>.md`
4. **If file exists**: read it — this is a continuation. Append to the Notes section rather than overwriting.
5. **Gather context** (read what's available, skip what doesn't exist):
   a. **Git activity**: run `git log --oneline --since="8 hours ago"` in the current working directory. If not a git repo, skip.
   b. **Task changes**: read `<vault>/AI Tasks/tasks/TASK-*.md` frontmatter — find any updated today.
   c. **Session summaries**: check `<vault>/AI Sessions/` for any files created today.
   d. **Yesterday's "Tomorrow" section**: read `<vault>/Daily Log/<yesterday>.md` if it exists — pull the Tomorrow checklist to show what was planned.
6. **Draft sign-off** using template below.
7. **Present draft to user** — ask for edits, additions, or approval.
8. **Write file** after approval.
9. **Print confirmation**: path and brief summary.

## Template

```markdown
---
date: <YYYY-MM-DD>
tags: [daily, log]
---

# <YYYY-MM-DD>

## Sign-off
- <what got done today — derived from git, tasks, sessions>
- <manual additions from user>

## Tomorrow
- [ ] <priority — ask user>
- [ ] <priority — ask user>

## Blockers
- <anything stalled — ask user, default "None">

## Notes
<raw thoughts, meeting fragments, links, voice-to-text dumps>
<include any context from sessions or git that's worth preserving>
```

## Context enrichment

When pre-filling the Sign-off section:
- Git commits → summarize as bullet points (group by repo if multiple)
- Tasks updated today → note status changes (claimed, in-progress, done)
- Session summaries → reference with `[[wikilink]]` and one-line summary
- Yesterday's Tomorrow items → show as checklist with completion status

If no automated context is available (no git, no tasks, no sessions), present an empty template and ask the user to fill in.

## Wikilinks

- Link to session summaries: `[[AI Sessions/<project>/<label>/<date>-session]]`
- Link to tasks: `[[AI Tasks/tasks/TASK-NNN]]`
- Link to brain entries when relevant: `[[brain/decisions]]`, `[[brain/patterns]]`

## Rules

- **One file per day**. If file exists, append to Notes section — never overwrite Sign-off/Tomorrow that user already wrote.
- **Always ask before writing**. Present the draft, get approval.
- **No fiction**. Only include git/task/session data that actually exists. Don't invent activity.
- **Client tag**: if working directory or git repo suggests a client (e.g., `meijer`, `storefront`), add the client name to tags.
- **Keep it brief**. Sign-off bullets should be one line each. This is a quick capture, not a report.
