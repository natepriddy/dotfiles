---
name: test-architecture
description: Assists in planning a test architecture for a set of changes, prior to implementation
---

# Test Architecture

Help plan automated tests to add alongside the provided set of changes. Assist the user in brainstorming and evaluating different options, but defer to them for the final judgement

## Workflow

1. **Explore the codebase** to understand the current state of tests. For example, to answer the following questions
  - What sorts of testbeds exist that can be augmented with new tests (e.g. unit tests, integration test, E2E tests)?
  - What sorts of logic is tested in which types of tests?
  - What mocking or other supporting capabilities are available and how are they used

2. **Identify high-value test boundaries**. Where will core logic be contained in the new set of changes, that it is easily tested? Especially boundaries that
  - Primarily test the behavior of the software and not its implementation
  - Should be stable as refactors are made, or additional features are added
  - Require minimal mocking, which are more effective at testing logic instead of implementation details

3. **Identify test types/scopes** that are appropriate for those test boundaries, given the state of tests in the codebase. Consider unit, integration, E2E tests, and any other types of tests present in the codebase

4. **Identify key test cases** that ensure the software works correctly, while being expressed in a concise set of tests. Focus on testing behavior, not implementation

5. **Propose test options**. For each testable boundary identified:
  - What the boundary is that is a good candidates for automated tests
  - Where tests for that boundary would fit into the existing test bed
  - The key test cases to implement tests for

6. **Produce a test architecture** document, once the user has made decisions on the test architecture they want. That document should concisely define the test architecture decisions that were made. It should not contain code unless that code is critical to the implementation of the tests

## Guidelines

- Prefer providing recommendations that following existing patterns. You can provide divergent suggestions if you think that certain high-value tests cannot be implemented within those patterns (e.g. there is no E2E testbed available)
- You may propose alternative approaches to the provided set of changes if you believe it will significantly improves the testability of the code
