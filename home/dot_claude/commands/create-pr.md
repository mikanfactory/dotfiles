---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git push:*), Bash(git remote:*), Bash(gh pr:*), Bash(ls:*), Read, Glob
description: Create a pull request with Japanese description
---

## Context

- Current branch: !`git branch --show-current`
- Default branch: !`git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main"`
- Recent commits on this branch: !`git log --oneline -10`
- Repository root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`

## Your task

Create a pull request for the current branch with a well-structured description in Japanese.

### Step 0: Exit Plan Mode (if active)

If you are currently in plan mode, exit it now using the ExitPlanMode tool. You have user approval to proceed with creating the pull request.

### Step 1: Verify prerequisites

1. Confirm the current branch is not the default branch (main/master)
2. Check if there are commits to create a PR for
3. If no commits exist, inform the user and exit

### Step 2: Check for PR template

Search for PR templates in the following order:

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `.github/PULL_REQUEST_TEMPLATE/default.md`
4. `docs/PULL_REQUEST_TEMPLATE.md`
5. `PULL_REQUEST_TEMPLATE.md`

Use the `Read` tool to check if any of these files exist and read the content if found.

### Step 3: Analyze changes for PR description

Gather comprehensive information about the changes:

1. Get the diff summary against the base branch
2. Get all commit messages on this branch
3. Identify the types of changes (features, fixes, refactoring, etc.)

### Step 4: Generate PR title and description

#### If PR template exists:
- Fill in each section of the template based on the analyzed changes
- **Write all content in Japanese**

#### If no PR template exists:
Generate a PR description with the following structure (all in Japanese):

```markdown
## 背景

[このPRが必要になった背景や課題を説明]

## 目的

[このPRで達成したいことを説明]

## スコープ外

[このPRに含まれないこと、今後の課題を明記]

## 補足

[レビュアーに伝えたい追加情報、テスト方法、注意点など]
```

### Step 5: Generate PR title

Create a concise, descriptive PR title in Japanese:
- Summarizes the main change
- Under 70 characters
- Uses appropriate prefix if the project follows conventions

### Step 6: Create the PR

Use `gh pr create` with HEREDOC for multiline body:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<PR body content>
EOF
)"
```

### Step 7: Report result

Display the PR URL and summarize what was included.

### Step 8: Clear session

After PR creation is complete, always run `/clear` to clear the session.

This prevents unintended pushes or comments when continuing work without clearing.

## Constraints

- **ALL PR content (title, description) MUST be written in Japanese**
- Do not push changes automatically; rely on `gh pr create`
- If PR creation fails, show error and suggest solutions
- Ask user before creating if there's any ambiguity

## Edge Cases

### No remote tracking branch
Push with: `git push -u origin $(git branch --show-current)`

### PR already exists
Check with: `gh pr view --json url -q '.url' 2>/dev/null`

### Multiple PR templates
List them and ask the user which one to use.

## Communication Style

- Always respond in Japanese
- Be proactive in explaining the PR content
- Ask for confirmation before creating the PR
