---
name: review-prompt
description: LLMプロンプトの品質レビューを実行。明確さ、トークン効率、インジェクション脆弱性、ベストプラクティス準拠を評価。使用場面：プロンプトの本番デプロイ前、既存プロンプトの最適化、システムプロンプトの監査。トリガー：prompt review, prompt analysis, prompt audit, system prompt review。
context: fork
agent: prompt-engineer
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(git log:*)
---

## Context

- Current working directory: !`pwd`
- Current branch: !`git branch --show-current 2>/dev/null || echo "Not a git repo"`
- Staged files: !`git diff --name-only --cached 2>/dev/null`
- Unstaged files: !`git diff --name-only 2>/dev/null`
- Diff against main: !`git diff --name-only main...HEAD 2>/dev/null || echo "No main branch"`

## Your Task

Perform a comprehensive LLM prompt review using the `prompt-engineer` agent expertise.

### Step 1: Identify Prompt Files to Review

Determine which prompt files to review based on the following priority:

**Option A: Staged/Unstaged changes (default)**
If there are staged or uncommitted changes, filter for prompt-related files:
```bash
git diff --name-only --cached 2>/dev/null
git diff --name-only 2>/dev/null
```

**Option B: Diff against main branch**
If no staged/unstaged prompt files exist, check diff against main:
```bash
git diff --name-only main...HEAD 2>/dev/null
```

**Option C: Specific path provided**
If user specified a path argument (e.g., `/review_prompt prompts/system.md`), use that path.

**Option D: Inline prompt provided**
If user provided prompt text directly in quotes, review that text.

**Prompt file patterns to detect:**
- `*.prompt`, `*.prompt.md`, `*.prompt.txt`
- `**/prompts/**/*.md`, `**/prompts/**/*.txt`
- `CLAUDE.md`, `SKILL.md`, `*.skill.md`
- Files containing `system_prompt`, `user_prompt` in name
- `**/agents/**/*.md`

### Step 2: Analyze Prompt Structure

For each prompt file, gather metadata:

```json
{
  "file_path": "<path>",
  "prompt_type": "system|user|few-shot|chain-of-thought|mixed",
  "estimated_tokens": "<count>",
  "components": {
    "has_system_instructions": true,
    "has_few_shot_examples": false,
    "has_output_format": true,
    "has_constraints": true,
    "has_persona": false
  }
}
```

### Step 3: Conduct Review

Evaluate the prompt against these 5 categories:

#### 3.1 Clarity and Specificity (PE-1xx)
- **PE-101**: Clear task definition
- **PE-102**: Unambiguous instructions
- **PE-103**: Specific output expectations
- **PE-104**: Well-defined scope

#### 3.2 Token Efficiency (PE-2xx)
- **PE-201**: Redundant content detection
- **PE-202**: Compression opportunities
- **PE-203**: Unnecessary verbosity
- **PE-204**: Example efficiency (for few-shot)

#### 3.3 Safety Considerations (PE-3xx)
- **PE-301**: Prompt injection vulnerabilities
- **PE-302**: Output manipulation risks
- **PE-303**: Sensitive data handling
- **PE-304**: Guardrail recommendations

#### 3.4 Pattern Effectiveness (PE-4xx)
- **PE-401**: Pattern selection appropriateness (Zero-shot, Few-shot, CoT, ToT, ReAct)
- **PE-402**: Example quality and relevance (for few-shot)
- **PE-403**: Reasoning step clarity (for CoT)
- **PE-404**: Pattern consistency

#### 3.5 Best Practices (PE-5xx)
- **PE-501**: Role/persona clarity
- **PE-502**: Output format specification
- **PE-503**: Error handling instructions
- **PE-504**: Edge case coverage

### Step 4: Classify Severity

- `critical` - Prompt likely to fail or produce harmful output
- `high` - Significant effectiveness or safety issues
- `medium` - Improvements that would notably enhance quality
- `low` - Style suggestions and minor optimizations

### Step 5: Present Review Results

#### Executive Summary

```markdown
# LLM Prompt Review Report

**Prompt Source:** <file path or "inline">
**Prompt Type:** <type>
**Estimated Tokens:** <count>

## Summary

| Category | Issues | Severity |
|----------|--------|----------|
| Clarity | X | High: Y, Medium: Z |
| Efficiency | X | High: Y, Medium: Z |
| Safety | X | Critical: Y, High: Z |
| Patterns | X | Medium: Y, Low: Z |
| Best Practices | X | Medium: Y, Low: Z |

**Quality Score:** X/100

### Critical Issues (Immediate Action)
1. **PE-301** Prompt injection vulnerability...
```

#### Detailed Findings

For each issue, provide:
- Issue ID (PE-XXX)
- Category and severity
- Location (line number or section)
- Description
- Recommendation with improved text
- Before/After comparison when applicable

#### Positive Findings

Highlight well-implemented patterns:
- Effective use of techniques
- Good safety practices
- Clean structure

#### Improved Prompt Suggestion

When critical or high-severity issues exist, provide an optimized version.

## Example Usage

```bash
# Review staged/unstaged prompt files (default)
/review_prompt

# Review specific file
/review_prompt prompts/system-prompt.md

# Review inline prompt
/review_prompt "You are a helpful assistant..."

# Review directory
/review_prompt prompts/
```

## Constraints

- Maximum prompt size: 100,000 tokens
- If no prompt files found, report clearly and exit
- Always output results in Japanese when communicating with user
- Provide actionable recommendations with concrete examples
- When safety issues found, always flag prominently

## Communication Style

- Use clear, actionable language
- Provide before/after examples for improvements
- Prioritize critical issues at the top
- Include token count impact for efficiency suggestions
- Respond in Japanese to the user
