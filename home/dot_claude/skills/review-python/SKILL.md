---
name: review-python
description: Perform comprehensive Python backend code review using multiple specialized agents
context: fork
agent: python-reviewer
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

Orchestrate a comprehensive Python backend code review by coordinating multiple specialized agents through the `backend-review-orchestrator` agent.

### Step 1: Determine review scope

Identify which Python files to review based on the following priority:

**Option A: Review changed/staged files (default)**
If there are staged or uncommitted changes, review those files:
```bash
git diff --name-only --cached HEAD
git diff --name-only HEAD
```

**Option B: Review specific path**
If user specified a path argument (e.g., `/review-python src/api/`), use that path as the review target.

**Option C: Review all Python backend files**
If user requests full review or no changes exist, scan for all Python backend files:
```bash
find . -type f -name "*.py" \
  ! -path "*/node_modules/*" ! -path "*/.venv/*" ! -path "*/__pycache__/*" ! -path "*/.git/*"
```

**File filtering:**
- Include: `*.py` in backend-relevant paths
- Exclude: `node_modules/`, `.venv/`, `__pycache__/`, `.git/`
- Maximum: 50 files per review session

### Step 2: Analyze file context

For each file to review, gather:
1. File path and size
2. Primary language (Python)
3. Functional area hints (from path: api/, services/, models/, auth/, db/)
4. Framework detection (FastAPI, Django, Flask, etc.)

Create a review manifest:
```json
{
  "scope": "changed|path|all",
  "target_path": "<path or null>",
  "branch": "<current branch>",
  "files": [
    {
      "path": "src/api/users.py",
      "language": "python",
      "area": "api",
      "framework_hints": ["fastapi"]
    }
  ],
  "git_context": {
    "has_uncommitted_changes": true,
    "is_pull_request": false
  }
}
```

### Step 3: Invoke backend-review-orchestrator

Pass the review manifest to the `backend-review-orchestrator` agent.

The orchestrator will:
1. Dispatch files to appropriate specialized agents:
   - **python-reviewer**: Python type safety, patterns, testing
   - **backend-developer**: API design, database, microservices
   - **security-engineer**: Vulnerabilities, auth, OWASP
   - **database-administrator**: Database performance, query optimization, schema design
2. Collect JSON-formatted review outputs
3. Aggregate and deduplicate findings
4. Generate unified report

### Step 4: Present review results

Display the aggregated report from the orchestrator:

**1. Executive Summary**
```markdown
# Python Backend Code Review Report

**Files Reviewed:** X
**Total Issues:** Y

| Severity | Count |
|----------|-------|
| Critical | X |
| High | X |
| Medium | X |
| Low | X |

## Top Critical Issues (if any)
1. **SE-001** SQL Injection in `src/db/queries.py:67`
```

**2. Detailed Findings by Severity**
List all issues from Critical to Low with:
- Issue ID and title
- File location with line numbers
- Category and contributing agents
- Description and recommendation
- Code suggestion (if available)

**3. Category Summary**
Group issues by category (Security, Performance, Design, Type Safety, Database, etc.)

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
/review-python

# Review specific directory
/review-python src/api/

# Review specific file
/review-python src/services/user_service.py

# Review all Python backend files
/review-python --all
```

## Constraints

- Only review Python files (exclude frontend, static assets, configs)
- Exclude test files from security review unless specifically requested
- Maximum 50 files per review to ensure thorough analysis
- Total timeout: 10 minutes
- If no Python files found, report clearly and exit
- Always output results in Japanese when communicating with user

## Communication Style

- Present findings clearly with actionable recommendations
- Use severity levels consistently across all reports
- Include specific file:line references for all issues
- Provide code examples for fixes when possible
- Respond in Japanese to the user
