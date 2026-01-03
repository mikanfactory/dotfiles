---
name: run_typescript_formatter
description: Run TypeScript/JavaScript formatter using the project's configured formatter (npm/pnpm/yarn format script or prettier).
allowed-tools: Bash, Read
model: sonnet
---

# TypeScript Formatter Skill

This skill formats TypeScript/JavaScript code using the project's configured formatter.

## Task Steps

1. **Check if this is a Node.js/TypeScript project**:
   - Verify `package.json` exists in the current directory
   - If not, report error and exit

2. **Determine package manager and format command**:
   - Read `package.json` to check if `scripts.format` exists
   - Detect package manager:
     - `pnpm-lock.yaml` exists → use `pnpm`
     - `yarn.lock` exists → use `yarn`
     - `package-lock.json` exists → use `npm`
     - Default → use `npm`

3. **Run formatter**:
   - If `scripts.format` exists:
     - `pnpm format` (if using pnpm)
     - `yarn format` (if using yarn)
     - `npm run format` (if using npm)
   - If no format script:
     - `npx prettier --write .`

4. **Report results**:
   - Report which package manager was used
   - Report which format command was executed
   - Show formatter output

## Constraints

- Only run on Node.js/TypeScript projects (where `package.json` exists)
- Always respect the project's configured format script if it exists
- Use the detected package manager for consistency

## Example Workflow

```
1. Checking for package.json...
   ✓ Found package.json - this is a Node.js/TypeScript project

2. Detecting package manager...
   ✓ Found pnpm-lock.yaml - using pnpm

3. Checking for format script...
   ✓ Found "format": "prettier --write ." in package.json

4. Running formatter: pnpm format
   ✓ Formatted:
     - src/components/Button.tsx
     - src/utils/helpers.ts
     - src/App.tsx

5. Complete: 3 files formatted
```
