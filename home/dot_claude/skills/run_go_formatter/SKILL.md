---
name: run_go_formatter
description: Run Go formatter (go fmt) on the entire project or specified directory.
allowed-tools: Bash
model: sonnet
---

# Go Formatter Skill

This skill formats Go code using the standard `go fmt` tool.

## Task Steps

1. **Check if this is a Go project**:
   - Verify `go.mod` exists in the current directory
   - If not, ask the user which directory to format

2. **Run go fmt**:
   - Execute: `go fmt ./...`
   - This formats all Go files in the current directory and subdirectories

3. **Report results**:
   - List which files were formatted (if any)
   - Report if no formatting changes were needed

## Constraints

- Only run on Go projects (where `go.mod` exists)
- Always use `go fmt ./...` to format all files recursively
- Report all formatted files to the user

## Example Workflow

```
1. Checking for go.mod...
   ✓ Found go.mod - this is a Go project

2. Running formatter: go fmt ./...
   ✓ Formatted:
     - cmd/server/main.go
     - internal/handlers/user.go
     - pkg/utils/validator.go

3. Complete: 3 files formatted
```
