---
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
description: Exit plan mode and proceed with TDD workflow
---

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Test files: !`find . -name "test_*.py" -o -name "*_test.py" -o -name "tests.py" 2>/dev/null | head -20`

## Your Task

You are now exiting plan mode to implement using Test-Driven Development.

### Step 1: Exit Plan Mode

If you are currently in plan mode, exit it now using the ExitPlanMode tool. You have user approval to proceed with implementation.

### Step 2: Follow TDD Workflow

Apply the `/tdd-workflow` skill principles:

1. **RED** - Write failing tests first
2. **GREEN** - Write minimal code to pass tests
3. **REFACTOR** - Improve code while keeping tests green

### Step 3: Coverage Check

After implementation, verify 80%+ test coverage:

```bash
uv run pytest --cov=src --cov-report=term-missing
```

## TDD Cycle Reminder

```
┌─────────────────────────────────────────────┐
│  RED → GREEN → REFACTOR → repeat            │
│                                             │
│  1. Write test (expect failure)             │
│  2. Run test (confirm failure)              │
│  3. Write minimal code                      │
│  4. Run test (confirm pass)                 │
│  5. Refactor if needed                      │
│  6. Verify coverage ≥ 80%                   │
└─────────────────────────────────────────────┘
```

## Constraints

- Write tests BEFORE implementation code
- Each test should focus on one behavior
- Use descriptive test names that explain what's tested
- Mock external dependencies
- Test edge cases and error paths
