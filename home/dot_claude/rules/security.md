# Security Rules

## Mandatory Checks Before Commit

1. No hardcoded secrets (API keys, passwords, tokens)
2. All user inputs validated and sanitized
3. Parameterized queries for database operations
4. Proper error handling (no sensitive info in errors)
5. Authentication/authorization verified
6. CSRF protection implemented where needed

## Secret Management

**WRONG:**
```python
API_KEY = "sk-1234567890abcdef"
```

**CORRECT:**
```python
import os
API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    raise ValueError("API_KEY environment variable required")
```

### Tools for Secret Detection
- `gitleaks` - Git repository scanner
- `git-secrets` - AWS credentials scanner
- `bandit` - Python security linter
- `gosec` - Go security checker

## Input Validation

- Validate ALL external inputs (user input, API responses, file contents)
- Use schema validation (Pydantic for Python, struct validation for Go)
- Sanitize inputs before database queries or shell commands
- Escape HTML output to prevent XSS

## Security Incident Response

1. **Stop** - Immediately halt current work
2. **Escalate** - Use `security-engineer` agent for analysis
3. **Remediate** - Fix critical vulnerabilities before resuming
4. **Scan** - Check entire codebase for similar issues
5. **Rotate** - If credentials exposed, rotate them immediately

## Dependency Security

- Regular audits: `pip-audit` (Python), `govulncheck` (Go)
- Pin dependency versions in lock files
- Monitor security advisories for dependencies
- Review and update vulnerable packages promptly
