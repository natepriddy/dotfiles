---
name: implement
description: Directions for an agent to follow when implementing a well-defined piece of functionality
---

# Implementation

Your task is to implement the provided plan or task. As you're writing code, follow the principles described below

## Process
- **Clarify ambiguity**: If during implementation you encounter a significant ambiguity or a question that is not explained in the plan, stop implementation and ask the user to clarify, much like a developer would if they were given an ambiguous task. It is a failure on your part if the resulting solution contains significant decisions or implicit assumptions that the user has to sort through afterwards.

## Code Quality
- **Single Responsibility** - each function does one thing. If a function is doing too many things, split it.
- **Clear types** - define standalone types for data structures. Avoid inline object types, especially for function parameters and return values.
- **Functional and declarative** - prefer immutable data transformations over mutation. Avid imperative loops that accumulate state when `map`, `filter`, `reduce`, or similar declarative functions would be more clear
- **Explicit over clever** - Write code that states its intent clearly. Avoids implicit null 
