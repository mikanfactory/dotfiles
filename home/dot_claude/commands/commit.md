---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Skill
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

### Step 1: Detect languages from changed files

Analyze the git diff to identify which programming languages are involved based on file extensions:

- `.py` → Python
- `.ts`, `.tsx`, `.js`, `.jsx` → TypeScript/JavaScript
- `.go` → Go

### Step 2: Run language-specific formatters

For each detected language, invoke the corresponding formatter skill:

- **Python**: `run_python_formatter` skill
- **TypeScript/JavaScript**: `run_typescript_formatter` skill
- **Go**: `run_go_formatter` skill

If multiple languages are detected, run all applicable formatters.

### Step 3: Organize and create commits

Use the `git-commit-organizer` agent to:

1. Analyze all changes (including formatter modifications)
2. Group related changes into logical, atomic commits
3. Create separate commits for each logical group with clear, descriptive messages

## Constraints

- DO NOT add Claude co-authorship footer to commits
- Run formatters BEFORE organizing commits to include formatting changes
- Each commit should be atomic and could be reverted independently
