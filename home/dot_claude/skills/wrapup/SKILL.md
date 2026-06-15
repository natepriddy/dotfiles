---
name: wrapup
description: >
  Engagement close-out generator. Scans client folder, pulls TODOs, open questions,
  contacts, deliverables, and produces a structured handoff document.
  Use when user says "wrap up engagement", "close out client", "handoff doc",
  "engagement summary", or invokes /wrapup.
---

Generate a structured engagement close-out document for a client.

## Steps

1. **Identify client**: parse argument after `/wrapup` as client name. If not provided, ask user.
2. **Resolve vault path**: `$OBSIDIAN_VAULT` or default `$OBSIDIAN_VAULT`.
3. **Locate client folder**: `<vault>/02-Clients/<client>/`
   - If folder doesn't exist, list available client folders and ask user to pick.
4. **Scan all markdown files** in the client folder recursively. For each file:
   a. Extract **unchecked TODOs** (`- [ ]`)
   b. Extract **open questions** (lines containing `?` in context, or sections titled "Open Questions")
   c. Extract **people/contacts** (look for names with roles, email patterns, Slack references)
   d. Extract **key links** (URLs — PRs, boards, docs, tools)
   e. Extract **deliverables** (PRs merged, tools set up, docs written)
5. **Scan AI Sessions** for this client: `<vault>/AI Sessions/*/` — look for session summaries tagged with the client name.
   - Pull key decisions and lessons learned.
6. **Scan brain/** for entries referencing the client.
7. **Draft the close-out document** using template below.
8. **Present to user** for review and edits.
9. **Write file** to `<vault>/02-Clients/<client>/WRAPUP.md` after approval.
10. **Print confirmation**.

## Template

```markdown
---
client: <client-name>
type: engagement-wrapup
date: <YYYY-MM-DD>
tags: [<client>, wrapup, handoff]
---

# <Client Name> — Engagement Close-Out

## Engagement Summary
<1-3 sentence overview: what the team was brought in to do, high-level outcome>

## Deliverables
| Deliverable | Status | Location |
|---|---|---|
| <what was delivered> | <complete/partial/handed off> | <link or path> |

## Open Items
### TODOs (not completed)
- [ ] <todo> — source: <filename>
- [ ] <todo> — source: <filename>

### Open Questions (unresolved)
- <question> — source: <filename>

### Risks / Known Issues
- <anything that could cause problems after departure>

## Key Contacts
| Person | Role | Notes |
|---|---|---|
| <name> | <role> | <context — what they own, how to reach them> |

## Key Links
- <description>: <url>

## Knowledge Transfer
### What the next person needs to know
- <critical context that isn't written down elsewhere>
- <tribal knowledge, gotchas, political dynamics>

### Recommended reading (in order)
1. <most important doc/file to read first>
2. <second>
3. <third>

## Decisions Made
- <key decisions from AI Sessions and brain/>

## Lessons Learned
- <what worked well on this engagement>
- <what was harder than expected>
- <what you'd do differently>

## Handoff Checklist
- [ ] All PRs merged or documented as open
- [ ] Access/credentials documented or transferred
- [ ] Key contacts notified of transition
- [ ] Outstanding work items assigned to client team
- [ ] Final demo/walkthrough completed
- [ ] Engagement notes organized and accessible
```

## Extraction heuristics

### TODOs
- Match `- [ ]` patterns across all files
- Skip TODOs inside templates or example blocks (code fences)
- Group by source file

### Contacts
- Look for patterns: `Name — Role`, `Name (role)`, `@Name`, Slack user links
- Also check for tables with columns like "Person", "Name", "Contact", "Role"
- Deduplicate by name

### Key links
- Extract all URLs
- Categorize: GitHub PRs, ADO boards/workitems, documentation, tools
- Deduplicate
- Skip urldefense.com wrappers — extract the inner URL

### Deliverables
- Look for merged PRs (past tense), completed TODOs (`- [x]`), sections titled "Deliverables", "What we shipped", "Completed"
- Cross-reference with AI Session task status tables

## Rules

- **Always ask before writing**. Present the full draft for review.
- **No fiction**. Only include data found in the vault. If a section has no data, write "None identified — verify manually."
- **Sensitive data**: flag any credentials, tokens, or passwords found during scanning. Do not include them in the output — note their location instead.
- **Promote lessons to brain/**: after writing the wrapup, suggest promoting key lessons to `brain/gotchas.md` or `brain/patterns.md` via `/consolidate-memory`.
- **Archive suggestion**: after wrapup is complete, suggest archiving the client folder or marking it as inactive.
