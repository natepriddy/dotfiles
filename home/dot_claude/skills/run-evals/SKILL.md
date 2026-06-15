---
name: run-evals
description: >
  Run evaluation scenarios against agent definitions. Tests structural format, semantic
  correctness, and red flag absence. Use when user says "run evals", "test agents",
  "validate agents", or invokes /run-evals. Auto-suggest after agent definition changes.
---

Run evaluation scenarios from `~/.claude/agents/eval/*.md` against agent definitions in `~/.claude/agents/*.md`. Report pass/partial/fail per scenario.

## Invocation

- `/run-evals` — all agents (warn: 44 scenarios, high token cost)
- `/run-evals <agent>` — single agent (e.g., `/run-evals coder`)
- `/run-evals --changed` — only agents whose `.md` file changed since last commit

## Steps

1. **Determine scope**:
   - No args: all agents. Warn user: "This runs ~44 scenarios. Proceed, or use `--changed`?"
   - Named agent: load that agent only
   - `--changed`: run `git diff --name-only HEAD -- ~/.claude/agents/*.md` to find changed agent files. If none changed, report "No agent definitions changed since last commit" and stop.

2. **Load definitions**: for each agent in scope, read:
   - Agent definition: `~/.claude/agents/<agent>.md`
   - Eval scenarios: `~/.claude/agents/eval/<agent>.md`

3. **Per scenario**:
   a. Read Input, Expected behavior, Red flags from scenario
   b. Role-play: generate output as-if you were that agent responding to the Input
   c. Evaluate the generated output:

   **Structural checks** (format compliance):
   - Output follows the agent's defined Output Format section
   - Required sections present (check against agent's template)

   **Semantic checks** (content correctness):
   - Each Expected behavior bullet is addressed (semantic match, not exact string)
   - Escalation triggers fire when they should
   - Scope boundaries respected

   **Red flag checks** (prohibited patterns absent):
   - Each Red flag item is NOT present in the output
   - No scope creep (agent staying in its lane)
   - No hallucinated capabilities

   d. Score: **PASS** (all checks), **PARTIAL** (structural OK but semantic gaps), **FAIL** (red flags present or structural failure)

4. **Regression detection**: if `~/.claude/agents/eval/results.md` has previous runs, compare. Flag any scenario that previously passed but now fails.

5. **Cross-reference failures.md**: check `~/.claude/agents/eval/failures.md` for known patterns matching any failures found.

6. **Produce report** (see Output Format below).

7. **Append to results log**: add summary row to `~/.claude/agents/eval/results.md`.

## Output Format

```
EVAL RESULTS
Run: <YYYY-MM-DD>
Scope: <all | agent-name | changed (list agents)>

SUMMARY: <passed>/<total> passed, <partial> partial, <failed> failed

DETAILS:
  <agent>:
    Scenario 1 (<title>): <PASS|PARTIAL|FAIL> — <brief reason if not PASS>
    Scenario 2 (<title>): <PASS>
    ...

REGRESSIONS: <scenarios that previously passed but now fail>
  (or: "None — no previous results" / "None — all stable")

KNOWN PATTERNS: <matches from failures.md, if any>
  (or: "No matching failure patterns")

RECOMMENDATIONS: <specific suggestions if failures found>
  (or: "No action needed")
```

## Results log format

Append to `~/.claude/agents/eval/results.md`:

```
| <date> | <scope> | <passed> | <failed> | <agents with failures> | <manual or post-change> |
```

## Evaluation criteria notes

- **Non-determinism**: LLM output varies. Checks are semantic (meaning present) not lexical (exact words).
- **Self-eval bias**: red flag checks are harder to game than presence checks. This is a known limitation.
- **Disclaimer**: these evals test definitional clarity (does the agent definition produce correct behavior?). They do NOT validate real-world correctness across all inputs.

## Goodhart check

If both an eval scenario file AND its corresponding agent definition were modified on the same day, flag:
> "WARNING: <agent> eval scenarios and definition were both modified today. Verify evals aren't being tuned to pass rather than testing genuine behavior."

## Rules

- Never auto-fix agent definitions. Report only.
- Warn before running all agents (token cost).
- `--changed` is the practical default. Suggest it when running post-edit.
- Results log is append-only (don't modify previous rows).
- If an eval file doesn't exist for an agent, skip with note: "No eval scenarios for <agent>".
- If agent definition doesn't exist, skip with error: "Agent definition not found: <agent>".
