---
name: address-feedback
description: Triage and implement feedback on code in a structured way
---

# Address Feedback

Your task is to address feedback on code changes. The feedback may come from any source — PR review comments, verbal feedback, issue comments, or pasted text. The user will provide the feedback or tell you how to access it as part of their input.

## Workflow

### Phase 1: Gather

Collect all feedback items from the source the user provides. List each item so you have a clear inventory to work through.

### Phase 2: Triage

For each feedback item:

1. **Understand it.** What is the reviewer actually asking for? What problem are they pointing out?
2. **Research the codebase.** Read the relevant code, check existing patterns and conventions, understand the implications of the suggested change. Do not skip this step — your evaluation is only as good as your understanding of the current code.
3. **Form your own opinion.** Do you agree with the feedback? Is the suggested change correct? Does it conflict with existing conventions? Are there better alternatives?
4. **Decide a next action.** Each item gets exactly one of:
   - **Implement directly** — The change is straightforward and clearly correct. No discussion needed.
   - **Evaluate approaches** — The feedback is valid but there are multiple ways to address it. You need to present options and tradeoffs to the user.
   - **Ask a clarifying question** — You don't fully understand what the reviewer wants, or the feedback is ambiguous.
   - **Push back** — You believe the suggested change is wrong or would make the code worse. Explain your reasoning and let the user decide whether to accept or reject the feedback.

### Phase 3: Align

Present ALL triage results to the user at once as a summary. For each feedback item, show:
- A brief description of the feedback
- Your next action and reasoning
- For "implement directly" items: what you plan to do (the user can object)
- For "evaluate approaches" items: the options and tradeoffs
- For "ask a clarifying question" items: your question
- For "push back" items: your reasoning for disagreeing

Then work through each item that needs human input, one by one, until every item has a clear resolution. Do not start implementing until all items are resolved.

### Phase 4: Implement

Execute all changes. Run tests and do whatever verification is needed to be confident the changes are correct. Do not checkpoint with the user during implementation — just get it done and report the results.

## Important

- You are empowered to disagree with feedback. If a suggestion conflicts with codebase conventions, introduces unnecessary complexity, or is simply wrong, say so. The user can overrule you, but your job is to give your honest assessment.
- Do not implement changes you haven't triaged. Understand first, act second.
- This skill works standalone — you may need to explore the codebase to build context before you can evaluate feedback. Do not assume prior context exists.
