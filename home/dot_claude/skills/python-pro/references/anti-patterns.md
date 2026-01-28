# Anti-Patterns Reference

Common Python anti-patterns to avoid with explanations and solutions.

## Table of Contents

- [Type System](#type-system)
- [Async Programming](#async-programming)
- [Resource Management](#resource-management)
- [Testing](#testing)
- [Security](#security)
- [Performance](#performance)

---

## Type System

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| `def func(data: Any)` | Bypasses all type checking | Use proper types, Generic, or Protocol |
| `# type: ignore` without comment | Hides real issues | Add explanation: `# type: ignore[arg-type]  # reason` |
| `cast()` to silence errors | Runtime type mismatch risk | Fix underlying type issue |
| `dict` instead of TypedDict | No structure validation | Use TypedDict for known keys |
| Missing return type | Incomplete type signature | Always specify return type |
| `Optional` without None check | NoneType errors at runtime | Use `if x is not None:` guard |

### Examples

**Any Abuse**
```python
# BAD
def process(data: Any) -> Any:
    return data.transform()  # No type checking

# GOOD
from typing import Protocol

class Transformable(Protocol):
    def transform(self) -> Result: ...

def process(data: Transformable) -> Result:
    return data.transform()
```

**Unsafe Cast**
```python
# BAD
result = cast(User, response.json())  # May not be User at runtime

# GOOD
user_data = UserSchema.model_validate(response.json())  # Pydantic validates
```

---

## Async Programming

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| `asyncio.run()` inside async | RuntimeError | Use `await` directly |
| Blocking call in async | Event loop blocked | Use `run_in_executor` |
| Missing exception handling in TaskGroup | Silent failures | Add explicit error handling |
| Creating tasks without awaiting | Tasks may be garbage collected | Use TaskGroup or gather |
| Shared mutable state without lock | Race conditions | Use `asyncio.Lock` |
| `time.sleep()` in async | Blocks event loop | Use `await asyncio.sleep()` |

### Examples

**Blocking Call in Async**
```python
# BAD
async def fetch_data():
    data = requests.get(url)  # Blocks event loop
    return data.json()

# GOOD
async def fetch_data():
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.json()

# Or for CPU-bound:
async def process_data():
    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(None, cpu_intensive_function)
    return result
```

**Missing TaskGroup Error Handling**
```python
# BAD
async def process_all(items):
    async with asyncio.TaskGroup() as tg:
        for item in items:
            tg.create_task(process(item))  # One failure crashes all

# GOOD
async def process_all(items):
    results = []
    errors = []
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(safe_process(item)) for item in items]
    for task in tasks:
        result = task.result()
        if isinstance(result, Exception):
            errors.append(result)
        else:
            results.append(result)
    return results, errors

async def safe_process(item):
    try:
        return await process(item)
    except Exception as e:
        return e
```

---

## Resource Management

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| `file = open(...)` without `with` | Resource leak | Use context manager |
| Manual cleanup in finally | Error-prone, verbose | Use `@contextmanager` |
| Global mutable state | Thread-safety issues | Use dependency injection |
| Unclosed database connections | Connection exhaustion | Use connection pool with context |
| Creating resources in __init__ | Hard to test, cleanup issues | Use factory pattern or context manager |

### Examples

**Resource Leak**
```python
# BAD
def read_file(path):
    f = open(path)
    content = f.read()
    f.close()  # Not called if read() raises
    return content

# GOOD
def read_file(path: Path) -> str:
    with open(path) as f:
        return f.read()
```

**Global Mutable State**
```python
# BAD
_cache = {}  # Global mutable state

def get_user(user_id: str) -> User:
    if user_id not in _cache:
        _cache[user_id] = fetch_user(user_id)
    return _cache[user_id]

# GOOD
class UserService:
    def __init__(self, cache: Cache) -> None:
        self._cache = cache

    def get_user(self, user_id: str) -> User:
        if user_id not in self._cache:
            self._cache[user_id] = self._fetch_user(user_id)
        return self._cache[user_id]
```

---

## Testing

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Mocking too much | Tests don't verify real behavior | Test integration with real dependencies |
| Testing implementation details | Brittle tests | Test behavior and contracts |
| No edge case testing | Bugs in boundary conditions | Use parametrized tests |
| Shared test state | Flaky tests, order dependency | Use fixtures with proper scope |
| Missing async test markers | Tests don't run async code | Use `@pytest.mark.asyncio` |
| Assertions without messages | Hard to debug failures | Add descriptive assertion messages |

### Examples

**Mocking Too Much**
```python
# BAD - mocks everything, tests nothing
def test_user_service():
    mock_repo = Mock()
    mock_repo.get.return_value = User(id="1", name="Test")
    service = UserService(mock_repo)

    result = service.get_user("1")

    assert result.name == "Test"  # Only tests the mock

# GOOD - integration test with real behavior
@pytest.fixture
def db_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    with Session(engine) as session:
        yield session

def test_user_service(db_session):
    repo = UserRepository(db_session)
    service = UserService(repo)
    user = User(id="1", name="Test")
    repo.save(user)

    result = service.get_user("1")

    assert result.name == "Test"  # Tests real query
```

**Testing Implementation Details**
```python
# BAD - tests internal method calls
def test_process_order():
    service = OrderService()
    service._validate = Mock()
    service._calculate_total = Mock(return_value=100)

    service.process(order)

    service._validate.assert_called_once()  # Brittle

# GOOD - tests behavior
def test_process_order():
    service = OrderService()
    order = Order(items=[Item(price=50), Item(price=50)])

    result = service.process(order)

    assert result.total == 100
    assert result.status == "processed"
```

---

## Security

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Hardcoded secrets | Credentials in source code | Use environment variables |
| SQL string formatting | SQL injection | Use parameterized queries |
| `eval()` / `exec()` on user input | Code injection | Never eval untrusted input |
| Weak password hashing | Easy to crack | Use bcrypt or argon2 |
| Missing input validation | Injection attacks | Validate all external input |
| Verbose error messages in production | Information disclosure | Use generic error messages |

### Examples

**SQL Injection**
```python
# BAD
def get_user(username: str) -> User:
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return db.execute(query).fetchone()

# GOOD
def get_user(username: str) -> User:
    query = "SELECT * FROM users WHERE username = :username"
    return db.execute(query, {"username": username}).fetchone()
```

**Hardcoded Secrets**
```python
# BAD
API_KEY = "sk-1234567890abcdef"

# GOOD
import os
API_KEY = os.environ["API_KEY"]

# Or with pydantic-settings
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    api_key: str

    class Config:
        env_file = ".env"

settings = Settings()
```

---

## Performance

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| N+1 queries | Database overload | Use eager loading or batch queries |
| String concatenation in loop | O(n^2) complexity | Use `"".join()` or StringIO |
| Loading entire file into memory | Memory exhaustion | Use generators or streaming |
| Premature optimization | Wasted effort, complex code | Profile first, optimize hot paths |
| Missing indexes | Slow queries | Add indexes for WHERE/JOIN columns |
| Creating objects in hot loop | GC pressure | Reuse objects or use `__slots__` |

### Examples

**N+1 Query**
```python
# BAD - N+1 queries
def get_orders_with_items():
    orders = db.query(Order).all()
    for order in orders:
        items = order.items  # Lazy load, 1 query per order
    return orders

# GOOD - eager loading
def get_orders_with_items():
    return db.query(Order).options(selectinload(Order.items)).all()
```

**String Concatenation**
```python
# BAD - O(n^2) for large lists
def build_report(items: list[str]) -> str:
    result = ""
    for item in items:
        result += item + "\n"
    return result

# GOOD - O(n)
def build_report(items: list[str]) -> str:
    return "\n".join(items)
```

**Loading Large Files**
```python
# BAD - loads entire file
def process_log(path: Path) -> list[dict]:
    with open(path) as f:
        lines = f.readlines()  # Entire file in memory
    return [json.loads(line) for line in lines]

# GOOD - streaming
def process_log(path: Path) -> Iterator[dict]:
    with open(path) as f:
        for line in f:
            yield json.loads(line)
```
