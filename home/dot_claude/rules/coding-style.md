# Coding Style Rules

## General Principles

- **Immutability**: Create new objects, never mutate existing ones
- **File size**: 200-400 lines typical, 800 lines maximum
- **Function size**: Single responsibility, under 50 lines
- **Nesting**: Maximum 4 levels deep
- **No hardcoded values** (per CLAUDE.md)

## Python Style

### Type Safety
- Type hints for ALL function signatures
- No `any` or `unknown` types (per CLAUDE.md)
- Use `Protocol` for duck typing instead of ABCs

### Class Usage
- Avoid classes unless necessary (per CLAUDE.md)
- Use `dataclass(frozen=True)` for immutable data structures
- Exception: Custom errors requiring `isinstance` checks

### Formatting
- Black formatter (line length 88)
- isort for imports
- ruff for linting

### Patterns
```python
# GOOD: Immutable dataclass
@dataclass(frozen=True)
class Config:
    host: str
    port: int

# BAD: Mutable class
class Config:
    def __init__(self):
        self.host = ""
        self.port = 0
```

## Go Style

### Core Principles
- `gofmt` and `golangci-lint` compliance
- Accept interfaces, return structs
- Explicit error handling (no panic for recoverable errors)

### Patterns
```go
// GOOD: Accept interface
func Process(r io.Reader) error {
    // ...
}

// GOOD: Return concrete type
func NewService(cfg Config) *Service {
    return &Service{cfg: cfg}
}

// GOOD: Wrap errors with context
if err != nil {
    return fmt.Errorf("failed to process: %w", err)
}
```

## Quality Checklist

Before completion, verify:
- [ ] Code is readable with clear naming
- [ ] Functions under 50 lines
- [ ] Files under 800 lines
- [ ] Nesting under 4 levels
- [ ] Proper error handling
- [ ] No console.log/print statements (except logging)
- [ ] No hardcoded values
- [ ] Consistent immutable patterns
