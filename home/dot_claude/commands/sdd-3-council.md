---
name: sdd-3-council
description: SDD-3 implementation with per-sub-task router triage and discipline routing
argument-hint: <optional task list path>
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# SDD-3 with Council Routing

Most sub-tasks → coder (sonnet), cheap and parallel. Risk = sub-tasks
miscued to coder when architect/security/database should review first.

## 1. Pre-flight — checkpoint mode

Follow `/SDD-3-manage-tasks` Phase 1 Task Preparation verbatim. Confirm
checkpoint mode (Continuous/Task/Batch) with user.

## 2. Per-sub-task — router triage (cheap haiku)

Before EACH sub-task:
"Router: classify sub-task [N.M] '[brief]'. Default route is coder.
Override if it touches: security boundary, schema/migration, module
boundary, build/CI/deploy, UI flow."

Most return "coder — proceed."

## 3. Sub-task execution — routed implementer

- **coder** (default): feature code, tests, refactors
- **devenv**: Taskfile/Makefile/Dockerfile/Compose/devcontainer
- **pipeline**: GitHub Actions, CI, deploy scripts
- **ux**: UI components, layout, i18n
- **e2e**: Playwright tests, browser-level proofs

Review-only gates (must approve before coder proceeds):

- **architect** for module boundary changes
- **security** for auth/secret/sensitive-data touches
- **database** for schema/migration/index changes

Follow `/SDD-3-manage-tasks` Phase 2 Sub-Task Execution verbatim.

## 4. Parent task completion — proof artifacts + commit

Follow `/SDD-3-manage-tasks` Phase 3 verbatim. Owners:

- **e2e**: screenshot/browser-flow artifacts
- **coder**: test results, CLI output
- **devenv**: build / quality-gate artifacts
- **docs**: commit message quality (conventional, task ref)

## 5. Error recovery — debugger

If sub-task verification fails or surfaces unexpected behavior:
**debugger (opus)** investigates before retry. Don't loop coder on
failing tests — escalate.

## 6. Validation pass

Follow `/SDD-3-manage-tasks` Phase 4 verbatim. On all complete,
recommend `/sdd-4-council`.
