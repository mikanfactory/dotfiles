---
name: review-go
description: Perform comprehensive Go backend code review using multiple specialized agents
context: fork
agent: golang-pro
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

Orchestrate a comprehensive Go backend code review by coordinating multiple specialized agents through the `backend-review-orchestrator` agent.

### Step 1: Determine review scope

Identify which Go files to review based on the following priority:

**Option A: Review changed/staged files (default)**
If there are staged or uncommitted changes, review those files:
```bash
git diff --name-only --cached HEAD
git diff --name-only HEAD
```

**Option B: Review specific path**
If user specified a path argument (e.g., `/review-go cmd/api/`), use that path as the review target.

**Option C: Review all Go backend files**
If user requests full review or no changes exist, scan for all Go backend files:
```bash
find . -type f -name "*.go" \
  ! -path "*/vendor/*" ! -path "*/.git/*"
```

**File filtering:**
- Include: `*.go` in backend-relevant paths
- Exclude: `vendor/`, `.git/`
- Maximum: 50 files per review session

### Step 2: Analyze file context

For each file to review, gather:
1. File path and size
2. Primary language (Go)
3. Functional area hints (from path: cmd/, internal/, pkg/, api/, services/, models/, auth/, db/)
4. Framework detection (Gin, Echo, Chi, etc.)

Create a review manifest:
```json
{
  "scope": "changed|path|all",
  "target_path": "<path or null>",
  "branch": "<current branch>",
  "files": [
    {
      "path": "internal/api/users.go",
      "language": "go",
      "area": "api",
      "framework_hints": ["gin"]
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
   - **golang-reviewer**: Go best practices, idioms, concurrency patterns
   - **backend-developer**: API design, database, microservices
   - **security-engineer**: Vulnerabilities, auth, OWASP
   - **database-administrator**: Database performance, query optimization, schema design
2. Collect JSON-formatted review outputs
3. Aggregate and deduplicate findings
4. Generate unified report

**Go-specific review focus areas:**
- **Goroutine management**: Proper goroutine lifecycle, leak detection
- **Race conditions**: Concurrent access to shared resources
- **Error handling**: Proper error wrapping and handling patterns
- **Context usage**: Proper context propagation for cancellation and timeouts
- **Defer usage**: Appropriate use of defer for resource cleanup
- **Interface design**: Proper abstraction and dependency injection
- **Memory management**: Efficient allocation and garbage collection impact

### Step 4: Present review results

Display the aggregated report from the orchestrator:

**1. Executive Summary**
```markdown
# Go Backend Code Review Report

**Files Reviewed:** X
**Total Issues:** Y

| Severity | Count |
|----------|-------|
| Critical | X |
| High | X |
| Medium | X |
| Low | X |

## Top Critical Issues (if any)
1. **GP-001** Goroutine leak in `internal/services/processor.go:45`
2. **SE-001** SQL Injection in `internal/db/queries.go:67`
```

**2. Detailed Findings by Severity**
List all issues from Critical to Low with:
- Issue ID and title
- File location with line numbers
- Category and contributing agents
- Description and recommendation
- Code suggestion (if available)

**3. Category Summary**
Group issues by category (Security, Performance, Concurrency, Error Handling, Database, etc.)

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
/review-go

# Review specific directory
/review-go internal/api/

# Review specific file
/review-go internal/services/user_service.go

# Review all Go backend files
/review-go --all
```

## Constraints

- Only review Go files (exclude frontend, static assets, configs)
- Exclude test files from security review unless specifically requested
- Maximum 50 files per review to ensure thorough analysis
- Total timeout: 10 minutes
- If no Go files found, report clearly and exit
- Always output results in Japanese when communicating with user

## Communication Style

- Present findings clearly with actionable recommendations
- Use severity levels consistently across all reports
- Include specific file:line references for all issues
- Provide code examples for fixes when possible
- Respond in Japanese to the user
