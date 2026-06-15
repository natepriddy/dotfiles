---
name: eval-report
description: Synthesise eval results across multiple runs into a trend report — agent performance over time, recurring failure modes, prompting quality patterns. Use when you want to understand how agent definitions are performing across sessions, not just a single run. Writes report to Obsidian vault.
allowed-tools: Bash, Read, Write
---

## Purpose

Where `/run-evals` tests agent definitions and appends one row to results.md, this skill reads across all historical rows to surface trends: which agents regress most, what failure modes recur, whether recent changes improved or degraded performance. Turns the append-only results log into actionable insight.

---

## Invocation

| Command | Action |
|---|---|
| `/eval-report` | Full trend report across all results.md history |
| `/eval-report <agent>` | Single-agent performance history |
| `/eval-report --since <YYYY-MM-DD>` | Trend report for a time window |

---

## Step 1 — Load data sources

```bash
# Results log (append-only, one row per run)
cat ~/.claude/agents/eval/results.md 2>/dev/null || echo "no-results"

# Failure patterns log
cat ~/.claude/agents/eval/failures.md 2>/dev/null || echo "no-failures"

# List available agent evals
ls ~/.claude/agents/eval/*.md 2>/dev/null | grep -v "failures\|results"

# Date range context
date +"%Y-%m-%d"
```

If results.md is empty or missing:
> No eval results found. Run `/run-evals` first to build a history to report on.

---

## Step 2 — Parse results log

The results.md format (from run-evals):
```
| <date> | <scope> | <passed> | <failed> | <agents with failures> | <manual or post-change> |
```

Parse each row. Build a per-agent timeline:

```
agent-name:
  YYYY-MM-DD: passed=N, failed=M, partial=P
  YYYY-MM-DD: passed=N, failed=M, partial=P
  ...
```

Apply scope filter if `--since` or `<agent>` was specified.

---

## Step 3 — Analyse patterns

**Agent-level analysis:**

For each agent that appears in results:
- Pass rate over time (trend: improving / stable / degrading)
- Total failures across all runs
- Most recently failed scenario (if any)
- Last-known status (pass/fail)

**System-level analysis:**

- Overall pass rate per run (trend line)
- Most frequently failing agents
- Runs with regressions (scenario that previously passed → now fails)
- Goodhart check: any agent whose eval and definition were modified on the same day

**Failure mode analysis** (from failures.md):

Cross-reference current failures against known failure patterns. Identify:
- Failures matching a known pattern (with fix applied or not)
- New failures with no known pattern (candidates for failures.md)
- Patterns that have been fixed (no longer appearing in results)

---

## Step 4 — Generate the report

```markdown
---
type: eval-report
date: <YYYY-MM-DD>
period-start: <YYYY-MM-DD>
period-end: <YYYY-MM-DD>
scope: <all | agent-name>
runs-analysed: <n>
tags:
  - claude-code
  - eval
  - agent-health
---

# Eval Report — <Period>

> [!note] Overview
> `<n>` eval runs analysed across `<date range>`. Overall pass rate: `<X%>`. `<n>` agents showing degradation.

## Summary by Agent

| Agent | Runs | Pass Rate | Trend | Last Status |
|---|---|---|---|---|
| <agent> | <n> | <X%> | ↑ improving / → stable / ↓ degrading | PASS/FAIL |

%%Sort by trend (degrading first), then pass rate ascending%%

## Agents Needing Attention

> [!warning] Degrading or Frequently Failing
> For each agent with downward trend or >1 failure:

### <agent>
- **Pass rate:** <X%> over <n> runs
- **Failed scenarios:** <list>
- **Pattern:** <what's going wrong — e.g. "consistently fails scope-boundary scenarios">
- **Recommendation:** <specific change to agent definition or eval scenario>

%%Omit this section entirely if all agents are stable%%

## Regressions This Period
<Scenarios that previously passed but now fail. List by agent and scenario title.>

%%"None" if no regressions%%

## Known Failure Patterns

| Pattern | Status | Matching Agents |
|---|---|---|
| <pattern from failures.md> | Fixed / Active / New | <agents> |

## New Failure Candidates
<Failures seen in results that don't match any pattern in failures.md. Candidates to document.>

%%Omit if none%%

> [!question] Goodhart Check
> <Any agents where eval + definition were modified on the same day. Requires manual review.>
> %%Omit if none%%

## Recommendations

1. <Specific action — e.g. "Rewrite scope-boundary scenario for coder: it's testing the wrong thing">
2. <Specific action — e.g. "Add failures.md entry for router's parallel dispatch failure">
3. <Specific action — e.g. "Run /run-evals security after last week's definition change">

## Trend Chart (text)
%%Simple ASCII trend — X axis: run dates, Y axis: pass rate%%

<date>  ████████░░  80%
<date>  ██████████  100%
<date>  ███████░░░  70%  ← regression

%%Omit if fewer than 3 runs%%
```

---

## Step 5 — Confirm before writing

Show full report. Ask:
> **Ready to write?** `AI Sessions/evals/<date>-eval-report.md`
>
> (`y` to confirm, `e` to edit, `n` to cancel)

---

## Step 6 — Write to vault

```bash
VAULT="${OBSIDIAN_VAULT:-$HOME/Documents/ObsidianVault}"
mkdir -p "$VAULT/AI Sessions/evals"
```

Write report to `$VAULT/AI Sessions/evals/<date>-eval-report.md`.

If new failure candidates were identified, offer to add them to failures.md:

> **New failure candidates found.** Add to `~/.claude/agents/eval/failures.md`?
> (y / n)

If yes, append in the existing format.

---

## Step 7 — Confirm success

> ✓ Eval report saved to `AI Sessions/evals/<date>-eval-report.md`
> ✓ failures.md updated with <n> new patterns _(if applicable)_

---

## Rules

- Read-only on results.md — never modify the append-only log
- Trend analysis requires ≥2 runs. With only 1 run, report it but note trends aren't meaningful yet
- Report findings, never auto-fix agent definitions
- If results.md has gaps (runs from different scopes), note that all-agent pass rates may be incomparable
