---
name: SDD-0-prepare-issue
description: Generate a per-issue playbook at brain/projects/<project>/playbook-issue-N.md BEFORE opening a claude --worktree session. Reads the runbook's constraints template, fetches the GitHub issue, identifies file-overlap risks against active worktrees, and produces a paste-ready kickoff playbook. Use when starting work on a new GitHub issue so the per-issue context is pre-loaded before the worktree opens. Slots in as SDD-0 before /SDD-1-generate-spec. Use when user says "prepare issue N", "make a playbook for #N", "kickoff prep for #N", or invokes /SDD-0-prepare-issue.
---

# SDD-0 — Prepare Issue (playbook generator)

Generates `<vault>/brain/projects/<project>/playbook-issue-N.md` so the user can open `claude --worktree issue-N` and immediately type "Follow `[[playbook-issue-N]]`" without manually pasting the runbook's constraints template.

**Lives in front of the SDD chain** as SDD-0. Output of this skill feeds `/SDD-1-generate-spec` (via the playbook's kickoff prompt).

## Inputs

- `$ARGUMENTS` should contain the issue number (e.g., `3` for issue #3). If missing, ask the user.
- Optional: a mode hint (`mode: 0|1|A|B|C`). Defaults to `1` unless the user states otherwise.

## Steps

### 1. Discover context (parallel where possible)

- **Issue body:** `gh issue view <N> --json title,body,labels,state --jq '{title, body, labels: [.labels[].name], state}'`. If issue is closed, refuse — playbooks are for open work.
- **Project + repo root:** `git rev-parse --show-toplevel` then `basename`. Use it as `<project>`.
- **Vault path:** `OBSIDIAN_VAULT` env var; default `$OBSIDIAN_VAULT`.
- **Active worktrees:** `git worktree list` (from the main repo). Note any `worktree-issue-*` branches — those are concurrent sessions.
- **Spec numbering:** `ls <main-repo>/docs/specs/ | grep '^[0-9]' | tail -1`. The next playbook should reference `NN+1` for its spec dir.
- **Runbook template:** read `<vault>/brain/projects/<project>/sdd-runbook.md`. Locate the "Constraints template" section (between code fences).

### 2. Identify architectural variants

Read the issue body. Generate 2–4 plausible implementation approaches (A/B/C, sometimes D), each with a one-line mechanism + a trade-off note. These will be what the `/grill-with-docs` phase resolves.

Be honest about your a-priori lean — pick a recommended variant and say why.

### 3. Identify file-overlap risk against active worktrees

For each active `worktree-issue-X`:

- Open the X playbook if it exists at `<vault>/brain/projects/<project>/playbook-issue-X.md`, read its "Files this touches" section.
- If no playbook for X, infer from the issue title via `gh issue view X --json title,body`.
- Compare with the files THIS issue would touch. Flag:
  - **High overlap**: same controller/service file → don't parallelise
  - **Medium overlap**: same module, different files → parallelise with care
  - **Low/zero overlap**: safe to parallelise

State the overlap clearly in the playbook's "Parallel-with-#X constraints" section.

### 4. Compose the playbook

Use this exact structure (mirrors `playbook-issue-2.md`):

```markdown
---
type: semantic
created: <YYYY-MM-DD>
last-reviewed: <YYYY-MM-DD>
tags: [ai, semantic, playbook, sdd, <project>, issue-<N>]
agent-written: true
project: <project>
issue: <N>
status: ready-to-run
mode: <0|1|A|B|C>
---

# 🧠 Playbook — Issue #<N> (<title>)

Tight, issue-specific. Universal guidance lives in [[sdd-runbook]]. This file only captures what's unique to #<N>.

**Mode:** <mode + one-line rationale>
**Parallel with:** <active worktrees or "none">
**Estimated time:** <rough estimate>

## Issue brief

> <paste from gh issue view>
>
> AC: <bullet list of acceptance criteria>
> Proof: <bullet list of proof artifacts required>
> Notes: <issue notes>

## Files this touches (overlap with active worktrees)

- <file 1>
- <file 2>
- <overlap analysis>

## <N> plausible architectural variants (for `/grill-with-docs`)

| Variant | Mechanism | Trade-off |
|---|---|---|
| A — <name> | <mechanism> | <trade-off> |
| B — <name> | <mechanism> | <trade-off> |
| C — <name> | <mechanism> | <trade-off> |

**My pre-grill lean: <variant> because <reason>.**

## Parallel-with-#<X> constraints (if active worktrees exist)

- Do NOT touch: <files>
- Port 8080 serialised: <yes/no>
- E2E serialised: <yes/no>

## Kickoff prompt (paste verbatim after `claude -w issue-<N>`)

\`\`\`text
<full constraints template from runbook, with issue-specific variant list
+ parallel constraints + spec-numbering note + skill chain pointer>
\`\`\`

## Tab setup for THIS worktree

\`\`\`bash
cd <main repo>
git checkout main && git pull origin main
claude --worktree issue-<N>
\`\`\`

(+ lazygit, gh issue view tabs as needed)

## Browser URLs for verification (project-aware)

| URL | What it tests |
|---|---|
| ... | ... |

## Spec numbering

Auto-detect: `ls docs/specs/`. Last completed is <NN>. This issue's spec auto-numbers as **<NN+1>-spec-<feature-name>/**. Confirm before invoking `/SDD-1-generate-spec`.

## Skill chain — same as Mode <X> in [[sdd-runbook]]

<one-line skill chain from runbook, mode-appropriate>

## Fill in `[[mode-experiment]]` after

This is slot <slot> per the experiment plan. Use the entry template.
```

### 5. Write the file

Write to `<vault>/brain/projects/<project>/playbook-issue-<N>.md`. If the file already exists, ASK before overwriting.

### 6. Report back

Return a concise summary to the user:

- File path written
- 1-line issue title
- N architectural variants identified (with the recommended one starred)
- File-overlap risks (if any)
- Suggested mode + rationale
- Next action: literally tell them to run `claude --worktree issue-<N>` and type `Follow [[playbook-issue-<N>]]`

## Rules

- **DO NOT open the worktree yourself.** The user runs `claude --worktree issue-<N>` after this skill completes. This skill only PREPARES the playbook.
- **DO NOT modify the runbook.** Only read it.
- **DO NOT execute `/SDD-1-generate-spec` or any other skill in the chain.** That happens in the new `claude -w issue-<N>` session.
- **If the runbook is missing**, fall back to embedding a minimal constraints template (use the latest playbook as reference). Note the runbook absence in your report.
- **Frontmatter must include `mode:` field.** Default `1`. If user explicitly says spike/parallel/etc., set accordingly.
- **H1 must start with 🧠** per the brain-marker convention in `~/.claude/CLAUDE.md`.
- **Keep the playbook tight.** Aim for 70–100 lines. Mirror `playbook-issue-2.md` structure. Don't duplicate universal content from the runbook — link to it.

## Comparison with related skills

- `/kickoff` — morning context loader. Different scope (full day, not single issue).
- `/grill-with-docs` — happens INSIDE the worktree session AFTER this skill produced the playbook.
- `/SDD-1-generate-spec` — happens AFTER `/grill-with-docs` resolves the design. This skill produces the playbook that contains the kickoff prompt for SDD-1.

## When NOT to use this skill

- Trivial Mode 0 changes (docs typo, single-line fix) — overkill; just `claude` in main repo
- Issues currently being worked on — would clobber the existing playbook unless explicitly resuming
- When you're already inside a worktree session — this skill is a pre-worktree setup tool

## Cleanup / iteration

The playbook is a working document. If the user later changes mode (e.g., decided to switch from Mode 1 to Mode C mid-flight), update the `mode:` field and the relevant sections. Don't regenerate from scratch — preserve any annotations.
