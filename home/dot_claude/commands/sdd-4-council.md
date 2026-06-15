---
name: sdd-4-council
description: SDD-4 validation with per-gate agent ownership and docs-led coverage matrix
argument-hint: <optional spec path>
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# SDD-4 with Council Routing

Six gates (A–F) map to specialists. Docs owns the report — your charter
says docs has veto during validation, but upstream SDD-4 never names it.

## 1. Pre-flight — auto-discover + assemble crew

Follow `/SDD-4-validate-spec-implementation` Auto-Discovery Protocol verbatim.

Once spec identified: "Router: classify SDD-4 for [spec name]. Default
crew docs + coder + architect + security. Add database/e2e/devenv?"

## 2. Step 1–3 Input Discovery — coder + architect

- **coder**: git log analysis, change extraction
- **architect**: maps changed files to Relevant Files list, flags drift

## 3. Step 4 Evidence Verification — per-gate ownership

| Gate | Owner | Check |
|---|---|---|
| **A** CRITICAL/HIGH triage | architect + security + debugger | Blocker severity |
| **B** Coverage Matrix complete | **docs** (veto) | No Unknown entries |
| **C** Proof artifacts functional | e2e + coder | URLs work, tests pass |
| **D** File integrity | architect | Changed files justified |
| **E** Repository compliance | devenv + coder | Standards followed |
| **F** Security secrets check | security | No real creds |

## 4. Output report — docs structures

**docs** writes the validation report per upstream SDD-4 format:
Executive Summary → Coverage Matrix (3 tables) → Validation Issues
(severity per rubric) → Evidence Appendix.

## 5. Post-flight — veto check

- **docs**: report accuracy — any "Verified" without evidence?
- **security**: GATE F genuinely passed?
- **architect**: GATE D genuinely passed?

If veto fires, re-run affected gate.

## 6. Handoff

PASS → recommend final code review then merge.
FAIL → list blockers, recommend returning to `/sdd-3-council`.
