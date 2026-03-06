# Self-Review Checklist

Walk through every section before delivering code. Sections are ordered by bug severity — concurrency and resource issues crash production; style issues do not.

---

## 1. Async and Concurrency Safety

- [ ] No blocking calls in async event loop (`time.sleep`, synchronous I/O, CPU-bound work without executor)
- [ ] `asyncio.TaskGroup` used for structured concurrency (3.11+) — tasks do not outlive their scope
- [ ] `CancelledError` is handled properly — not silently swallowed, cleanup runs before propagation
- [ ] `loop.run_in_executor` used for CPU-bound work called from async context
- [ ] No shared mutable state across coroutines without locks (`asyncio.Lock`)
- [ ] GIL-aware design choices — multiprocessing for CPU-bound parallelism, not threading

## 2. Resource Management

- [ ] Context managers (`with`) used for all acquirable resources (files, connections, locks, cursors)
- [ ] `async with` used for async resources (aiohttp sessions, async database connections)
- [ ] `atexit` / signal handlers registered for graceful shutdown of long-running services
- [ ] Temporary files cleaned up (use `tempfile.NamedTemporaryFile` with automatic cleanup or explicit `finally`)
- [ ] No leaked connections in loops — connections acquired and released within the loop body, not held across iterations
- [ ] Database connection pools properly configured and closed on shutdown

## 3. Error Handling

- [ ] No bare `except:` or broad `except Exception:` without re-raise
- [ ] `raise ... from err` used for exception chaining at boundaries
- [ ] Custom exceptions defined for domain errors, inheriting from project base exception
- [ ] No silently swallowed exceptions without justification comment
- [ ] `finally` blocks used for critical cleanup that must run regardless of exception
- [ ] Logging before re-raise where appropriate — but not both log-and-raise and log-and-return

## 4. Data Integrity

- [ ] ORM queries use parameterised statements — no f-string or `.format()` SQL
- [ ] Database migrations are versioned and reversible (Alembic, Django migrations)
- [ ] Transaction boundaries are explicit — `with session.begin():` or `@atomic`
- [ ] Cache invalidation is deliberate — stale data paths identified and handled
- [ ] No stale closures over mutable state (especially in callbacks and deferred execution)
- [ ] Race conditions considered in concurrent write paths

## 5. Type Safety

- [ ] All public functions fully annotated with type hints
- [ ] `mypy --strict` (or `pyright`) passes with zero errors
- [ ] No `# type: ignore` without an explanatory comment
- [ ] `Protocol` classes used for structural subtyping at dependency boundaries
- [ ] `TypeGuard` used for type narrowing functions
- [ ] No `Any` without justification — prefer `object` with type guards for unknown data

## 6. Input Validation and Security

- [ ] All external input validated at the boundary (Pydantic, marshmallow, or manual)
- [ ] No dangerous built-in functions called on untrusted data (no dynamic code evaluation on user input)
- [ ] No unsafe deserialization of untrusted data (use safe alternatives for all serialization formats)
- [ ] `yaml.safe_load()` used instead of `yaml.load()`
- [ ] `secrets` module used for tokens and security-sensitive randomness, never `random`
- [ ] File paths from external input sanitised against path traversal
- [ ] No hardcoded secrets, API keys, or credentials in source code

## 7. API and Interface Design

- [ ] Public functions have docstrings explaining purpose, parameters, and return value
- [ ] `Protocol` classes define dependency boundaries — not concrete class inheritance
- [ ] `@dataclass` or Pydantic `BaseModel` used for structured data (not plain dicts)
- [ ] `__slots__` used on high-volume data classes where memory matters
- [ ] `__repr__` and `__eq__` implemented for domain objects
- [ ] Constructor parameters are explicit — no `**kwargs` without documentation

## 8. Testing Completeness

- [ ] All public functions and classes have test coverage
- [ ] Error paths tested explicitly — not just happy path
- [ ] `@pytest.mark.parametrize` used for multiple input/output scenarios
- [ ] Fixtures used for setup and teardown — not manual setup in each test
- [ ] Async tests use `pytest-asyncio` (`@pytest.mark.asyncio`)
- [ ] Property-based tests (Hypothesis) used for parsing and validation functions
- [ ] Mocks isolated to external boundaries — internal code tested with real objects

## 9. Performance Awareness

- [ ] Generators used for large sequences (not materialised lists)
- [ ] `__slots__` used on high-volume objects to reduce memory
- [ ] Lazy imports for heavy modules that are not always needed
- [ ] No N+1 query patterns — use `select_related` / `joinedload` or batch queries
- [ ] Optimisation is profiling-driven (not guessing) — `cProfile`, `line_profiler`, or `py-spy`
- [ ] Appropriate data structures: `set` for membership, `deque` for FIFO, `defaultdict` for grouping

## 10. Code Hygiene

- [ ] No bare `TODO` comments without a tracking reference or explanation
- [ ] No commented-out code
- [ ] No unused imports (enforced by linter, but verify after refactoring)
- [ ] PEP 8 naming: `snake_case` for functions/variables/modules, `CamelCase` for classes, `UPPER_SNAKE_CASE` for constants
- [ ] `__all__` defined for public API modules
- [ ] No `from module import *`
