---
name: sdd-2-council
description: SDD-2 task generation with architect + coder + docs review
argument-hint: <spec file path or feature name>
allowed-tools: Read, Glob, Grep, Edit, Write
---

# SDD-2 with Council Routing

Decomposes a spec into parent tasks (Phase 2) and sub-tasks (Phase 3).
Bad decomposition cascades through all of SDD-3 — invest here.

## 1. Pre-flight — confirm crew

Default crew: **architect (opus) → coder (sonnet) → docs (haiku)**.

If spec touches database/security/UX, invoke router: "Classify SDD-2 for
$ARGUMENTS. Default is architect + coder + docs — add specialists?"

## 2. Phase 1 — Analysis (architect leads, review-only)

**architect** reads spec and produces:

- 4–6 demoable parent-task boundaries (vertical slices)
- Dependency ordering
- Risk callouts where a unit might be miscoped

Architect does NOT write to disk in this phase.

## 3. Phase 2 — Parent Tasks (architect + docs + coder)

Follow `/SDD-2-generate-task-list-from-spec` Phase 2 verbatim. While generating:

- **architect**: confirms vertical-slice purity (no horizontal-layer tasks)
- **docs**: validates demoable-unit clarity + proof-artifact phrasing
- **coder**: feasibility check — flags un-implementable-in-one-cycle tasks

Route proof-artifact design by domain: e2e (UI), coder (test/CLI), security
(auth artifacts), database (migration artifacts).

STOP after Phase 2. Wait for "Generate sub tasks" per upstream protocol.

## 4. Phase 3 — Sub-Tasks + Relevant Files (coder leads)

Follow `/SDD-2-generate-task-list-from-spec` Phase 3 verbatim. Owners:

- **coder**: sub-task breakdown, Relevant Files identification
- **devenv**: sub-tasks involving Taskfile/CI/Dockerfile/Compose
- **docs**: validates actionable wording, no ambiguity
- **architect**: review-only on Relevant Files — flags unexpected module crossings

## 5. Post-flight — veto check

- architect: parent-task boundaries + file architectural sanity
- docs: clarity, actionability, proof-artifact phrasing

If veto fires, return to the affected phase only.

## 6. Handoff

Recommend `/sdd-3-council` next.
