---
allowed-tools: Bash(uv run pytest:*), Bash(pytest:*), Bash(python -m pytest:*), Read, Write, Edit, Glob, Grep
description: Enforce test-driven development workflow for Python. Scaffold interfaces, generate tests FIRST, then implement minimal code to pass. Ensure 80%+ coverage.
---

# TDD Command

This command invokes the **tdd-guide** agent to enforce test-driven development methodology for Python.

## What This Command Does

1. **Scaffold Interfaces** - Define types/dataclasses first
2. **Generate Tests First** - Write failing tests (RED)
3. **Implement Minimal Code** - Write just enough to pass (GREEN)
4. **Refactor** - Improve code while keeping tests green (REFACTOR)
5. **Verify Coverage** - Ensure 80%+ test coverage

## When to Use

Use `/tdd` when:
- Implementing new features
- Adding new functions/modules
- Fixing bugs (write test that reproduces bug first)
- Refactoring existing code
- Building critical business logic

## How It Works

The tdd-guide agent will:

1. **Define interfaces** for inputs/outputs using dataclasses or Pydantic
2. **Write tests that will FAIL** (because code doesn't exist yet)
3. **Run tests** and verify they fail for the right reason
4. **Write minimal implementation** to make tests pass
5. **Run tests** and verify they pass
6. **Refactor** code while keeping tests green
7. **Check coverage** and add more tests if below 80%

## TDD Cycle

```
RED -> GREEN -> REFACTOR -> REPEAT

RED:      Write a failing test
GREEN:    Write minimal code to pass
REFACTOR: Improve code, keep tests passing
REPEAT:   Next feature/scenario
```

## Example Usage

```
User: /tdd I need a function to calculate market liquidity score

Agent (tdd-guide):
# TDD Session: Market Liquidity Score Calculator

## Step 1: Define Interface (SCAFFOLD)

```python
# src/liquidity.py
from dataclasses import dataclass
from datetime import datetime

@dataclass
class MarketData:
    total_volume: float
    bid_ask_spread: float
    active_traders: int
    last_trade_time: datetime

def calculate_liquidity_score(market: MarketData) -> float:
    # TODO: Implementation
    raise NotImplementedError()
```

## Step 2: Write Failing Test (RED)

```python
# tests/test_liquidity.py
import pytest
from datetime import datetime, timedelta
from src.liquidity import calculate_liquidity_score, MarketData

class TestCalculateLiquidityScore:
    def test_returns_high_score_for_liquid_market(self):
        market = MarketData(
            total_volume=100000,
            bid_ask_spread=0.01,
            active_traders=500,
            last_trade_time=datetime.now()
        )

        score = calculate_liquidity_score(market)

        assert score > 80
        assert score <= 100

    def test_returns_low_score_for_illiquid_market(self):
        market = MarketData(
            total_volume=100,
            bid_ask_spread=0.5,
            active_traders=2,
            last_trade_time=datetime.now() - timedelta(days=1)
        )

        score = calculate_liquidity_score(market)

        assert score < 30
        assert score >= 0

    def test_returns_zero_for_zero_volume(self):
        market = MarketData(
            total_volume=0,
            bid_ask_spread=0,
            active_traders=0,
            last_trade_time=datetime.now()
        )

        score = calculate_liquidity_score(market)

        assert score == 0
```

## Step 3: Run Tests - Verify FAIL

```bash
uv run pytest tests/test_liquidity.py -v

FAILED tests/test_liquidity.py::TestCalculateLiquidityScore::test_returns_high_score_for_liquid_market
    NotImplementedError

1 failed, 0 passed
```

Tests fail as expected. Ready to implement.

## Step 4: Implement Minimal Code (GREEN)

```python
# src/liquidity.py
from datetime import datetime

def calculate_liquidity_score(market: MarketData) -> float:
    # Handle zero volume edge case
    if market.total_volume == 0:
        return 0.0

    # Calculate component scores (0-100 scale)
    volume_score = min(market.total_volume / 1000, 100)
    spread_score = max(100 - (market.bid_ask_spread * 1000), 0)
    trader_score = min(market.active_traders / 10, 100)

    # Recent activity bonus
    hours_since_last_trade = (
        datetime.now() - market.last_trade_time
    ).total_seconds() / 3600
    recency_score = max(100 - (hours_since_last_trade * 10), 0)

    # Weighted average
    score = (
        volume_score * 0.4 +
        spread_score * 0.3 +
        trader_score * 0.2 +
        recency_score * 0.1
    )

    return min(max(score, 0), 100)  # Clamp to 0-100
```

## Step 5: Run Tests - Verify PASS

```bash
uv run pytest tests/test_liquidity.py -v

PASSED tests/test_liquidity.py::TestCalculateLiquidityScore::test_returns_high_score_for_liquid_market
PASSED tests/test_liquidity.py::TestCalculateLiquidityScore::test_returns_low_score_for_illiquid_market
PASSED tests/test_liquidity.py::TestCalculateLiquidityScore::test_returns_zero_for_zero_volume

3 passed
```

All tests passing!

## Step 6: Refactor (IMPROVE)

```python
# src/liquidity.py - Refactored with constants
from dataclasses import dataclass
from datetime import datetime

WEIGHTS = {
    "volume": 0.4,
    "spread": 0.3,
    "traders": 0.2,
    "recency": 0.1,
}

SCALE_FACTORS = {
    "volume": 1000,
    "spread": 1000,
    "traders": 10,
    "recency_penalty": 10,
}

def _clamp(value: float, min_val: float, max_val: float) -> float:
    return min(max(value, min_val), max_val)

def calculate_liquidity_score(market: MarketData) -> float:
    if market.total_volume == 0:
        return 0.0

    volume_score = min(market.total_volume / SCALE_FACTORS["volume"], 100)
    spread_score = _clamp(100 - (market.bid_ask_spread * SCALE_FACTORS["spread"]), 0, 100)
    trader_score = min(market.active_traders / SCALE_FACTORS["traders"], 100)

    hours_since_last_trade = (
        datetime.now() - market.last_trade_time
    ).total_seconds() / 3600
    recency_score = _clamp(100 - (hours_since_last_trade * SCALE_FACTORS["recency_penalty"]), 0, 100)

    weighted_score = (
        volume_score * WEIGHTS["volume"] +
        spread_score * WEIGHTS["spread"] +
        trader_score * WEIGHTS["traders"] +
        recency_score * WEIGHTS["recency"]
    )

    return _clamp(weighted_score, 0, 100)
```

## Step 7: Verify Tests Still Pass

```bash
uv run pytest tests/test_liquidity.py -v

3 passed
```

Refactoring complete, tests still passing!

## Step 8: Check Coverage

```bash
uv run pytest --cov=src/liquidity --cov-report=term-missing tests/test_liquidity.py

Name               Stmts   Miss  Cover   Missing
------------------------------------------------
src/liquidity.py      25      0   100%
------------------------------------------------
TOTAL                 25      0   100%

Coverage: 100% (Target: 80%)
```

TDD session complete!
```

## TDD Best Practices

**DO:**
- Write the test FIRST, before any implementation
- Run tests and verify they FAIL before implementing
- Write minimal code to make tests pass
- Refactor only after tests are green
- Add edge cases and error scenarios
- Aim for 80%+ coverage (100% for critical code)

**DON'T:**
- Write implementation before tests
- Skip running tests after each change
- Write too much code at once
- Ignore failing tests
- Test implementation details (test behavior)
- Mock everything (prefer integration tests)

## Test Types to Include

**Unit Tests** (Function-level):
- Happy path scenarios
- Edge cases (empty, None, max values)
- Error conditions
- Boundary values

**Integration Tests** (Component-level):
- API endpoints
- Database operations
- External service calls

**E2E Tests** (use Playwright):
- Critical user flows
- Multi-step processes
- Full stack integration

## Coverage Requirements

- **80% minimum** for all code
- **100% required** for:
  - Financial calculations
  - Authentication logic
  - Security-critical code
  - Core business logic

## Important Notes

**MANDATORY**: Tests must be written BEFORE implementation. The TDD cycle is:

1. **RED** - Write failing test
2. **GREEN** - Implement to pass
3. **REFACTOR** - Improve code

Never skip the RED phase. Never write code before tests.

## Integration with Other Commands

- Use `/plan` first to understand what to build
- Use `/tdd` to implement with tests
- Use `/run_python_formatter` if format/type errors occur
- Use `/review_python` to review implementation

## Related Agents

This command invokes the `tdd-guide` agent located at:
`~/.claude/agents/tdd-guide.md`

And can reference the `tdd-workflow` skill at:
`~/.claude/skills/tdd-workflow/`
