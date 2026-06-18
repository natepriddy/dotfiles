---
name: brain-update
description: Apply approved changes to brain/ semantic memory files (decisions.md, patterns.md, gotchas.md, sources.md). Use after consolidate-memory proposes updates, or to add a single finding directly. Never auto-writes — always confirms before touching brain/ files.
allowed-tools: Bash, Read, Write
---

## Purpose

Write human-approved entries to the brain/ semantic memory layer. Pairs with `/consolidate-memory` (which reads and proposes) — this skill handles the write phase. Can also be invoked directly to add a single distilled finding without a full consolidation cycle.

Brain files live at `$VAULT/brain/`:
- `decisions.md` — design decisions proven across multiple sessions
- `patterns.md` — proven implementation and workflow patterns
- `gotchas.md` — recurring failure modes and their fixes
- `sources.md` — curated research links and references

---

## Invocation modes

| Command | Action |
|---|---|
| `/brain-update` | Apply staged proposals from a consolidate-memory run |
| `/brain-update decisions "one-liner to add"` | Add a single entry to decisions.md |
| `/brain-update patterns "one-liner to add"` | Add a single entry to patterns.md |
| `/brain-update gotchas "one-liner to add"` | Add a single entry to gotchas.md |
| `/brain-update sources "Title — url — why"` | Add a source entry |

---

## Step 1 — Load current brain/ state

```bash
VAULT="${OBSIDIAN_VAULT:?OBSIDIAN_VAULT is not set — set it in ~/.zshrc.local}"
cat "$VAULT/brain/decisions.md"
cat "$VAULT/brain/patterns.md"
cat "$VAULT/brain/gotchas.md"
cat "$VAULT/brain/sources.md"
```

Read all four files. Note existing entries to detect duplicates before writing.

---

## Step 2 — Determine what to write

**Mode: staged proposals** (`/brain-update` with no args)

Look in the current conversation for output from a recent `/consolidate-memory` run. Extract all proposed additions — they're typically formatted as:

```
→ brain/decisions.md — <section> — "<entry>"
→ brain/patterns.md — "<entry>"
→ brain/gotchas.md — "<entry>"
```

If no proposals are in context, ask:
> No consolidate-memory proposals found in context. Paste the proposals you want to apply, or use `/brain-update <file> "<entry>"` to add one directly.

**Mode: single entry** (`/brain-update decisions "..."`)

The entry is provided directly. Skip to Step 3.

---

## Step 3 — Duplicate and quality check

For each proposed entry:

1. **Duplicate check**: does any existing brain/ entry convey the same insight? If yes, flag:
   > SKIP — already captured: `<existing entry>`

2. **Staleness check**: does the entry contradict or supersede an existing entry? If yes, flag:
   > UPDATE — this would replace: `<existing entry>`
   > New: `<proposed entry>`
   > Confirm replacement? (y/n)

3. **Quality check**: entries must be:
   - A single line (no multi-line entries in brain/ files)
   - Standalone — readable without context
   - Specific enough to be actionable
   - Not a restatement of what the section heading already implies

Reject entries that fail quality check and explain why.

---

## Step 4 — Confirm before writing

Present the full write plan:

```
Brain update plan:

decisions.md — <section>:
  + <new entry>

patterns.md:
  + <new entry>

gotchas.md:
  + <new entry>

SKIP (duplicate): <entry>
UPDATE (replaces): <old> → <new>

Apply all? (y / select numbers / n)
```

Do not write anything until confirmed.

---

## Step 5 — Write entries

For each approved entry, append it under the correct section heading in the target file. Use the existing file structure — don't add new top-level sections without user confirmation.

Format matches existing entries:
- `decisions.md` / `patterns.md` / `gotchas.md`: `- <entry>` (bullet under section heading)
- `sources.md`: match existing link format

Update `last-reviewed` in the frontmatter of any file that was modified:

```yaml
last-reviewed: <YYYY-MM-DD>
```

---

## Step 6 — Confirm success

> ✓ brain/decisions.md — <n> entries added
> ✓ brain/patterns.md — <n> entries added
> ✓ brain/gotchas.md — <n> entries added
> ✓ brain/sources.md — <n> entries added
> ✗ Skipped <n> duplicates

---

## Rules

- Never auto-write. Always confirm with the user before touching any file.
- Never add multi-line entries to brain/ files.
- Never create new brain/ files. The four files are the canonical set.
- Never remove existing entries without explicit user instruction.
- If in doubt about which section an entry belongs under, ask — don't guess.
- Brain/ entries are semantic memory: distilled, proven, slow-written. Reject speculative or single-session observations; those belong in session notes.
