---
name: obsidian-session-review
description: >
  Daily AI session review — reads all session summaries for a date, synthesizes patterns,
  evaluates agent performance and prompting quality, and identifies feedback loop actions.
  Use when user says "review my sessions", "how did today go", "daily review",
  "session feedback", or invokes /session-review. Auto-suggest at end of day when 3+ sessions exist.
---

Review AI session summaries and produce a structured daily retrospective with actionable feedback.

## Steps

1. **Resolve date**: default today (`YYYY-MM-DD`). Accept optional date argument for historical reviews.
2. **Resolve vault path**: `$OBSIDIAN_VAULT` or default `$OBSIDIAN_VAULT`.
3. **Find session files**: glob `<vault>/AI Sessions/**/<date>*.md` — collect all sessions across all projects.
4. **Read all session files** in full.
5. **Read agent definitions**: glob `~/.claude/agents/*.md` (exclude `eval/` and `README.md`) — needed for gap analysis.
6. **Read charter**: `~/.claude/CLAUDE.md` — needed for output gate and rule gap analysis.
7. **Analyze sessions** using the analysis framework below.
8. **Draft review** using template below.
9. **Present draft to user** — ask for edits, additions, or approval.
10. **Write file** after approval to `<vault>/Daily Reviews/<YYYY-MM-DD>.md`.
11. **If actionable agent/charter updates identified**: list specific proposed edits. Do NOT apply them — present for user approval.

## Analysis Framework

Analyze across all sessions for the date. Each section maps to a template section.

### Accomplishments & Scope
- What workstreams were active? How many sessions per workstream?
- What was the throughput? (tasks completed, files changed, decisions made)
- Did scope stay controlled or creep across sessions?

### Decision Quality
- Were decisions well-supported with evidence/research?
- Were trade-offs named explicitly?
- Were decisions made at the right level (app vs. test vs. infra)?
- Were any decisions reversed in later sessions? (write-then-revert pattern)

### Agent Performance
- Which agents were consulted? Which produced useful output?
- Did agents stay within scope or creep?
- Did the router pick the right agents?
- Were there blind spots — things no agent caught that the user had to correct?
- Did agents follow their output formats and self-checks?

### Prompting Patterns
- Did the user front-load constraints (branch scope, PR boundaries)?
- Did the user checkpoint between logical units?
- Did the user prompt for full-path analysis or fix symptoms incrementally?
- Were names challenged immediately or renamed later?
- Did the user use "what fails next?" follow-ups?

### Open Item Backlog
- Collect all open questions and blocked items across sessions.
- Flag items that appeared in multiple sessions without resolution.
- Flag items that need explicit triage (defer, close, or schedule).

### Cost Efficiency
- Which sessions were most/least cost-efficient relative to output?
- Were there high-cost sessions with low throughput? (possible sign of wrong agent, excessive retries, or scope churn)
- Did Context7 doc lookups prevent or reduce rework? (compare sessions with/without doc lookups)
- Flag any session where cost exceeds $5 or API duration exceeds 30m for review.

### Context7 Usage
- Which sessions used Context7? Which should have but didn't?
- Did doc lookups change the proposed approach or just confirm it?
- Were there cases where training knowledge was wrong and Context7 would have caught it?

### Feedback Loop Actions
- Agent definition gaps: principles, constraints, self-checks, or output format fields that would have prevented issues.
- Charter gaps: output gates, rules, or protocols that would have prevented issues.
- Memory updates: patterns or gotchas worth recording in brain/.
- Skill gaps: recurring manual workflows that could be automated.

## Template

```markdown
---
date: <YYYY-MM-DD>
sessions: <count>
total_cost: <sum of all session costs, e.g. "$4.56">
total_duration_api: <sum of API durations>
total_lines_changed: <sum of lines added + removed>
projects: [<project1>, <project2>]
tags: [daily-review, ai, retrospective]
---

# Daily AI Review — <YYYY-MM-DD>

## Sessions Reviewed
| # | Project | Label | Sessions | Cost | API Duration | Key Focus |
|---|---|---|---|---|---|---|
| 1 | <project> | <label> | <count> | <cost> | <duration> | <1-line summary> |

**Daily total**: <total_cost> across <sessions> sessions, <total_duration_api> API time

## Accomplishments
- <what got done, grouped by workstream>
- Throughput: <N> tasks completed, <N> files changed, <N> decisions made

## Decision Quality
### Strong
- <decision that was well-supported>

### Questionable
- <decision that was reversed, unsupported, or made at wrong scope>

## Agent Performance
### Effective
- <agent>: <what they did well>

### Gaps
- <agent>: <what they missed or where they needed user correction>

### Blind Spots
- <thing no agent caught that the user had to correct>

## Prompting Patterns
### Strengths
- <effective prompting pattern observed>

### Improvements
- <pattern that would have saved time or prevented rework>

## Open Item Backlog
| Item | Source Session | Status | Sessions Seen |
|---|---|---|---|
| <item> | <session> | <open/blocked/deferred> | <count> |

### Triage Needed
- <items that appeared 2+ times without resolution>

## Feedback Loop Actions

### Agent Updates (proposed)
- **<agent>** — <section>: <proposed change and why>

### Charter Updates (proposed)
- **<section>**: <proposed change and why>

### Memory Updates (proposed)
- **<brain/file>**: <what to add and why>

### Cost & Context7 Observations
- <cost pattern or Context7 usage observation>

### No Action Needed
- <things that worked well and don't need changes>
```

## Rules

- **Evidence-based only**. Every finding must reference a specific session and specific event. No vague "agents could improve."
- **Actionable feedback**. Every gap must include a proposed fix (agent edit, charter edit, memory update, or skill creation).
- **Balanced**. Include what worked, not just what failed. Reinforcing good patterns is as valuable as fixing bad ones.
- **Don't apply changes**. Present proposed agent/charter/memory edits for user approval. User decides what to implement.
- **Cross-session patterns matter most**. A one-off mistake is noise. The same mistake across 2+ sessions is a signal.
- **Compare against agent definitions**. When flagging an agent gap, quote the relevant existing principle/constraint and explain why it didn't prevent the issue.
- **Distinguish user vs. agent responsibility**. Some improvements are prompting changes (user side), some are definition changes (agent side). Label which is which.
- **Historical reviews**: when reviewing a past date, don't propose changes already made since that date.
- **Keep it concise**. This is a structured review, not a narrative. One line per bullet. Tables over paragraphs.
