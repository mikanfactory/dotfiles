---
name: review-typescript
description: Perform comprehensive React/TypeScript frontend code review using multiple specialized agents
context: fork
agent: typescript-pro
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(find:*), Bash(ls:*), Read, Glob, Grep
disable-model-invocation: true
---

## Context

- Current git status: !`git status --short`
- Current branch: !`git branch --show-current`
- Changed files (vs HEAD~1): !`git diff --name-only HEAD~1 2>/dev/null || echo "No previous commit"`
- Staged files: !`git diff --name-only --cached`
- Repository root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`

## Your task

Orchestrate a comprehensive React/TypeScript frontend code review by coordinating multiple specialized agents through the `frontend-review-orchestrator` agent.

### Step 1: Determine review scope

Identify which TypeScript/React files to review based on the following priority:

**Option A: Review changed/staged files (default)**
If there are staged or uncommitted changes, review those files:
```bash
git diff --name-only --cached HEAD
git diff --name-only HEAD
```

**Option B: Review specific path**
If user specified a path argument (e.g., `/review-typescript src/components/`), use that path as the review target.

**Option C: Review all frontend files**
If user requests full review or no changes exist, scan for all frontend files:
```bash
find . -type f \( -name "*.tsx" -o -name "*.ts" \) \
  ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" ! -path "*/.next/*" ! -path "*/.git/*" ! -path "*/coverage/*" ! -name "*.d.ts"
```

**File filtering:**
- Include: `*.tsx`, `*.ts` in frontend-relevant paths (`src/`, `components/`, `hooks/`, `pages/`, `app/`, `utils/`, `lib/`)
- Exclude: `node_modules/`, `dist/`, `build/`, `.next/`, `.git/`, `coverage/`, `*.d.ts`
- Maximum: 50 files per review session

### Step 2: Analyze file context

For each file to review, gather:
1. File path and size
2. File type (component, hook, page, utility, test, style)
3. Functional area hints (from path: components/, hooks/, pages/, api/, store/, utils/)
4. Framework detection (React, Next.js, Vite, etc.)

Create a review manifest:
```json
{
  "scope": "changed|path|all",
  "target_path": "<path or null>",
  "branch": "<current branch>",
  "files": [
    {
      "path": "src/components/Button/Button.tsx",
      "language": "typescript",
      "file_type": "component",
      "area": "components",
      "framework_hints": ["react", "typescript"]
    }
  ],
  "git_context": {
    "has_uncommitted_changes": true,
    "is_pull_request": false
  },
  "framework_detected": {
    "react": true,
    "next": false,
    "vite": true
  }
}
```

### Step 3: Invoke frontend-review-orchestrator

Pass the review manifest to the `frontend-review-orchestrator` agent.

The orchestrator will:
1. Dispatch files to appropriate specialized agents:
   - **typescript-pro**: Type safety, generics, strict mode, type inference
   - **react-specialist**: Hooks patterns, state management, rendering optimization
   - **frontend-developer**: Accessibility (WCAG), component design, UX patterns
   - **security-engineer**: XSS prevention, input sanitization, CSP compliance
2. Collect JSON-formatted review outputs
3. Aggregate and deduplicate findings
4. Generate unified report

**Review focus areas:**
- **Type Safety**: Type definitions, generics, type guards, strict mode compliance
- **React Patterns**: Hooks correctness, state management, component composition
- **Rendering Performance**: Re-render optimization, memoization, code splitting
- **Accessibility**: WCAG compliance, semantic HTML, ARIA attributes, keyboard navigation
- **Security**: XSS prevention, dangerouslySetInnerHTML usage, input validation
- **Testing**: Component testing coverage, hook testing, integration tests

### Step 4: Present review results

Display the aggregated report from the orchestrator:

**1. Executive Summary**
```markdown
# Frontend Code Review Report

**Files Reviewed:** X
**Total Issues:** Y

| Severity | Count |
|----------|-------|
| Critical | X |
| High | X |
| Medium | X |
| Low | X |

## Top Critical Issues (if any)
1. **TS-001** Missing type guard in `src/utils/api.ts:67`
```

**2. Detailed Findings by Severity**
List all issues from Critical to Low with:
- Issue ID and title
- File location with line numbers
- Category and contributing agents
- Description and recommendation
- Code suggestion (if available)

**3. Category Summary**
Group issues by category (Type Safety, React Patterns, Accessibility, Performance, Security, Testing)

**4. Positive Findings**
Highlight well-implemented patterns found during review

**5. Action Items**
Prioritized recommendations:
- Immediate (must fix before merge)
- Short-term (address this sprint)
- Long-term (tech debt)

## Example Usage

```bash
# Review changed files (default)
/review-typescript

# Review specific directory
/review-typescript src/components/

# Review specific file
/review-typescript src/hooks/useAuth.ts

# Review all frontend files
/review-typescript --all
```

## Constraints

- Only review TypeScript/React files (exclude backend, configs, type definitions)
- Exclude test files from security review unless specifically requested
- Maximum 50 files per review to ensure thorough analysis
- Total timeout: 10 minutes
- If no TypeScript files found, report clearly and exit
- Always output results in Japanese when communicating with user

## Communication Style

- Present findings clearly with actionable recommendations
- Use severity levels consistently across all reports
- Include specific file:line references for all issues
- Provide code examples for fixes when possible
- Respond in Japanese to the user
