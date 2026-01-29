# Git Workflow Rules

## Commit Message Format

```
type(scope): description

[optional body]
```

### Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting, no code change
- `refactor` - Code change without feature/fix
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

### Constraints (per commit.md)
- **ALL commit messages MUST be written in English**
- **DO NOT add Claude co-authorship footer**
- Keep subject line under 50 characters
- Body explains WHY, not WHAT

## Commit Best Practices

- **Atomic commits**: One logical change per commit
- Each commit should be independently revertable
- Use `git-commit-splitter` agent for complex changes
- Stage related changes together

## Branch Strategy

- Feature branches from main/master
- Use descriptive branch names: `feature/add-auth`, `fix/login-bug`
- PR workflow for all changes to main
- Delete branches after merge

## Feature Implementation Phases

1. **Planning** - Design and scope with `planner` agent
2. **TDD** - Write tests first with `tdd-guide` agent
3. **Implementation** - Code changes
4. **Review** - Code review with `code-reviewer` agent
5. **Merge** - PR and integration

## Pre-commit Checklist

- [ ] Tests pass
- [ ] Linters pass (ruff, golangci-lint)
- [ ] No secrets in code
- [ ] Commit message follows format
- [ ] Changes are atomic
