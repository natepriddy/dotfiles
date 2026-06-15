---
name: consolidate-memory
description: >
  Read session outcomes, Obsidian summaries, brain/ semantic memory, and failure logs. Extract recurring
  patterns, propose updates to brain/ and MEMORY.md. Never auto-writes. Use when user says "consolidate
  memory", "review memory", "clean up memory", or invokes /consolidate-memory. Supports weekly rollup.
---

Read all learning data sources. Detect patterns. Propose changes to brain/ (semantic) and MEMORY.md (index). Human approves before any write.

## Subcommands

| Command | Action |
|---|---|
| `/consolidate-memory` | Full consolidation: pattern detection + proposals |
| `/consolidate-memory rollup` | Weekly rollup: human-readable summary of last 7 days |

## Sources

1. **MEMORY.md** — `~/.claude/projects/<project-slug>/memory/MEMORY.md`
   - Outcomes table (Date, Task, Result, Root Cause, Lesson)
   - Key Design Decisions (condensed — full list in brain/)
   - Memory Architecture reference
2. **Obsidian sessions** — `$VAULT/AI Sessions/**/*-session.md` (default: `$OBSIDIAN_VAULT`)
   - Skip gracefully if vault doesn't exist or no session files found
3. **Failure log** — `~/.claude/agents/eval/failures.md`
4. **Task files** — `$VAULT/AI Tasks/tasks/TASK-*.md`
   - Read frontmatter: status, project, tags, timestamps
   - Extract notes sections for session-specific learnings
   - Skip gracefully if directory doesn't exist
5. **Brain (semantic memory)** — `$VAULT/brain/*.md`
   - `decisions.md`: distilled design decisions
   - `patterns.md`: proven patterns
   - `gotchas.md`: recurring failure modes
   - `sources.md`: curated research links
   - Read all brain/ files to detect duplicates and check for staleness

## Steps — Full Consolidation

1. **Inventory sources**:
   - Read MEMORY.md (required — abort if missing)
   - Read all brain/ files
   - Glob for `*-session.md` files. Count them.
   - Read failures.md
   - Glob for `TASK-*.md`. Count them.

2. **Parse data**:
   - Extract Outcomes table rows from MEMORY.md
   - Extract Reflection sections from sessions (Lessons + Episodes + Sources)
   - Extract failure entries from failures.md
   - Extract task notes and completion patterns
   - Parse brain/ files for existing entries

3. **Pattern detection** — apply these analyses:

   **Promote to brain/decisions.md**:
   - Same decision appears in 2+ sessions or confirmed by user
   - Action: propose adding to brain/decisions.md under appropriate heading

   **Promote to brain/patterns.md**:
   - Same implementation pattern works in 2+ sessions
   - Action: propose adding to brain/patterns.md

   **Promote to brain/gotchas.md**:
   - Same failure mode hits 2+ times
   - Action: propose adding to brain/gotchas.md

   **Promote to brain/sources.md**:
   - Same URL referenced in 2+ sessions, or user explicitly flags as important
   - Action: propose adding to brain/sources.md with topic and description

   **Stale PENDING entries**:
   - Outcomes rows with Result=PENDING older than 14 days
   - Action: flag for resolution (confirm success, mark failed, or remove)

   **Duplicate entries**:
   - Two entries in brain/ or MEMORY.md that say the same thing differently
   - Action: propose merge into single entry

   **Contradictions**:
   - Two lessons/decisions that conflict
   - Action: escalate to user — do NOT auto-resolve

   **Stale brain/ entries**:
   - Entry in brain/ that hasn't been referenced in any session in 30+ days
   - Action: flag for review — may be outdated

   **Stale tasks**:
   - Tasks claimed/in-progress with `updated` >48h ago
   - Action: flag for review

   **Completed TODOs**:
   - Items in Remaining TODO that are actually done
   - Action: propose marking complete

   **MEMORY.md line count check**:
   - Count lines. If >180, warn and propose moving content to brain/

4. **Generate consolidation report** (see Output Format).

5. **Present to user**. Wait for approval on each proposed change.

6. **Apply only approved changes** to appropriate files:
   - Brain/ entries → write to brain/*.md
   - MEMORY.md index changes → write to MEMORY.md
   - Both require explicit approval per item

## Steps — Weekly Rollup

1. Read sessions from last 7 days (by date in frontmatter)
2. Read tasks updated in last 7 days
3. Read decisions logged in `AI Tasks/_decisions.md` from last 7 days
4. Generate rollup report:

```
WEEKLY ROLLUP — <start date> to <end date>

SESSIONS: <N>
  - <date>: <label> — <1-line summary from Decisions section>

TASKS:
  Completed: <N>  |  In Progress: <N>  |  Created: <N>  |  Blocked: <N>
  Highlights:
    - TASK-XXX: <title> — <status>

DECISIONS: <N>
  - <decision title>: <1-line summary>

KEY THEMES:
  - <theme>: appeared in <N> sessions (<list>)

RESEARCH:
  - <N> new sources referenced. <N> promoted to brain/sources.md.

BRAIN/ UPDATES:
  - <N> entries added, <N> modified, <N> flagged as stale

HEALTH:
  Memory lines: <N>/200
  Stale tasks: <N>
  Stale PENDING outcomes: <N>
```

## Output Format — Full Consolidation

```
MEMORY CONSOLIDATION REPORT
Date: <YYYY-MM-DD>
Sources: <N> outcomes, <N> sessions, <N> failures, <N> tasks, <N> brain entries

PROMOTE TO brain/decisions.md:
  - "<lesson>" — seen in <N> sessions
    Proposed: "<concise entry>"

PROMOTE TO brain/patterns.md:
  - "<pattern>" — seen in <N> sessions
    Proposed: "<concise entry>"

PROMOTE TO brain/gotchas.md:
  - "<failure>" — hit <N> times
    Proposed: "<concise entry>"

PROMOTE TO brain/sources.md:
  - <URL> — referenced in <N> sessions, topic: <topic>
    Proposed: "<title>: <description>"

MERGE (duplicates):
  - Entries: "<entry A>" + "<entry B>"
    Location: <file>
    Proposed merge: "<single entry>"

STALE (unresolved):
  - PENDING outcomes older than 14 days
  - brain/ entries not referenced in 30+ days
  - Tasks claimed >48h ago

CONTRADICTIONS (user decides):
  - "<decision A>" vs "<decision B>"
    Context: <where each appears>

PRUNE (superseded/obsolete):
  - "<entry>" in <file> — reason: <why no longer applicable>

NET CHANGE: +<N> additions, -<N> removals, ~<N> modifications
MEMORY.md LINES: <current>/<200 limit>
```

## Rules

- **Never auto-write**. All changes require explicit user approval.
- **brain/ is the primary target** for promoted content. MEMORY.md only for index-level changes.
- **All-Add warning**: if net additions > 5, warn about memory inflation.
- **Missing vault**: skip with note, not error.
- **Contradictions**: always surface. Never silently resolve.
- **MEMORY.md line limit**: warn if approaching 200 lines. Propose moving detail to brain/.
- **Rollup is read-only**: no proposed changes, just a summary report.
- **Wikilinks**: when proposing brain/ entries, include `[[wikilinks]]` to related sessions/tasks.
