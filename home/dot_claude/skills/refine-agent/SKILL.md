---
name: refine-agent
description: >
  Analyze failure patterns per agent and propose targeted definition edits. Reads failures.md,
  groups by agent, proposes fixes for agents with 5+ failures. Human approves all changes.
  Use when user says "refine agent", "fix agent definition", "improve agent", or invokes /refine-agent.
---

Read failure log, group by agent, propose targeted definition edits for agents with recurring failure patterns. Human approves all changes.

## Invocation

- `/refine-agent` — scan all agents, process those with 5+ failures
- `/refine-agent <agent>` — process named agent (warn if < 5 failures: "Only <N> failures for <agent>. Patterns may not be reliable. Proceed anyway?")

## Steps

1. **Parse failures.md**: read `~/.claude/agents/eval/failures.md`, extract Log table rows. If table has only placeholder row ("—"), report "No failures recorded yet. Nothing to refine." and stop.

2. **Group by agent**: count failures per agent. List agents with counts.

3. **Check threshold**:
   - No args: process agents with 5+ failures. If none qualify, report counts and stop.
   - Named agent: process regardless but warn if < 5.

4. **Categorize failures** by Root Cause column:

   | Root Cause | Fix Target in Agent Definition |
   |---|---|
   | Scope creep | Constraints section — add explicit boundary |
   | Missing escalation | Escalation Triggers section — add trigger |
   | Wrong format | Self-Check section + Examples — add format check or example |
   | Missed edge case | Self-Check red flags + propose new eval scenario |
   | Tool misuse | Constraints section — add tool usage rule |
   | Hallucination | Operating Principles — add verification step |
   | Over-engineering | Constraints section — add simplicity rule |

5. **Read agent definition**: `~/.claude/agents/<agent>.md`

6. **Generate proposals**: for each pattern, produce a targeted edit:
   - Which section to modify
   - What to add/change (exact proposed text)
   - Rationale (linking back to failure evidence)

7. **Quality checks** (Goodhart safeguards):

   **Eval-only failures?**
   - If all failures come from `/run-evals` (not real sessions), warn: "All failures are from eval runs, not real sessions. Consider fixing the eval scenarios instead of the agent definition."

   **Over-constraining?**
   - If proposing 3+ new constraints, warn: "Adding 3+ constraints risks scope-narrowing death spiral. Consider whether the root cause is really in the definition or in how the agent is being used."

   **Token inflation?**
   - Calculate word count of current definition vs. proposed. If growth > 20%, warn: "Definition would grow by <N>% (<current> -> <proposed> words). Larger definitions cost more tokens per invocation. Consider if all additions are necessary."

   **Conflicting rules?**
   - Check if proposed additions contradict existing text in the definition. Flag any conflicts.

8. **Present to user** (see Output Format). Wait for approval.

9. **Apply only approved changes** to agent definition file.

10. **Update failures.md**: for each addressed failure pattern, update the "Fix Applied" column with date and brief description.

11. **Suggest validation**: "Run `/run-evals <agent>` to verify these changes don't cause regressions."

## Output Format

```
AGENT REFINEMENT PROPOSAL
Agent: <name>
Failures analyzed: <N> from <earliest date> to <latest date>

PATTERN 1: <category> (<N> occurrences)
  Evidence:
    - <date>: "<input summary>" — <root cause>
    - <date>: "<input summary>" — <root cause>
  PROPOSED EDIT:
    Section: <section name>
    Action: ADD | MODIFY | REPLACE
    Content: "<exact text to add or change>"
  Rationale: <why this fix addresses the pattern>

PATTERN 2: ...

QUALITY CHECKS:
  Eval-only failures: <YES — warning | NO>
  Constraint additions: <N> (<OK | WARNING: over-constraining>)
  Token impact: <current words> -> <proposed words> (<+N%>)
  Conflicts with existing rules: <none | list>

NEW EVAL SCENARIO (if edge case failures found):
  Proposed addition to ~/.claude/agents/eval/<agent>.md:
  ## Scenario N: <title>
  **Input**: "<input>"
  **Expected behavior**: <bullets>
  **Red flags**: <bullets>

NEXT STEP: approve/reject each proposal, then run /run-evals <agent>
```

## Rules

- **Never auto-write**. All changes require explicit user approval.
- **Minimum threshold**: 5 failures default. Named agent can override with warning.
- **Goodhart's law**: distinguish eval-only vs real-session failures. Eval-only failures may indicate bad eval, not bad agent.
- **Scope-narrowing death spiral**: warn at 3+ constraint additions per agent per refinement.
- **Token inflation**: warn at 20% definition word count growth.
- **Circular fixes**: always recommend `/run-evals` after applying changes.
- **Audit trail**: update failures.md Fix Applied column for addressed failures.
- **One refinement at a time**: if multiple agents qualify, process one at a time. Present first, get approval, then move to next.
- **Preserve agent structure**: never remove required sections from agent definitions. Only add to or modify within existing sections.
