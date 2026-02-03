# Testing Requirements

## Core Requirements

**Minimum Test Coverage: 80%**

All code changes must include appropriate tests:

1. **Unit Tests** - Individual functions, utilities, modules
2. **Integration Tests** - API endpoints, database operations, service interactions

Both test types must be implemented together for comprehensive coverage.

## TDD Workflow

Follow the Test-Driven Development cycle:

1. **RED** - Write test first (it should fail)
2. **GREEN** - Write minimal implementation to pass
3. **REFACTOR** - Improve code while keeping tests green
4. Verify coverage meets 80%+ threshold

## Troubleshooting Failed Tests

When tests fail:

- Check test isolation (tests should not depend on each other)
- Validate mock configurations
- Fix implementation, not tests (unless tests have bugs)
- Review edge cases and error scenarios

## Skill Reference

For detailed implementation patterns, code examples, and best practices:

- Use `/tdd-workflow` skill when writing new features, fixing bugs, or refactoring
- The skill provides pytest patterns, mocking examples, and coverage configuration
