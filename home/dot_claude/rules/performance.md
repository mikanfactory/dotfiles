# Performance Rules

## Model Selection

| Model | Use Case | Cost |
|-------|----------|------|
| Opus | Complex reasoning, architecture decisions, research | High |
| Sonnet | Standard development, orchestration | Medium |
| Haiku | Simple tasks, pair programming, repetitive work | Low |

**Default**: Opus (per settings.json)

## Context Window Management

### Efficient File Reading
- Use `Glob` and `Grep` before reading files
- Read specific line ranges when possible
- Avoid loading entire large files

### Parallel Tool Calls (per CLAUDE.md)
- Batch independent file reads in single message
- Run multiple searches concurrently
- Use parallel agents for independent tasks

### Library Information
- Use **Context7 MCP** for library documentation (per CLAUDE.md)
- Avoid reading entire library source code

## Code Performance Guidelines

### Python
- Profile with `cProfile` before optimizing
- Use generators for large datasets
- Prefer comprehensions over explicit loops
- Consider async for I/O-bound operations

```python
# GOOD: Generator for memory efficiency
def process_lines(path: Path) -> Iterator[str]:
    with open(path) as f:
        for line in f:
            yield line.strip()
```

### Go
- Benchmark before optimizing (`go test -bench`)
- Use `sync.Pool` for frequent allocations
- Pre-allocate slices with known capacity
- Profile with `pprof`

```go
// GOOD: Pre-allocate slice
results := make([]Result, 0, len(items))
for _, item := range items {
    results = append(results, process(item))
}
```

## Build Issue Resolution

When builds fail:
1. Use `build-error-resolver` agent if available
2. Examine error messages systematically
3. Apply incremental fixes
4. Test after each correction
