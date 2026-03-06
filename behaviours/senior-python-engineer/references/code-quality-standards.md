# Code Quality Standards

Opinionated defaults for decisions where `mypy`, `ruff`, and `pytest` are silent. **Existing project conventions always take priority** — adopt the codebase style, then apply these where no convention exists.

---

## 1. Project Layout

- Follow the existing project structure. Do not reorganise without explicit approval.
- If starting fresh: `src/<package>/` layout with `pyproject.toml`, domain-based package organisation:
  ```
  src/
  └── myproject/
      ├── __init__.py
      ├── __main__.py          # CLI entry point
      ├── domain/
      │   ├── models.py
      │   └── services.py
      ├── infrastructure/
      │   ├── database.py
      │   └── http_client.py
      ├── api/
      │   └── routes.py
      └── config.py
  tests/
  ├── conftest.py
  ├── domain/
  │   └── test_services.py
  └── infrastructure/
      └── test_database.py
  ```
- Tests in `tests/` mirroring `src/` structure. `conftest.py` at appropriate levels for shared fixtures.
- Thin entry points: `__main__.py` or a CLI module parses args, wires dependencies, calls the application.

## 2. Naming

- PEP 8 naming:
  - `snake_case` for functions, variables, methods, and module names
  - `CamelCase` for classes
  - `UPPER_SNAKE_CASE` for module-level constants
  - `_private` prefix for internal functions, methods, and module members
- Avoid abbreviations — `calculate_total_price` over `calc_tot_prc`.
- Descriptive parameter names — the function signature should be readable without the docstring.
- Module names are short, lowercase, no underscores when possible: `config.py`, `models.py`, `routes.py`.
- Boolean variables and functions use `is_`, `has_`, `can_` prefixes: `is_active`, `has_permission`.

## 3. Error Handling Style

- Custom exception hierarchy inheriting from a project base exception:
  ```python
  class AppError(Exception):
      """Base exception for the application."""

  class NotFoundError(AppError):
      def __init__(self, resource: str, identifier: str) -> None:
          super().__init__(f"{resource} {identifier} not found")
          self.resource = resource
          self.identifier = identifier
  ```
- Wrap with context at every boundary using `from`:
  ```python
  raise ServiceError(f"creating order for user {user_id}") from err
  ```
- Do not prefix with "error" or "failed to" — the caller already knows it is an error.
- Never bare `except:` — catch specific exceptions.
- Log-and-raise or log-and-return — never both (avoids duplicate log entries).
- `contextlib.suppress()` only for explicitly expected exceptions with a comment explaining why.

## 4. Function Signatures

- Full type annotations on all public functions:
  ```python
  def get_user(user_id: str, *, include_deleted: bool = False) -> User | None:
  ```
- Default arguments via `None` sentinel pattern — never mutable defaults:
  ```python
  def process(items: list[str] | None = None) -> list[str]:
      items = items if items is not None else []
  ```
- Keyword-only arguments (after `*`) for boolean and optional parameters — prevents positional ambiguity.
- `@dataclass` or Pydantic `BaseModel` for functions with 4+ related parameters.
- Return `T | None` explicitly — never rely on implicit `None` return.
- Use `from __future__ import annotations` for modern annotation syntax.

## 5. Testing Style

- pytest with `@pytest.mark.parametrize` for table-driven tests:
  ```python
  @pytest.mark.parametrize("input_val,expected", [
      ("valid", True),
      ("", False),
      (None, False),
  ])
  def test_validate(input_val: str | None, expected: bool) -> None:
      assert validate(input_val) == expected
  ```
- Fixtures over manual setup. `conftest.py` for shared fixtures.
- `monkeypatch` for environment variables and configuration overrides.
- `pytest-asyncio` for async tests (`@pytest.mark.asyncio`).
- Naming: `test_<function>_<scenario>` — e.g., `test_parse_config_missing_file`.
- Hypothesis for property-based testing on parsing and validation functions.
- Mock at external boundaries only — test internal code with real objects.

## 6. Logging and Observability

- Use structured logging: `structlog`, `logging` with JSON formatter, or match the project's approach.
- Log at the handling site, not at the origination site. The function that decides what to do with an error logs it; functions that propagate errors do not.
- Include request/trace IDs in log context for request-scoped operations.
- Appropriate log levels: `error` for failures requiring attention, `warning` for recoverable issues, `info` for significant events, `debug` for development.
- Never log secrets, tokens, or PII.
- Configure logging at the application entry point — not at the library/module level.
