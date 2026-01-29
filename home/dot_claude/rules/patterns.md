# Architecture Patterns

## API Response Format

Standard structure for REST APIs:

### Success Response
```json
{
  "data": { ... },
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": { "field": "email" }
  }
}
```

## Repository Pattern

Separate data access from business logic:

```python
from typing import Protocol

class UserRepository(Protocol):
    def find_all(self, filters: dict) -> list[User]: ...
    def find_by_id(self, id: str) -> User | None: ...
    def create(self, data: CreateUserDTO) -> User: ...
    def update(self, id: str, data: UpdateUserDTO) -> User: ...
    def delete(self, id: str) -> None: ...
```

## Service Layer Pattern

- Business logic in dedicated service modules
- Dependency injection for testability
- Single responsibility per service

```python
class UserService:
    def __init__(self, repo: UserRepository, email: EmailService) -> None:
        self._repo = repo
        self._email = email

    async def register(self, data: RegisterDTO) -> User:
        user = await self._repo.create(data)
        await self._email.send_welcome(user.email)
        return user
```

## Skeleton Projects Strategy

1. **Search** - Find established skeleton projects for your stack
2. **Evaluate** - Use parallel agents (security, extensibility, relevance)
3. **Start** - Use best match as foundation
4. **Build** - Develop within established framework

## See Also

- `~/.claude/skills/python-pro/references/patterns.md` - Python-specific patterns
- `~/.claude/skills/golang-pro/` - Go-specific patterns
