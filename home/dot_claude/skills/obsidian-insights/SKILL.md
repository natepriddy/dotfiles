---
name: obsidian-insights
description: >
  Save a Claude Code Insights report to the Obsidian vault. Extracts patterns, friction,
  and suggestions from the /insights output and writes a structured note to AI Reviews/insights/.
  Proposes brain/ updates and CLAUDE.md additions for user approval. Optionally creates tasks
  for on-the-horizon workflows. Use after running /insights or when insights data is in context.
allowed-tools: Bash, Read, Write
---

## Purpose

Insights is a periodic aggregate report (typically 2 weeks of sessions), not a per-session note. It belongs in its own vault location with its own structure — separate from session notes and daily reviews.

This skill:
1. Extracts structured data from /insights output in context
2. Writes a reference note to `AI Reviews/insights/<date>-insights.md`
3. Proposes brain/ updates derived from friction patterns and lessons
4. Surfaces CLAUDE.md suggestions for user approval
5. Optionally converts on-the-horizon workflows to Obsidian tasks

---

## Step 1 — Locate insights data

Look in the current conversation for `/insights` output. It contains:
- `project_areas` — workstream breakdown with session counts
- `interaction_style` — narrative + key pattern
- `what_works` — impressive workflows
- `friction_analysis` — friction categories with specific examples
- `suggestions` — CLAUDE.md additions, features to try, usage patterns
- `on_the_horizon` — ambitious workflow opportunities with copyable prompts
- `at_a_glance` — executive summary

If no insights data is in context:
> No /insights output found. Run `/insights` first, then invoke `/obsidian-insights` in the same session.

---

## Step 2 — Resolve vault path and date

```bash
VAULT="${OBSIDIAN_VAULT:-$HOME/Documents/ObsidianVault}"
date +"%Y-%m-%d"
mkdir -p "$VAULT/AI Reviews/insights"
```

Filename: `<YYYY-MM-DD>-insights.md` (date of the insights run, not the period start).

---

## Step 3 — Generate the insights note

```markdown
---
type: insights
date: <YYYY-MM-DD>
period-start: <earliest session date from insights>
period-end: <latest session date from insights>
sessions-analysed: <total sessions count>
tags:
  - claude-code
  - insights
  - retrospective
---

# Claude Code Insights — <date>

> [!note] Period
> <period-start> to <period-end> · <N> sessions analysed

## At a Glance
<at_a_glance.whats_working — one paragraph>

> [!warning] What's Hindering
> <at_a_glance.whats_hindering — one paragraph>

## Project Areas
| Area | Sessions | Summary |
|---|---|---|
| <name> | <session_count> | <description — one line> |

## Interaction Style
<interaction_style.key_pattern — the one-liner>

<interaction_style.narrative — condensed to 2–3 sentences capturing the most actionable observations>

## What Worked Well
%%Impressive workflows that should be reinforced%%
- **<title>**: <description — one line>

## Friction Patterns
%%Each category is a signal worth tracking%%

> [!warning] <category>
> <description — one line>

**Examples:**
- <example 1>
- <example 2>

%%Repeat for each friction category%%

## Suggestions

### CLAUDE.md Additions (proposed)
%%Present for user approval — do not apply automatically%%

**<addition title>**
```
<addition text verbatim>
```
> Why: <why field>

%%Repeat for each suggestion%%

### Features to Try
- **<feature>**: <why_for_you — one line>

### Usage Patterns
- **<title>**: <suggestion — one line>

## On the Horizon
%%Ambitious workflows — candidates for tasks%%

### <title>
<whats_possible — 2 sentences>

**How to try:** <how_to_try>

%%Include copyable_prompt as a collapsed callout%%
> [!tip] Starter Prompt
> <copyable_prompt>

%%Repeat for each opportunity%%

## Highlight
> [!quote] <fun_ending.headline>
> <fun_ending.detail>
```

---

## Step 4 — Propose brain/ updates

Extract from friction_analysis and interaction_style the patterns worth distilling to semantic memory. Present as a numbered proposal — do not write without confirmation.

Format:
```
Proposed brain/ updates:

1. brain/patterns.md — "<entry>" (source: friction_analysis.<category>)
2. brain/gotchas.md — "<entry>" (source: friction_analysis.<category>)
3. brain/patterns.md — "<entry>" (source: interaction_style)

Apply all? (y / select numbers / n)
```

If approved, apply via `/brain-update` or write directly.

---

## Step 5 — Surface CLAUDE.md suggestions

For each `suggestions.claude_md_additions` entry, show:

```
CLAUDE.md addition proposed:

Section: ## <title>
Location: <prompt_scaffold>

<addition text>

Add this? (y / edit / n)
```

Present one at a time. Do not apply any without explicit confirmation per entry.

---

## Step 6 — On-the-horizon tasks (optional)

Ask:
> **On the Horizon** — <N> ambitious workflows identified. Create Obsidian tasks for any?
>
> 1. <title> — <one-line summary>
> 2. <title> — <one-line summary>
> 3. <title> — <one-line summary>
>
> (Enter numbers, "all", or "none")

For approved items, use `/obsidian-tasks` or write task files directly to `AI Tasks/tasks/TASK-NNN.md`.

---

## Step 7 — Write and confirm

Show the full note. Ask:
> **Ready to write?** `AI Reviews/insights/<date>-insights.md`
>
> (`y` / `e` / `n`)

Write after confirmation. Then confirm:
> ✓ Saved to `AI Reviews/insights/<date>-insights.md`
> ✓ brain/ updates applied: <n> entries
> ✓ CLAUDE.md additions: <n> approved, staged for user to apply
> ✓ Tasks created: <n>

---

## Rules

- Never auto-apply CLAUDE.md suggestions — always present for approval per entry.
- Never auto-write brain/ entries — always propose first.
- If insights data is stale (period-end more than 30 days ago), flag it before proceeding.
- The note is a reference, not a transcript. Condense — don't dump the full JSON.
- One insights note per run. If a note already exists for the date, overwrite after confirming.
