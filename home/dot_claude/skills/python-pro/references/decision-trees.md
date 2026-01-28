# Decision Trees Reference

Decision guidance for common Python development scenarios.

## Table of Contents

- [Concurrency Selection](#concurrency-selection)
- [Data Structure Selection](#data-structure-selection)
- [Framework Selection](#framework-selection)
- [Testing Strategy](#testing-strategy)
- [Error Handling Strategy](#error-handling-strategy)

---

## Concurrency Selection

### When to Use Async

```
Is the operation I/O-bound (network, file, database)?
├── Yes → Is the codebase already async?
│   ├── Yes → Use async/await
│   └── No → Is this a new service or major refactor?
│       ├── Yes → Consider adopting async throughout
│       └── No → Use threading or concurrent.futures
└── No (CPU-bound) → Do you need shared memory?
    ├── Yes → Use threading with proper locks
    └── No → Use multiprocessing or ProcessPoolExecutor
```

### Async vs Threading vs Multiprocessing

| Scenario | Solution | Rationale |
|----------|----------|-----------|
| HTTP requests | `asyncio` + `httpx`/`aiohttp` | Non-blocking I/O, high concurrency |
| Database queries | `asyncio` + async driver | Connection pooling, efficient waiting |
| File I/O | `asyncio.to_thread` or `concurrent.futures` | OS-level blocking, wrap in executor |
| CPU-intensive | `multiprocessing` or `ProcessPoolExecutor` | Bypass GIL, true parallelism |
| Mixed I/O + CPU | `asyncio` + `run_in_executor` | Async for I/O, executor for CPU |

---

## Data Structure Selection

### Dataclass vs Pydantic vs attrs

```
Do you need runtime validation?
├── Yes → Is it for API input/output?
│   ├── Yes → Use Pydantic BaseModel
│   └── No → Is complex validation needed?
│       ├── Yes → Use Pydantic or attrs with validators
│       └── No → Use dataclass with __post_init__
└── No → Do you need immutability?
    ├── Yes → Use dataclass(frozen=True) or NamedTuple
    └── No → Do you need slots for memory efficiency?
        ├── Yes → Use dataclass(slots=True) or attrs
        └── No → Use standard dataclass
```

### Selection Matrix

| Feature | dataclass | Pydantic | attrs | NamedTuple | TypedDict |
|---------|-----------|----------|-------|------------|-----------|
| Type hints | Yes | Yes | Yes | Yes | Yes |
| Runtime validation | Manual | Built-in | Plugin | No | No |
| Immutability | `frozen=True` | `frozen=True` | `frozen=True` | Always | N/A |
| Slots | `slots=True` | v2 only | `slots=True` | Yes | N/A |
| Serialization | Manual | Built-in | Plugin | Manual | Dict native |
| Default factory | `field(default_factory=)` | Built-in | Built-in | No | No |
| Inheritance | Yes | Yes | Yes | Limited | Yes |
| Performance | Fast | Medium | Fast | Fastest | Native dict |

### When to Use Each

| Use Case | Recommended |
|----------|-------------|
| API request/response models | Pydantic BaseModel |
| Internal data containers | dataclass |
| High-performance structures | dataclass(slots=True) or attrs |
| Immutable value objects | dataclass(frozen=True) or NamedTuple |
| Dict with structure hints | TypedDict |
| ORM-like models | Pydantic or SQLAlchemy |

---

## Framework Selection

### FastAPI vs Django vs Flask

```
What type of application?
├── REST API / Microservice
│   ├── Need async support → FastAPI
│   ├── Simple endpoints, minimal dependencies → Flask
│   └── Part of larger Django project → Django REST Framework
├── Full-stack web application
│   ├── Need admin interface → Django
│   ├── Need ORM with migrations → Django
│   └── Minimal, custom approach → Flask + extensions
├── GraphQL API
│   ├── Async required → Strawberry + FastAPI
│   └── Django ecosystem → Graphene + Django
└── Background jobs / Workers
    ├── With web framework → Celery
    ├── Standalone → Dramatiq or RQ
    └── Async-native → arq
```

### Framework Comparison

| Aspect | FastAPI | Django | Flask |
|--------|---------|--------|-------|
| Async | Native | Limited (4.1+) | Via extensions |
| Validation | Pydantic | Forms/Serializers | Manual/WTForms |
| ORM | Any (SQLAlchemy) | Built-in | SQLAlchemy |
| Admin | Custom | Built-in | Flask-Admin |
| OpenAPI | Auto-generated | Via DRF | Via extensions |
| Learning curve | Low | Medium | Low |
| Best for | APIs, microservices | Full-stack, CMS | Simple apps, prototypes |

---

## Testing Strategy

### Test Type Selection

```
What are you testing?
├── Single function/class
│   └── Unit test with mocks
├── Multiple components together
│   ├── Database involved → Integration test with test DB
│   └── External API → Integration test with mocks
├── Full request/response cycle
│   ├── API endpoint → TestClient (FastAPI) or Django TestCase
│   └── Web page → Playwright or Selenium
└── Performance characteristics
    └── Benchmark with pytest-benchmark
```

### Mock vs Real Dependencies

```
Is the dependency...
├── External service (API, third-party)
│   └── Always mock in unit tests
├── Database
│   ├── Unit tests → Mock repository/ORM
│   └── Integration tests → Use test database
├── File system
│   ├── Reading config → Mock or use tmp_path fixture
│   └── Writing output → Use tmp_path fixture
├── Time/Date
│   └── Use freezegun or time-machine
└── Random/UUID
    └── Seed random or mock uuid4
```

### Coverage Guidelines

| Test Type | Target Coverage | Focus |
|-----------|-----------------|-------|
| Unit tests | 80%+ line coverage | Business logic, edge cases |
| Integration tests | Critical paths | API contracts, DB operations |
| E2E tests | Happy paths | User workflows |

---

## Error Handling Strategy

### Exception Selection

```
What kind of error occurred?
├── Invalid input from user
│   └── Raise ValidationError with field details
├── Resource not found
│   └── Raise NotFoundError with resource type and ID
├── Permission denied
│   └── Raise PermissionError or custom AuthorizationError
├── External service failure
│   ├── Transient (timeout, rate limit)
│   │   └── Retry with exponential backoff, then raise
│   └── Permanent (invalid response)
│       └── Wrap and raise ServiceError
├── Programming error (bug)
│   └── Let exception propagate or raise AssertionError
└── Configuration error
    └── Raise ConfigurationError at startup
```

### Error Recovery Strategy

```
Can the operation be retried?
├── Yes → Is it safe to retry (idempotent)?
│   ├── Yes → Retry with backoff (max 3 attempts)
│   └── No → Return error, let caller decide
└── No → Is there a fallback?
    ├── Yes → Log warning, use fallback
    └── No → Propagate error with context
```

### Exception Handling Patterns

| Scenario | Pattern |
|----------|---------|
| External API call | Retry with backoff, wrap in service-specific exception |
| Database operation | Transaction rollback, preserve original exception |
| User input validation | Collect all errors, return structured response |
| Background job | Log error, optionally retry, send to dead letter queue |
| Startup initialization | Fail fast with clear error message |
