---
name: sdd-1-council
description: SDD-1 spec generation with council pre-review and section ownership
argument-hint: <feature idea or initial input>
allowed-tools: Read, Glob, Grep, Edit, Write, WebFetch, WebSearch
---

# SDD-1 with Council Routing

Coordinate spec generation. Specs gate everything downstream — invest in
section ownership and veto coverage.

## 1. Pre-flight — router classifies

Invoke router: "Classify SDD-1 spec request: $ARGUMENTS. Which spec
sections need which agents? Consider: architect (technical/scope),
security (auth/secrets/PII), database (entities/migrations),
devenv (build/CI/repo standards), docs (always — structures spec)."

Default crew if router skipped: docs + architect.

## 2. Step 2 Context Assessment — docs leads

**docs** reads README, CLAUDE.md, AGENTS.md, package.json/Cargo.toml,
etc. to identify repo conventions, patterns, testing approach. Output
feeds the Repository Standards spec section later.

## 3. Step 3 Scope Assessment — architect leads

**architect** evaluates feature size per SDD-1 scope examples. If
"too large", STOP and present split options. If "too small", STOP and
recommend skip-the-spec.

## 4. Step 4 Clarifying Questions — docs structures, crew contributes

**docs** owns questions file structure. Each named specialist adds 1–3
domain questions:

- architect: technical constraints, integration boundaries
- security: auth, sensitive data, threat surface
- database: data model, query patterns, migration concerns
- devenv: build/test/CI implications

STOP after questions file saved. Wait for user answers per upstream SDD-1.

## 5. Step 5 Spec Generation — section ownership

Follow `/SDD-1-generate-spec` Step 5 verbatim. Section ownership:

- Technical Considerations → architect
- Security Considerations → security
- Repository Standards → devenv + docs
- Goals / User Stories / Demoable Units → docs
- Open Questions → docs (collects from all)

## 6. Step 6 Review — veto check

- architect: technical realism + scope sizing
- security: security-section completeness
- database: data model adequacy
- docs: overall coherence + junior-dev comprehensibility

If any veto fires, amend and re-review.

## 7. Handoff

Recommend `/sdd-2-council` next.
