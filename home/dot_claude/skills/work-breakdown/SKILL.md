---
name: work-breakdown
description: Analyzes a large piece of scope and provides recommendations on how to split the work into smaller units of work, identifying dependencies and opportunities for parallelization
---

# Work Breakdown

Analyze the provided features/issues and produce a breakdown of work suitable for parallel or sequential execution.

## Process

1. **Gather context** — Fetch issue details, read relevant source code, review existing specs in `docs/`
2. **Identify work units** — Break input into discrete, independently deliverable units
3. **Map dependencies** — Which units depend on others? What must be sequenced vs parallelized?
4. **Assess risks** — Flag units that touch the same files, entities, or layers (merge conflict risk). Flag shared database schema changes, overlapping templates, or i18n key additions.
5. **Recommend execution order** — Suggest which units can run in parallel and which should be sequenced

## Output

Present a concise breakdown to the user:
- List of work units with one-line descriptions
- Dependency graph (which blocks which)
- Risk flags (file overlap, shared entities, merge conflict hotspots)
- Recommended parallelization strategy

Do NOT make requirements or design decisions — just identify the shape of the work.
