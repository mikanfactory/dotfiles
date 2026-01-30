---
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(git log:*)
description: LLMプロンプトをレビューして品質・効率・安全性を評価する
---

## Context

- Current working directory: !`pwd`
- Current branch: !`git branch --show-current 2>/dev/null || echo "Not a git repo"`
- Staged files: !`git diff --name-only --cached 2>/dev/null`
- Unstaged files: !`git diff --name-only 2>/dev/null`
- Diff against main: !`git diff --name-only main...HEAD 2>/dev/null || echo "No main branch"`

## Your Task

Perform a comprehensive LLM prompt review using the `prompt-engineer` agent.

### Step 1: Determine Review Scope

Identify which prompt files to review based on the following priority:

**Option A: Staged/Unstaged changes (default)**
If there are staged or uncommitted changes, filter for prompt-related files:
- `*.prompt`, `*.prompt.md`, `*.prompt.txt`
- `**/prompts/**/*.md`, `**/prompts/**/*.txt`
- `CLAUDE.md`, `SKILL.md`, `*.skill.md`
- Files containing `system_prompt`, `user_prompt` in name
- `**/agents/**/*.md`

**Option B: Diff against main branch**
If no staged/unstaged prompt files exist, check diff against main:
```bash
git diff --name-only main...HEAD 2>/dev/null
```

**Option C: Specific path provided**
If user specified a path argument (e.g., `/review_prompt prompts/system.md`), use that path.

**Option D: Inline prompt provided**
If user provided prompt text directly in quotes, review that text.

### Step 2: Invoke review-prompt Skill

Pass the identified prompt(s) to the `review-prompt` skill for comprehensive analysis.

The skill will evaluate:
1. **Clarity (PE-1xx)**: Task definition, output expectations, scope
2. **Efficiency (PE-2xx)**: Token usage, redundancy, compression
3. **Safety (PE-3xx)**: Injection vulnerabilities, guardrails
4. **Patterns (PE-4xx)**: Zero/Few-shot, CoT appropriateness
5. **Best Practices (PE-5xx)**: Role clarity, error handling

### Step 3: Present Results

Display the review report with:
- Executive summary with quality score
- Issues grouped by severity (critical → low)
- Specific improvement recommendations
- Optimized prompt suggestion (when applicable)

## Example Usage

```bash
# Review staged/unstaged prompt files (default)
/review_prompt

# Review specific file
/review_prompt prompts/system.md

# Review inline prompt
/review_prompt "You are a coding assistant..."

# Review directory
/review_prompt prompts/
```

## Constraints

- If no prompt files found, report clearly and exit
- Always output results in Japanese when communicating with user
- Provide actionable recommendations with concrete examples
- Flag safety issues prominently
