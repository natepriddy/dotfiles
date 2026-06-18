---
name: obsidian-digest
description: Synthesise multiple Obsidian session notes into a structured digest and optional Marp slide deck. Use when asked to summarise a week's work, produce a sprint review, create a presentation, or generate slides from session notes. Scope by topic, feature, project, or date range.
allowed-tools: Bash, Read, Write
---

## Purpose

Read a collection of session notes from the Obsidian vault, synthesise them into a coherent digest, and optionally produce a Marp slide deck. Output must be useful out of context — readable by someone who wasn't in any of the sessions. This is not a per-session summary — it surfaces patterns, decisions, and progress only visible in aggregate.

---

## Prerequisites check

Before doing anything else, verify Marp is available if slides are requested:

```bash
npx @marp-team/marp-cli --version 2>/dev/null || echo "marp-not-found"
```

If `marp-not-found` and the user wants slides:

> **Marp is not installed.** Install via:
> - VS Code: install "Marp for VS Code" extension (`marp-team.marp-vscode`)
> - CLI: `npm install -g @marp-team/marp-cli`
> - No install (npx): `npx @marp-team/marp-cli input.md -o output.html`
>
> You can proceed with the digest note now and generate slides later.

---

## Step 1 — Gather inputs

Run first:
```bash
git branch --show-current 2>/dev/null || echo "no-branch"
git rev-parse --show-toplevel 2>/dev/null || echo "no-repo"
date +"%Y-%m-%d"
```

Present inferred values, ask for corrections in one message:

> **Confirm or adjust before I proceed:**
>
> - **Scope:** `<inferred from branch/repo>` — project, feature, topic, or "all"
> - **Date range:** `<last 7 days, show actual YYYY-MM-DD..YYYY-MM-DD>`
> - **Audience:** `<personal | team | leadership | client-facing>`
> - **Output:** `digest only` / `digest + slides` / `slides only`

---

## Step 2 — Find matching session notes

```bash
VAULT="${OBSIDIAN_VAULT:?OBSIDIAN_VAULT is not set — set it in ~/.zshrc.local}"
find "$VAULT/AI Sessions" -name "*-session.md" | sort
```

Filter by date range and scope (grep for project name if scoped). Read each matched file fully.

If no files found:
> No session notes found for scope `<scope>` between `<start>` and `<end>`. Verify sessions were saved with `/obsidian-summary` during this period.

Show what was found before proceeding:
> Found `<n>` session notes:
> - `<filename>` — `<one-line from "What We Were Doing">`
> Continue? (y / adjust scope / n)

---

## Step 3 — Synthesise

Look for what only becomes visible across multiple sessions:

- **Patterns** — decisions that recurred, problems that reappeared, themes
- **Progress arc** — where things started, where they ended, what's still open
- **Key decisions** — choices that shaped the work, with alternatives considered
- **Blockers and resolutions** — what slowed work and how it was resolved
- **Outstanding risks** — things flagged or left in open questions
- **What shipped** — concrete deliverables, commits, PRs, merged work

Adjust depth and tone by audience:

| Audience | Tone | Technical depth | Agent findings | Commit refs |
|---|---|---|---|---|
| Personal | Casual | Full | Include | Include |
| Team | Professional | Full | Include summarised | Include |
| Leadership | Polished | Outcomes only | Omit | Omit |
| Client-facing | Polished, no jargon | Outcomes + key decisions | Omit | Omit |

---

## Step 4 — Generate the digest note

```markdown
---
type: digest
project: <project or topic>
period-start: <YYYY-MM-DD>
period-end: <YYYY-MM-DD>
audience: <personal|team|leadership|client-facing>
date: <YYYY-MM-DD>
tags:
  - claude-code
  - digest
  - <project>
sessions:
  - <[[wikilink to each source session note]]>
status: complete
---

# <Project or Topic> — <Period> Digest

> [!note] Summary
> <2–3 sentence executive summary. Goal, outcome, what's next.>

## What Shipped
<Concrete deliverables. PRs merged, features completed, specs validated. Names, numbers, outcomes.>

## Key Decisions

> [!important] Decisions That Shaped This Work
> <One-line summary of the most consequential decision.>

| Decision | Reasoning | Impact |
|---|---|---|

## Progress Against Goals
- [x] Completed goal
- [~] In-progress goal
- [ ] Not reached goal

## What Slowed Us Down
<Blockers and resolutions. Omit if nothing significant.>

> [!warning] Outstanding Risk
> <Risk flagged but not resolved. Omit section if none.>

## Open Questions Going Forward
- [ ] <Question carrying into next period>

## Agent Findings (This Period)
%%Omit for leadership and client-facing%%

## Diagrams
%%Include if the period's work had structure worth showing%%

## Source Sessions
- [[<session wikilink>]] — <one line>
```

---

## Step 5 — Generate Marp slides (if requested)

Derive slides from the digest. Do not generate independently.

Density by audience:
- Personal / team: 6–10 slides, detail OK
- Leadership / client-facing: 5–7 slides max, outcomes + visuals only

```markdown
---
marp: true
theme: default
paginate: true
footer: <project> · <period>
---

# <Project or Topic>
## <Period>

---

# What We Did
<3–4 bullets from "What Shipped" — outcomes not tasks>

---

# Decisions Made
<Two-column table or bullet list — for leadership: outcome only>

---

# Where Things Stand
<Task list or before/after>

---

# What's Still Open
%%Omit slide entirely if nothing material%%

---

# Next Steps
<Concrete actions into next period>
```

---

## Step 6 — Confirm before writing

Show digest and slides. Ask:
> **Ready to write?**
> - Digest → `Digests/<project>/<date>-digest.md`
> - Slides → `Digests/<project>/<date>-slides.md`
>
> (`y` to confirm, `e` to edit, `n` to cancel)

---

## Step 7 — Write to vault

```bash
VAULT="${OBSIDIAN_VAULT:?OBSIDIAN_VAULT is not set — set it in ~/.zshrc.local}"
mkdir -p "$VAULT/Digests/<project>"
```

Write digest content to `$VAULT/Digests/<project>/<date>-digest.md`.

For slides, write to `$VAULT/Digests/<project>/<date>-slides.md`.

To export slides to HTML (if Marp CLI available):
```bash
npx @marp-team/marp-cli "$VAULT/Digests/<project>/<date>-slides.md" \
  -o "$VAULT/Digests/<project>/<date>-slides.html"
```

Ask before exporting — not everyone wants extra files by default.

---

## Step 8 — Confirm success

> ✓ Digest saved to `Digests/<project>/<date>-digest.md`
> ✓ Slides saved to `Digests/<project>/<date>-slides.md` _(if applicable)_
>
> To preview slides: open the `.md` in VS Code with the Marp extension, or:
> ```bash
> npx @marp-team/marp-cli --preview "$VAULT/Digests/<project>/<date>-slides.md"
> ```
