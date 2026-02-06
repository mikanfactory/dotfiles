# Guidelines

This document defines the project's rules, objectives, and progress management methods. Please proceed with the project according to the following content.

## Top-Level Rules

- To maximize efficiency, **if you need to execute multiple independent processes, invoke those tools concurrently, not sequentially**.
- **You must think exclusively in English**. However, you are required to **respond in Japanese**.
- To understand how to use a library, **always use the Contex7 MCP** to retrieve the latest information.

## Programming Rules

- Avoid hard-coding values unless absolutely necessary.
- Do not use `any` or `unknown` types in TypeScript.
- You must not use a TypeScript `class` unless it is absolutely necessary (e.g., extending the `Error` class for custom error handling that requires `instanceof` checks).

## Workflow Preferences

### Code Review

- When user requests a code review, provide the review findings only
- Do not automatically proceed to implement fixes unless explicitly asked
- Wait for explicit instruction like "fix it" or "implement the changes"

### Plan Mode

- Before exiting plan mode to execute changes, pause and confirm with the user
- User often wants to review the plan before implementation starts

### Refactoring

- When refactoring code that changes error types or exception classes, always update related tests to expect the new exceptions before running the test suite
- Identify all test assertions for the old pattern before starting the refactor
