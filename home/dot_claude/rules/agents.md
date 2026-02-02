# Agent Usage Rules

## When to Use Agents

Use agents PROACTIVELY for:
- Complex feature requests
- Code reviews after writing
- Security analysis before commits
- Build failures
- Architectural decisions

## Language-Specific Agents

| Language | Development | Review |
|----------|-------------|--------|
| Python | `python-pro` | `python-reviewer` |
| Go | `golang-pro` | `golang-reviewer` |
| TypeScript | `typescript-pro` | `code-reviewer` |
| React | `react-specialist` | `code-reviewer` |

## Role-Based Agents

| Task | Agent |
|------|-------|
| Code review | `code-reviewer` |
| Security review | `security-engineer` |
| Database design | `database-administrator` |
| PostgreSQL | `postgres-pro` |
| Backend development | `backend-developer` |
| Frontend development | `frontend-developer` |
| Full-stack | `fullstack-developer` |
| Terraform/IaC | `terraform-engineer` |
| Prompt engineering | `prompt-engineer` |
| ML/Data | `ml-engineer`, `data-engineer` |
| MLOps | `mlops-engineer` |
| LLM architecture | `llm-architect` |
| Electron apps | `electron-pro` |

## Orchestration Agents

| Task | Agent |
|------|-------|
| Multi-agent code review | `backend-review-orchestrator` |
| Git commit splitting | `git-commit-splitter` |

## Execution Guidelines

### Parallel Execution (per CLAUDE.md)
- Multiple independent tasks: invoke agents concurrently
- Example: Run `python-reviewer` and `security-engineer` in parallel

### Sequential Execution
- Dependent tasks: run in order
- Example: `planner` → `code-reviewer`

### Complex Reviews
Use `backend-review-orchestrator` to coordinate:
- `python-pro` or `golang-pro` (language-specific)
- `security-engineer` (security analysis)
- `code-reviewer` (general quality)
