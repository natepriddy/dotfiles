---
name: polish
description: Post-implementation workflow — creates PR, runs /simplify and /review in parallel, pushes fixes, checks external reviewers, and surfaces tech debt as GitHub issues. Use after SDD-3 tasks are complete or when implementation is PR-ready.
---

# /polish — Post-Implementation Polish

## Overview

Orchestrates the post-implementation workflow: PR creation, parallel code polish (simplify + review), external reviewer gate, and tech debt capture. Expected position in the SDD lifecycle: **SDD-3 completes → `/polish` → SDD-4 validates**.

---

## Pre-requisites

- Implementation complete (all SDD-3 tasks done, or code is PR-ready)
- All changes committed to the working branch
- Branch pushed to remote

If any of these aren't met, prompt to fix before proceeding.

---

## Step 1 — Pre-flight checks

Stop and fix any failures before continuing.

### 1a. Tests pass locally

Detect and run the project test suite:
- **Python**: `pytest` or `python -m pytest`
- **TypeScript/JavaScript**: `npm test` or `npx vitest` or `npx jest`
- **Java**: `mvn test` or `gradle test`

### 1b. CI pre-flight (lint, format, types)

Run local validation per project type:
- **Python**: `ruff check .`, `ruff format --check .`, `pyright` or `mypy`
- **TypeScript/JavaScript**: `npx prettier --check .`, `npx eslint .`, `npx tsc --noEmit`
- **Java**: `mvn checkstyle:check`, `mvn compile`
- **General**: `pre-commit run --all-files` if `.pre-commit-config.yaml` exists

### 1c. Working tree clean

```bash
git status
```

Uncommitted changes must be committed or stashed before continuing.

---

## Step 2 — PR creation

Check if a PR already exists:

```bash
gh pr view --json number,url 2>/dev/null
```

- **PR exists**: capture number and URL, report it
- **No PR**: use `/create-pull-request` skill if available, otherwise `gh pr create`

Capture **PR number** and **PR URL** for later steps.

---

## Step 3 — Parallel polish

Dispatch two agents concurrently:

**Agent A — Simplify:** Invoke `/simplify` against the current branch. Reviews changed code for reuse, quality, and efficiency.

**Agent B — Review:** Invoke `/review` (or `/caveman-review`) against the current PR. Runs full council review, identifies issues by severity.

Wait for both to complete before proceeding. If parallel dispatch fails (sandbox restrictions), run sequentially: simplify first, then review.

---

## Step 4 — Apply fixes

### 4a. Apply simplify fixes

Apply actionable items from simplify output. Stage and commit:

```bash
git add <fixed files>
git commit -m "refactor: apply simplify findings"
```

### 4b. Apply review fixes

Apply BLOCKER and CRITICAL items from review. Stage and commit:

```bash
git add <fixed files>
git commit -m "fix: address review findings"
```

### 4c. Re-run CI pre-flight

Rerun Step 1b checks to confirm fixes haven't introduced new issues.

### 4d. Push

```bash
git push
```

---

## Step 5 — External review gate

```bash
gh pr checks "$PR_NUMBER"
```

Report:
- Checks completed and status
- Checks still pending
- Automated reviewers (Copilot, CodeRabbit) that haven't posted yet

This is a gate, not a blocker — report status and let the user decide when to proceed. Do not merge.

---

## Step 6 — Tech debt capture

Collect simplify and review findings categorised as:
- "Fix later" / "Out of scope" / "Tech debt"
- MINOR or INFO severity that represent improvement opportunities

Present as numbered list:

```
Tech debt candidates from this PR:

1. [file:line] Description (source: simplify/review)
2. [file:line] Description (source: simplify/review)
...

Which items should I create as GitHub issues? (Enter numbers, "all", or "none")
```

For approved items:

```bash
gh issue create --title "Tech debt: <brief description>" \
  --body "Found during /polish of PR #<number>.

**File:** <file:line>
**Finding:** <description>
**Source:** <simplify|review>"
```

---

## Step 7 — Summary

```
## Polish Summary

**PR:** #<number> — <url>
**Simplify fixes:** <count> commits
**Review fixes:** <count> commits
**CI status:** <passing|failing>
**Pending reviewers:** <list or "none">
**Tech debt issues created:** <count> (<issue numbers>)
```

---

## What this skill does NOT do

- **Merge** — merging is the user's call
- **SDD-4 validation** — separate stage with different intent
- **Obsidian summary** — use `/obsidian-summary` separately if needed
- **Branch cleanup** — too destructive to automate silently

---

## Notes

- `/simplify` is available via the superpowers plugin (obra/superpowers)
- `/review` or `/caveman-review` is the local review skill
- `/create-pull-request` is available via the superpowers plugin
