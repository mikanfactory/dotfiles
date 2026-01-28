# Python Patterns Reference

GOOD/BAD code examples for common Python patterns.

## Table of Contents

- [Type System](#type-system)
- [Pythonic Patterns](#pythonic-patterns)
- [Async Programming](#async-programming)
- [Error Handling](#error-handling)
- [Testing](#testing)
- [Data Structures](#data-structures)

---

## Type System

### Generic Types

**GOOD**
```python
from typing import TypeVar, Generic

T = TypeVar("T")

class Repository(Generic[T]):
    def __init__(self) -> None:
        self._items: dict[str, T] = {}

    def get(self, id: str) -> T | None:
        return self._items.get(id)

    def save(self, id: str, item: T) -> None:
        self._items[id] = item

# Usage with concrete type
user_repo: Repository[User] = Repository()
```

**BAD**
```python
class Repository:
    def __init__(self):
        self._items = {}

    def get(self, id):  # No type hints, returns Any
        return self._items.get(id)

    def save(self, id, item):  # No validation, no type safety
        self._items[id] = item
```

### Protocol Definitions

**GOOD**
```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Serializable(Protocol):
    def to_dict(self) -> dict[str, object]: ...
    def to_json(self) -> str: ...

def serialize(obj: Serializable) -> str:
    return obj.to_json()

# Any class with to_dict and to_json methods satisfies this protocol
```

**BAD**
```python
from abc import ABC, abstractmethod

class Serializable(ABC):  # Forces inheritance
    @abstractmethod
    def to_dict(self) -> dict: ...

# Requires explicit inheritance, less flexible
```

### TypedDict Usage

**GOOD**
```python
from typing import TypedDict, Required, NotRequired

class UserConfig(TypedDict):
    username: Required[str]
    email: Required[str]
    nickname: NotRequired[str]
    settings: NotRequired[dict[str, bool]]

def create_user(config: UserConfig) -> User:
    return User(
        username=config["username"],
        email=config["email"],
        nickname=config.get("nickname"),
    )
```

**BAD**
```python
def create_user(config: dict) -> User:  # No structure validation
    return User(
        username=config["username"],  # Runtime KeyError risk
        email=config["email"],
        nickname=config.get("nickname"),
    )
```

### Overloads

**GOOD**
```python
from typing import overload, Literal

@overload
def fetch_data(format: Literal["json"]) -> dict[str, object]: ...
@overload
def fetch_data(format: Literal["text"]) -> str: ...
@overload
def fetch_data(format: Literal["bytes"]) -> bytes: ...

def fetch_data(format: str) -> dict[str, object] | str | bytes:
    if format == "json":
        return {"data": "value"}
    elif format == "text":
        return "data"
    return b"data"
```

**BAD**
```python
def fetch_data(format: str) -> dict | str | bytes:  # Caller doesn't know return type
    if format == "json":
        return {"data": "value"}
    elif format == "text":
        return "data"
    return b"data"
```

---

## Pythonic Patterns

### Comprehensions vs Loops

**GOOD**
```python
# List comprehension with filter
active_users = [u for u in users if u.is_active]

# Dict comprehension
user_by_id = {u.id: u for u in users}

# Set comprehension
unique_domains = {email.split("@")[1] for email in emails}

# Generator for memory efficiency
def process_large_file(path: Path) -> Iterator[dict[str, str]]:
    with open(path) as f:
        for line in f:
            yield json.loads(line)
```

**BAD**
```python
# Unnecessary loop
active_users = []
for u in users:
    if u.is_active:
        active_users.append(u)

# Loading entire file into memory
def process_large_file(path: Path) -> list[dict]:
    with open(path) as f:
        return [json.loads(line) for line in f.readlines()]
```

### Context Managers

**GOOD**
```python
from contextlib import contextmanager, asynccontextmanager
from typing import Iterator, AsyncIterator

@contextmanager
def managed_transaction(db: Database) -> Iterator[Transaction]:
    tx = db.begin()
    try:
        yield tx
        tx.commit()
    except Exception:
        tx.rollback()
        raise

@asynccontextmanager
async def managed_connection(pool: Pool) -> AsyncIterator[Connection]:
    conn = await pool.acquire()
    try:
        yield conn
    finally:
        await pool.release(conn)
```

**BAD**
```python
def process_with_db(db: Database) -> None:
    tx = db.begin()
    try:
        do_work(tx)
        tx.commit()
    except Exception:
        tx.rollback()
        raise
    # Repeated boilerplate for every transaction
```

### Decorator Patterns

**GOOD**
```python
from functools import wraps
from typing import TypeVar, Callable, ParamSpec

P = ParamSpec("P")
R = TypeVar("R")

def retry(max_attempts: int = 3, delay: float = 1.0) -> Callable[[Callable[P, R]], Callable[P, R]]:
    def decorator(func: Callable[P, R]) -> Callable[P, R]:
        @wraps(func)
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
            last_error: Exception | None = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_error = e
                    time.sleep(delay * (2 ** attempt))
            raise last_error or RuntimeError("Retry failed")
        return wrapper
    return decorator

@retry(max_attempts=3)
def fetch_api_data() -> dict[str, object]:
    return requests.get(url).json()
```

**BAD**
```python
def retry(func):  # No type hints, loses function signature
    def wrapper(*args, **kwargs):
        for _ in range(3):
            try:
                return func(*args, **kwargs)
            except:  # Bare except
                time.sleep(1)
    return wrapper
```

---

## Async Programming

### TaskGroup Usage

**GOOD**
```python
async def fetch_all_users(user_ids: list[str]) -> list[User]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_user(uid)) for uid in user_ids]
    return [t.result() for t in tasks]

async def process_with_semaphore(items: list[str], max_concurrent: int = 10) -> list[Result]:
    semaphore = asyncio.Semaphore(max_concurrent)

    async def bounded_process(item: str) -> Result:
        async with semaphore:
            return await process_item(item)

    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(bounded_process(item)) for item in items]
    return [t.result() for t in tasks]
```

**BAD**
```python
async def fetch_all_users(user_ids: list[str]) -> list[User]:
    results = []
    for uid in user_ids:
        results.append(await fetch_user(uid))  # Sequential, not concurrent
    return results

# Or using gather without exception handling
async def fetch_all_users(user_ids: list[str]) -> list[User]:
    return await asyncio.gather(*[fetch_user(uid) for uid in user_ids])
    # One failure cancels all, no proper exception handling
```

### Async Resource Cleanup

**GOOD**
```python
class AsyncDatabasePool:
    def __init__(self, dsn: str) -> None:
        self._dsn = dsn
        self._pool: Pool | None = None

    async def __aenter__(self) -> "AsyncDatabasePool":
        self._pool = await asyncpg.create_pool(self._dsn)
        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        if self._pool:
            await self._pool.close()

    async def execute(self, query: str) -> list[Record]:
        if not self._pool:
            raise RuntimeError("Pool not initialized")
        async with self._pool.acquire() as conn:
            return await conn.fetch(query)
```

**BAD**
```python
class AsyncDatabasePool:
    def __init__(self, dsn: str) -> None:
        self._pool = None

    async def connect(self) -> None:
        self._pool = await asyncpg.create_pool(dsn)

    async def close(self) -> None:  # Easy to forget calling this
        if self._pool:
            await self._pool.close()
```

---

## Error Handling

### Exception Hierarchies

**GOOD**
```python
class ServiceError(Exception):
    """Base exception for service errors."""
    def __init__(self, message: str, code: str) -> None:
        self.message = message
        self.code = code
        super().__init__(message)

class NotFoundError(ServiceError):
    """Resource not found."""
    def __init__(self, resource: str, id: str) -> None:
        super().__init__(f"{resource} not found: {id}", "NOT_FOUND")
        self.resource = resource
        self.id = id

class ValidationError(ServiceError):
    """Input validation failed."""
    def __init__(self, field: str, reason: str) -> None:
        super().__init__(f"Validation failed for {field}: {reason}", "VALIDATION_ERROR")
        self.field = field
        self.reason = reason
```

**BAD**
```python
def get_user(user_id: str) -> User:
    user = db.get(user_id)
    if not user:
        raise Exception(f"User not found: {user_id}")  # Generic exception
    return user
```

### Error Wrapping

**GOOD**
```python
async def fetch_user_profile(user_id: str) -> UserProfile:
    try:
        user = await user_service.get(user_id)
    except DatabaseError as e:
        raise NotFoundError("user", user_id) from e  # Preserves stack trace

    try:
        preferences = await preferences_service.get(user_id)
    except ExternalServiceError as e:
        logger.warning("Failed to fetch preferences", exc_info=e)
        preferences = DEFAULT_PREFERENCES  # Graceful degradation

    return UserProfile(user=user, preferences=preferences)
```

**BAD**
```python
async def fetch_user_profile(user_id: str) -> UserProfile:
    try:
        user = await user_service.get(user_id)
        preferences = await preferences_service.get(user_id)
        return UserProfile(user=user, preferences=preferences)
    except Exception:  # Catches everything, loses context
        return None  # Returns None instead of raising
```

---

## Testing

### Fixtures and Parameterization

**GOOD**
```python
import pytest
from collections.abc import Iterator

@pytest.fixture
def db_session() -> Iterator[Session]:
    session = Session()
    session.begin()
    yield session
    session.rollback()

@pytest.fixture
def sample_user(db_session: Session) -> User:
    user = User(name="Test User", email="test@example.com")
    db_session.add(user)
    db_session.flush()
    return user

@pytest.mark.parametrize(
    "email,expected_valid",
    [
        ("user@example.com", True),
        ("user@subdomain.example.com", True),
        ("invalid-email", False),
        ("", False),
        ("user@", False),
    ],
)
def test_email_validation(email: str, expected_valid: bool) -> None:
    assert validate_email(email) == expected_valid
```

**BAD**
```python
def test_email_validation() -> None:
    assert validate_email("user@example.com") == True
    assert validate_email("invalid") == False
    # No clear test cases, hard to identify failures
```

### Async Test Patterns

**GOOD**
```python
import pytest

@pytest.mark.asyncio
async def test_fetch_user(mock_db: AsyncMock) -> None:
    mock_db.get.return_value = User(id="1", name="Test")

    result = await user_service.fetch("1")

    assert result.name == "Test"
    mock_db.get.assert_awaited_once_with("1")

@pytest.fixture
def mock_db() -> AsyncMock:
    return AsyncMock(spec=Database)
```

**BAD**
```python
def test_fetch_user() -> None:
    # Blocking call in test, may hang
    result = asyncio.run(user_service.fetch("1"))
    assert result is not None
```

---

## Data Structures

### Dataclass Usage

**GOOD**
```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass(frozen=True, slots=True)
class Event:
    id: str
    name: str
    timestamp: datetime
    metadata: dict[str, str] = field(default_factory=dict)

    def __post_init__(self) -> None:
        if not self.id:
            raise ValueError("Event ID cannot be empty")
```

**BAD**
```python
class Event:
    def __init__(self, id, name, timestamp, metadata=None):
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.metadata = metadata or {}  # Mutable default workaround
```

### Pydantic for Validation

**GOOD**
```python
from pydantic import BaseModel, EmailStr, field_validator

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    age: int

    @field_validator("username")
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        if not v.isalnum():
            raise ValueError("Username must be alphanumeric")
        return v

    @field_validator("age")
    @classmethod
    def age_valid(cls, v: int) -> int:
        if v < 0 or v > 150:
            raise ValueError("Age must be between 0 and 150")
        return v
```

**BAD**
```python
def create_user(data: dict) -> User:
    # No validation, trusts input blindly
    return User(
        username=data["username"],
        email=data["email"],
        age=data["age"],
    )
```
