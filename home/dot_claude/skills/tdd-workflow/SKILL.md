---
name: tdd-workflow
description: Use this skill when writing new features, fixing bugs, or refactoring Python code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.
allowed-tools: Bash, Read, Write, Edit
model: sonnet
---

# Test-Driven Development Workflow

This skill ensures all Python code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new modules

## Core Principles

### 1. Tests BEFORE Code
ALWAYS write tests first, then implement code to make tests pass.

### 2. Coverage Requirements
- Minimum 80% coverage (unit + integration + E2E)
- All edge cases covered
- Error scenarios tested
- Boundary conditions verified

### 3. Test Types

#### Unit Tests
- Individual functions and utilities
- Module logic
- Pure functions
- Helpers and utilities

#### Integration Tests
- API endpoints
- Database operations
- Service interactions
- External API calls

#### E2E Tests (Playwright)
- Critical user flows
- Complete workflows
- Browser automation
- UI interactions

## TDD Workflow Steps

### Step 1: Write User Stories
```
As a [role], I want to [action], so that [benefit]

Example:
As a user, I want to search for markets semantically,
so that I can find relevant markets even without exact keywords.
```

### Step 2: Generate Test Cases
For each user story, create comprehensive test cases:

```python
import pytest

class TestSemanticSearch:
    def test_returns_relevant_markets_for_query(self):
        # Test implementation
        pass

    def test_handles_empty_query_gracefully(self):
        # Test edge case
        pass

    def test_falls_back_to_substring_search_when_redis_unavailable(self):
        # Test fallback behavior
        pass

    def test_sorts_results_by_similarity_score(self):
        # Test sorting logic
        pass
```

### Step 3: Run Tests (They Should Fail)
```bash
uv run pytest
# Tests should fail - we haven't implemented yet
```

### Step 4: Implement Code
Write minimal code to make tests pass:

```python
# Implementation guided by tests
async def search_markets(query: str) -> list[Market]:
    # Implementation here
    pass
```

### Step 5: Run Tests Again
```bash
uv run pytest
# Tests should now pass
```

### Step 6: Refactor
Improve code quality while keeping tests green:
- Remove duplication
- Improve naming
- Optimize performance
- Enhance readability

### Step 7: Verify Coverage
```bash
uv run pytest --cov=src --cov-report=term-missing
# Verify 80%+ coverage achieved
```

## Testing Patterns

### Unit Test Pattern (pytest)
```python
import pytest
from mymodule import Button

class TestButton:
    def test_renders_with_correct_text(self):
        button = Button(text="Click me")
        assert button.text == "Click me"

    def test_calls_onclick_when_clicked(self):
        clicked = False

        def on_click():
            nonlocal clicked
            clicked = True

        button = Button(on_click=on_click)
        button.click()

        assert clicked is True

    def test_is_disabled_when_disabled_prop_is_true(self):
        button = Button(disabled=True)
        assert button.disabled is True
```

### API Integration Test Pattern
```python
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
class TestMarketsAPI:
    async def test_returns_markets_successfully(self):
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/markets")

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert isinstance(data["data"], list)

    async def test_validates_query_parameters(self):
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/markets", params={"limit": "invalid"})

        assert response.status_code == 400

    async def test_handles_database_errors_gracefully(self, mocker):
        mocker.patch("app.db.get_markets", side_effect=Exception("DB Error"))

        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/markets")

        assert response.status_code == 500
```

### E2E Test Pattern (Playwright)
```python
import pytest
from playwright.async_api import Page, expect

@pytest.mark.asyncio
class TestMarketSearch:
    async def test_user_can_search_and_filter_markets(self, page: Page):
        # Navigate to markets page
        await page.goto("/")
        await page.click('a[href="/markets"]')

        # Verify page loaded
        await expect(page.locator("h1")).to_contain_text("Markets")

        # Search for markets
        await page.fill('input[placeholder="Search markets"]', "election")

        # Wait for debounce and results
        await page.wait_for_timeout(600)

        # Verify search results displayed
        results = page.locator('[data-testid="market-card"]')
        await expect(results).to_have_count(5, timeout=5000)

        # Filter by status
        await page.click('button:has-text("Active")')

        # Verify filtered results
        await expect(results).to_have_count(3)

    async def test_user_can_create_new_market(self, page: Page):
        # Login first
        await page.goto("/creator-dashboard")

        # Fill market creation form
        await page.fill('input[name="name"]', "Test Market")
        await page.fill('textarea[name="description"]', "Test description")
        await page.fill('input[name="endDate"]', "2025-12-31")

        # Submit form
        await page.click('button[type="submit"]')

        # Verify success message
        await expect(page.locator("text=Market created successfully")).to_be_visible()
```

