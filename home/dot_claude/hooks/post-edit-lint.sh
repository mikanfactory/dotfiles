#!/bin/bash
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

if [[ -z "$CWD" ]] || [[ ! -d "$CWD" ]]; then
  exit 0
fi

# 変更されたファイルを取得（unstaged + staged）
CHANGED_FILES=$(cd "$CWD" && {
  git diff --name-only HEAD 2>/dev/null
  git diff --name-only --cached 2>/dev/null
} | sort -u)

# 変更なし → 即終了
if [[ -z "$CHANGED_FILES" ]]; then
  exit 0
fi

ERRORS=""

# Python files変更あり & pyproject.toml存在 → backend lint
if echo "$CHANGED_FILES" | grep -q '\.py$' && [[ -f "$CWD/pyproject.toml" ]]; then
  if ! (cd "$CWD" && mise backend:lint:fix 2>&1); then
    ERRORS="${ERRORS}Backend lint failed.\n"
  fi
fi

# TypeScript/JS files変更あり & package.json存在 → frontend lint
if echo "$CHANGED_FILES" | grep -qE '\.(ts|tsx|js|jsx)$' && [[ -f "$CWD/package.json" ]]; then
  if ! (cd "$CWD" && mise frontend:lint:fix 2>&1); then
    ERRORS="${ERRORS}Frontend lint failed.\n"
  fi
fi

# エラーがあればブロック
if [[ -n "$ERRORS" ]]; then
  echo -e "$ERRORS" >&2
  exit 2
fi

exit 0
