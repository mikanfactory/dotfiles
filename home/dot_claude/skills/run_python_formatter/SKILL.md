---
name: run_python_formatter
description: Run Python formatter (ruff format) and type checker (mypy). If mypy fails, fix type errors and re-run until it passes.
allowed-tools: Bash, Read, Edit
model: sonnet
---

# Python Formatter Skill

This skill formats Python code using ruff and ensures type safety with mypy.

## Task Steps

1. **Run ruff formatter**:
   - Check if `uv` is available: `which uv`
   - If `uv` exists: `uv run ruff format .` and `uv run ruff check --fix .`
   - If `ruff` exists: `ruff format .` and `ruff check --fix .`
   - Otherwise: `black .`

2. **Run mypy type checker**:
   - If `uv` exists: `uv run mypy .`
   - Otherwise: `mypy .`

3. **Fix type errors if mypy fails**:
   - Analyze mypy error messages
   - Read the files with type errors
   - Fix the type errors using the Edit tool
   - Re-run mypy until it passes

4. **Report results**:
   - Report which formatter was used
   - Report mypy results
   - If type errors were fixed, report what was fixed

## Constraints

- DO NOT use `any` or `unknown` types when fixing type errors
- Always prefer proper type annotations over type ignores
- Run mypy until it passes completely (no errors)
- Report all changes made during type error fixes

## Example Workflow

```
1. Running formatter: uv run ruff format .
   ✓ Formatted 15 files

2. Running type checker: uv run mypy .
   ✗ Found 3 type errors in src/main.py

3. Fixing type errors:
   - Fixed missing return type annotation in function 'process_data'
   - Fixed incompatible type assignment in variable 'result'
   - Fixed missing type parameter in generic class 'Container'

4. Re-running type checker: uv run mypy .
   ✓ Success: no issues found in 20 source files
```
