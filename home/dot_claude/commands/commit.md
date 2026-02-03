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

### Step 1: Split and create commits

Use the `git-commit-splitter` agent to:

1. Analyze all changes (including formatter modifications)
2. Split changes into logical, atomic commits
3. Create separate commits for each logical group with clear, descriptive messages

### Step 2: Clear session

コミット完了後、必ず `/clear` を実行してセッションをクリアする。

これにより、セッション継続時に意図しないpushやコメントを防止する。

## Constraints

- DO NOT add Claude co-authorship footer to commits
- Each commit should be atomic and could be reverted independently
- **ALL commit messages MUST be written in English**
