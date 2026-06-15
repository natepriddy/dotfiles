---
name: implementation-plan
description: Generates a structured implementation plan that an agent can use to implement a change
---

# Implementation Plan

## Workflow
1. Analyze the current codebase to understand how the changes in your implementation plan will fit with the existing code
2. Ask the user questions about any ambiguity you identify, rather than making assumptions, before generating a plan
3. Generate a plan that follows the structure defined below

## Plan structure
- It is CRITICAL that the plan to be structured to use the "Tracer Bullet" approach, focusing on completing the core vertical slice before beginning to implement the details of the requirements. It is preferred that to stub out functions to achieve a working end-to-end flow, and then complete the implementation of those functions later
- The plan should identify checkpoints where the agent can confirm that its changes are working. The exact tool depends on what is implemented, but may include running automated tests, making API requests, or using a skill like `agent-browser` to interact with a web browser
- The plan should be concise and should not include code unless it is critical to the implementation or is a type/interface that demonstrates the target data structures

