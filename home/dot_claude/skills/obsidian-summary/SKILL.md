---
name: obsidian-summary
description: >
  Save structured session summary to Obsidian vault. Captures decisions, routing trace, agent findings,
  task status, research links, and reflection. Use when user says "save to obsidian",
  "session summary", "write summary", or invokes /obsidian-summary. Auto-suggest at 75%+ context.
---

Write structured session summary to Obsidian vault as markdown.

## Steps

1. **Derive label**: read git branch name. If ambiguous or detached HEAD, ask user for label.
2. **Derive project**: use current working directory basename.
3. **Resolve vault path**: use `OBSIDIAN_VAULT` env var. Default: `$OBSIDIAN_VAULT`.
4. **Build output path**: `<vault>/AI Sessions/<project>/<label>/<YYYY-MM-DD>-session.md`
5. **Create directories** if they don't exist.
6. **Generate summary** using template below.
7. **Write file**.
8. **Confirm**: print path and brief contents summary.

## Template

```markdown
---
date: <YYYY-MM-DD>
project: <project>
label: <label>
branch: <git branch>
tags: [ai, session, <project>, <label>]
---

# Session Summary — <label>

## Decisions
- <decision>: <rationale>
- Link to [[brain/decisions]] when a decision matches an existing entry

## Routing Trace
Log agent consultations for observability. Omit if no agents consulted.
| Request | Agents | Convergence | Outcome |
|---|---|---|---|
| <what was asked> | <which agents, in order> | <agree/diverge — on what> | <decision reached> |

## Agent Council Findings
- <agent>: <finding or recommendation>

## Task Status
| Task | Status | Notes |
|---|---|---|
| <task> | <done/in-progress/blocked> | <notes> |

Link to task files where they exist: [[AI Tasks/tasks/TASK-XXX]]

## Changes Made
- <file>: <what changed>

## Docs Consulted (Context7)
Library documentation fetched via Context7 MCP during this session. Omit if none.
- <library> — <topic queried>: <whether it changed the approach or confirmed it>

## Sources & Research
URLs and references discovered during this session. Useful ones get promoted to [[brain/sources]] via `/consolidate-memory`.
- [<title>](<url>): <1-line description of what was useful>

## Reflection

### What worked
- <thing that went well and why>

### What failed or was harder than expected
- <thing that failed, root cause>

### Lessons (semantic — store as principles)
- <principle extracted from this session>
- Link to [[brain/patterns]] or [[brain/gotchas]] when a lesson matches existing entries

### Episodes (context-specific — don't generalize)
- <specific fact tied to this session only>

## Open Questions
- <unresolved question or decision deferred>
```

## Rules

- Not a transcript. Structured reference only.
- Reflection section required. Separate semantic lessons from episodic facts.
- Sources section: include all URLs referenced during session. Omit if none.
- Use `[[wikilinks]]` to brain/ entries, task files, and other sessions where relevant.
- If no agent council was consulted, omit Routing Trace and Agent Council Findings.
- If no open questions, omit that section.
- Keep each bullet to one line. Concise.
- If file already exists at path (multiple sessions same day), append `-2`, `-3` etc.
- Tags in frontmatter: always include `ai`, `session`, project name, and label.
