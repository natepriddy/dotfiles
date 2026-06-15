---
name: task
description: >
  Cross-session task tracking in Obsidian vault. Create, claim, update, and archive tasks.
  Decision logging. Kanban board generation. Use when user says "create task", "list tasks",
  "claim task", "task board", or invokes /task.
---

Manage tasks in Obsidian vault at `$OBSIDIAN_VAULT/AI Tasks/` (default: `$OBSIDIAN_VAULT/AI Tasks/`).

## Subcommands

Parse first argument after `/task` to determine action:

| Command | Action |
|---|---|
| `create <title>` | Create task file, assign next ID from counter |
| `list [status]` | List non-archived tasks, optional status filter |
| `show <id>` | Display task file contents |
| `claim <id>` | Claim for current session |
| `unclaim <id>` | Release back to open |
| `start <id>` | claimed → in-progress |
| `done <id>` | → done, append completion note |
| `cancel <id>` | → cancelled |
| `note <id> <text>` | Append timestamped note |
| `board` | Regenerate `_board.md` kanban |
| `decide <title>` | Append entry to `_decisions.md` |
| `archive` | Move done/cancelled tasks >7 days old to archive/ |
| `stale` | List claimed/in-progress tasks updated >2h ago |

## Paths

```
VAULT = $OBSIDIAN_VAULT or $OBSIDIAN_VAULT
BASE  = $VAULT/AI Tasks
TASKS = $BASE/tasks/
ARCHIVE = $BASE/archive/
BOARD = $BASE/_board.md
DECISIONS = $BASE/_decisions.md
COUNTER = $BASE/_counter.md
```

## Session ID

Generate once per session on first claim/note/decide:
```bash
date +%s%N | shasum | head -c 6
```
Store as `ses-XXXXXX`. Reuse for all operations in this session.

## create

1. Read `_counter.md` frontmatter → get `next_id`
2. Pad to 3 digits: `TASK-001`, `TASK-042`
3. Build task file from template (see Task Template below)
4. Verify file doesn't exist at path. If collision, increment and retry once.
5. Write task file to `tasks/TASK-{id}.md`
6. Update `_counter.md` with `next_id + 1`
7. Ask user for optional fields: project, tags, priority, context, acceptance criteria
8. Print: created path + task ID

## list

1. Glob `tasks/TASK-*.md`
2. Read frontmatter from each
3. Filter by status arg if provided (default: all non-archived)
4. Print table: `| ID | Title | Status | Claimed By | Priority | Updated |`
5. Sort by priority (critical > high > normal > low), then by ID

## show

1. Read `tasks/TASK-{id}.md`
2. Print full contents

## claim

1. Read task frontmatter
2. If status != `open` → report current status + holder. If >2h stale, suggest `/task unclaim`
3. If `open` → update frontmatter: `status: claimed`, `claimed_by: <label>`, `session_id: ses-XXXXXX`, `updated: <now>`
4. Label: derive from git branch or working directory. If ambiguous, use "manual-session"
5. Print confirmation

## unclaim

1. Read task frontmatter
2. If not claimed/in-progress → report "task not claimed"
3. Update: `status: open`, `claimed_by: ""`, `session_id: ""`, `updated: <now>`
4. Print confirmation

## start

1. Read task frontmatter
2. If status != `claimed` → report. Must claim first.
3. Update: `status: in-progress`, `updated: <now>`
4. Print confirmation

## done

1. Read task frontmatter
2. Update: `status: done`, `updated: <now>`
3. Append note: `### <timestamp> [<session_id>]\nMarked done.`
4. Ask user for optional completion note
5. Print confirmation

## cancel

1. Read task frontmatter
2. Update: `status: cancelled`, `updated: <now>`
3. Ask user for cancellation reason
4. Append note with reason
5. Print confirmation

## note

1. Read task file
2. Append under `## Notes` section:
   ```
   ### YYYY-MM-DD HH:MM [ses-XXXXXX]
   <text>
   ```
3. Update frontmatter `updated` timestamp
4. Print confirmation

## board

1. Glob all `tasks/TASK-*.md` files
2. Read frontmatter from each
3. Group by status: open, claimed, in-progress, done (last 7 days only)
4. Write `_board.md`:
   ```markdown
   ---
   kanban-plugin: basic
   ---
   ## Open
   - [ ] [[TASK-001]] Title here #tag
   ## Claimed
   - [ ] [[TASK-002]] Title @ses-a3f2c1
   ## In Progress
   - [ ] [[TASK-003]] Title @ses-d4e5f6
   ## Done
   - [x] [[TASK-004]] Title
   ```
5. Print summary: counts per column

## decide

1. Ask user for: context, decision, rationale, relevant agents, related task ID (all optional except decision)
2. Generate session ID if not yet created
3. Append to `_decisions.md`:
   ```markdown
   ## YYYY-MM-DD HH:MM — <title>
   **Context:** <context>
   **Decision:** <decision>
   **Rationale:** <rationale>
   **Agents:** <agents>
   **Task:** [[TASK-XXX]]
   **Session:** ses-XXXXXX
   ---
   ```
4. Print confirmation

## archive

1. Glob `tasks/TASK-*.md`
2. Read frontmatter, find done/cancelled with `updated` >7 days ago
3. Move matching files to `archive/`
4. Regenerate board
5. Print: list of archived tasks

## stale

1. Glob `tasks/TASK-*.md`
2. Read frontmatter, find claimed/in-progress with `updated` >2h ago
3. Print table: `| ID | Title | Status | Claimed By | Last Updated | Stale Duration |`
4. If any found, suggest `/task unclaim <id>` for each

## Task Template

```markdown
---
id: TASK-{NNN}
title: "{title}"
status: open
claimed_by: ""
session_id: ""
project: "{project}"
created: {YYYY-MM-DDTHH:MM:SS}
updated: {YYYY-MM-DDTHH:MM:SS}
tags: [ai, task, {tags}]
priority: normal
---
# TASK-{NNN}: {title}

## Context
{context}

## Acceptance Criteria
- [ ] {criteria}

## Notes
```

## Rules

- **Never auto-unclaim**. Human decides. Suggest only.
- **Counter collision**: verify file doesn't exist before writing. Retry once with next ID.
- **Frontmatter edits**: read full file, modify frontmatter only, write back. Preserve body.
- **Timestamps**: ISO 8601 for frontmatter (`YYYY-MM-DDTHH:MM:SS`). Human-readable in notes (`YYYY-MM-DD HH:MM`).
- **Vault missing**: if vault path doesn't exist, abort with clear error message.
- **No auto-write to MEMORY.md**. Task system is separate from memory system.
- **Board is derived data**: always regenerated from task files, never hand-edited.
