Add under a ## Refactoring or ## Testing section
When refactoring code that changes error types or exception classes, always update related tests to expect the new exceptions before running the test suite.

Add under a ## Code Review section or ## Workflow Preferences
When user requests a code review, provide the review findings only - do not automatically proceed to implement fixes unless explicitly asked.

Add under a ## Planning section or ## General Preferences
Before exiting plan mode to execute changes, pause and confirm with the user that they're ready to proceed with implementation.

Add under a ## Code Conventions or ## Error Handling section
This project uses domain exceptions (NotFoundError, DomainValidationError) instead of HTTPException for business logic errors. Always use domain exceptions in service layer code.

Do a thorough code review of [file]. Provide findings only - do not make any changes or exit plan mode until I explicitly ask you to implement fixes.
Refactor [component] to use domain exceptions instead of HTTPException. This includes: 1) Update the implementation, 2) Update all related tests to expect the new exception types, 3) Run the full test suite to verify.
Split my staged changes into logical commits. Group by: 1) Feature additions (feat:), 2) Refactoring (refactor:), 3) Test changes (test:). Use conventional commit format.

Refactor [file] to extract [concern] into a new module. Work autonomously using TDD: after each edit, run the full test suite. If tests fail, analyze the failure and fix it before proceeding. Only stop to ask me questions if you encounter an architectural decision that could go multiple valid directions. Track your progress with todos and commit after each logical unit of work passes tests.

Review this PR with three parallel perspectives: (1) error handling consistency with our domain exception pattern, (2) type safety and TypedDict usage, (3) test coverage for edge cases. For each finding, assess severity and whether it can be auto-fixed. Then execute all safe fixes autonomously, running tests after each change. Present me with a summary of changes made and any decisions that need my input.

I'm adding a new enum value '[value]' to the [EntityName] schema. Autonomously: (1) Update the OpenAPI spec with proper documentation, (2) Regenerate any codegen'd types, (3) Update all backend handlers and services that reference this enum, (4) Update frontend TypeScript types and any UI components, (5) Fix all test failures in both backend and frontend. Run the full test suite after each layer and fix issues before proceeding. Commit each layer separately with conventional commit messages.