## Test File Organization

```
project/
├── src/
│   ├── components/
│   │   └── button.py
│   ├── services/
│   │   └── market_service.py
│   └── api/
│       └── markets.py
├── tests/
│   ├── unit/
│   │   ├── test_button.py
│   │   └── test_market_service.py
│   ├── integration/
│   │   └── test_markets_api.py
│   └── e2e/
│       ├── test_market_search.py
│       └── test_trading.py
└── conftest.py
```

## Mocking External Services

### Mock Database
```python
@pytest.fixture
def mock_db(mocker):
    return mocker.patch("app.db.get_markets", return_value=[
        {"id": 1, "name": "Test Market"}
    ])
```

### Mock Redis
```python
@pytest.fixture
def mock_redis(mocker):
    return mocker.patch(
        "app.services.redis.search_markets_by_vector",
        return_value=[
            {"slug": "test-market", "similarity_score": 0.95}
        ]
    )
```

### Mock External API
```python
@pytest.fixture
def mock_openai(mocker):
    return mocker.patch(
        "app.services.openai.generate_embedding",
        return_value=[0.1] * 1536  # Mock 1536-dim embedding
    )
```

## Test Coverage Verification

### Run Coverage Report
```bash
uv run pytest --cov=src --cov-report=html
```

### Coverage Configuration (pyproject.toml)
```toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-fail-under=80"

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

## Common Testing Mistakes to Avoid

### BAD: Testing Implementation Details
```python
# Don't test internal state
assert obj._internal_count == 5
```

### GOOD: Test User-Visible Behavior
```python
# Test what users see
assert obj.count == 5
```

### BAD: Brittle Selectors
```python
# Breaks easily
await page.click(".css-class-xyz")
```

### GOOD: Semantic Selectors
```python
# Resilient to changes
await page.click('button:has-text("Submit")')
await page.click('[data-testid="submit-button"]')
```

### BAD: No Test Isolation
```python
# Tests depend on each other
def test_creates_user(): ...
def test_updates_same_user(): ...  # depends on previous test
```

### GOOD: Independent Tests
```python
# Each test sets up its own data
def test_creates_user():
    user = create_test_user()
    # Test logic

def test_updates_user():
    user = create_test_user()
    # Update logic
```

## Continuous Testing

### Watch Mode During Development
```bash
uv run pytest-watch
# Tests run automatically on file changes
```

### Pre-Commit Hook
```bash
# Runs before every commit
uv run pytest && uv run ruff check
```

### CI/CD Integration (GitHub Actions)
```yaml
- name: Run Tests
  run: uv run pytest --cov --cov-fail-under=80
```

## Best Practices

1. **Write Tests First** - Always TDD
2. **One Assert Per Test** - Focus on single behavior
3. **Descriptive Test Names** - Explain what's tested
4. **Arrange-Act-Assert** - Clear test structure
5. **Mock External Dependencies** - Isolate unit tests
6. **Test Edge Cases** - None, empty, large
7. **Test Error Paths** - Not just happy paths
8. **Keep Tests Fast** - Unit tests < 50ms each
9. **Clean Up After Tests** - No side effects
10. **Review Coverage Reports** - Identify gaps

## Success Metrics

- 80%+ code coverage achieved
- All tests passing (green)
- No skipped or disabled tests
- Fast test execution (< 30s for unit tests)
- E2E tests cover critical user flows
- Tests catch bugs before production

---

**Remember**: Tests are not optional. They are the safety net that enables confident refactoring, rapid development, and production reliability.
