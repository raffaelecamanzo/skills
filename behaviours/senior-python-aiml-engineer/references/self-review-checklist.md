# Self-Review Checklist

Walk through every section before delivering code. Sections are ordered by bug severity — AI safety and model integration issues first, then concurrency and resource issues, then style.

---

## 1. Model Integration Safety

- [ ] Unified model client abstraction (`Protocol`) used — business logic does not depend on provider SDKs directly
- [ ] All model responses validated via Pydantic before downstream use — no raw string consumption
- [ ] Token count checked against context window budget before sending requests
- [ ] Retryable errors (`RateLimitError`, `ModelProviderError`) distinguished from terminal errors (`ContentFilterError`, `ContextWindowExceeded`)
- [ ] Retry policy uses exponential backoff with jitter — no fixed-delay retry loops
- [ ] Fallback behavior defined for model unavailability (graceful degradation, not silent failure)
- [ ] Cost tracking logged per request (model name, token counts, estimated cost)

## 2. Prompt Security

- [ ] User input sanitised before inclusion in prompts — length limits, control sequence removal
- [ ] System and user messages structurally separated via role-based API — no user input concatenated into system messages
- [ ] No secrets, API keys, or infrastructure details in prompt context (system or user messages)
- [ ] PII handling documented — redacted before context assembly, or justified if intentionally included
- [ ] Model output validated before downstream use (SQL, file paths, API calls, code execution, display)
- [ ] Content safety filters applied to both input and output where required

## 3. RAG Pipeline Correctness

- [ ] Chunking strategy uses semantic boundaries (paragraphs, sections) with configurable overlap — not arbitrary character splits
- [ ] Embedding model and distance metric consistent between indexing and query time
- [ ] Relevance threshold applied to filter low-quality chunks before context assembly
- [ ] Token budget enforced in context assembly — retrieved chunks fit within available context window
- [ ] Document-level access control enforced in vector store queries — users only see authorised content
- [ ] Chunk metadata preserved through the pipeline (source document, page, section, access groups)

## 4. Async and Concurrency Safety

- [ ] No blocking calls in async event loop (`time.sleep`, synchronous I/O, CPU-bound work without executor)
- [ ] `asyncio.TaskGroup` used for structured concurrency (3.11+) — tasks do not outlive their scope
- [ ] `CancelledError` is handled properly — not silently swallowed, cleanup runs before propagation
- [ ] `loop.run_in_executor` used for CPU-bound work called from async context
- [ ] No shared mutable state across coroutines without locks (`asyncio.Lock`)
- [ ] GIL-aware design choices — multiprocessing for CPU-bound parallelism, not threading

## 5. Resource Management

- [ ] Context managers (`with`) used for all acquirable resources (files, connections, locks, cursors)
- [ ] `async with` used for async resources (aiohttp sessions, async database connections)
- [ ] Model client connections properly initialised and closed (lifecycle managed via context manager or shutdown hook)
- [ ] Vector store connections properly initialised and closed
- [ ] `atexit` / signal handlers registered for graceful shutdown of long-running services
- [ ] Temporary files cleaned up (use `tempfile.NamedTemporaryFile` with automatic cleanup or explicit `finally`)
- [ ] No leaked connections in loops — connections acquired and released within the loop body, not held across iterations
- [ ] Database connection pools properly configured and closed on shutdown

## 6. Error Handling

- [ ] No bare `except:` or broad `except Exception:` without re-raise
- [ ] `raise ... from err` used for exception chaining at boundaries
- [ ] Custom exceptions defined for domain errors, inheriting from project base exception
- [ ] AI/ML exception hierarchy follows retryable vs terminal classification
- [ ] No silently swallowed exceptions without justification comment
- [ ] `finally` blocks used for critical cleanup that must run regardless of exception
- [ ] Logging before re-raise where appropriate — but not both log-and-raise and log-and-return

## 7. Data Pipeline Integrity

- [ ] Schema validation applied at pipeline stage boundaries (Pydantic models for stage inputs/outputs)
- [ ] Pipeline stages are idempotent — re-running a stage with the same input produces the same output
- [ ] Data lineage tracked — each output artifact records its source inputs and transformation version
- [ ] Streaming used for large datasets (generators, async iterators) — not full materialisation in memory
- [ ] Temporary artifacts (intermediate files, cached embeddings) cleaned up after pipeline completion
- [ ] Pipeline failures produce clear error messages identifying the failing stage and input

## 8. Type Safety

- [ ] All public functions fully annotated with type hints
- [ ] `mypy --strict` (or `pyright`) passes with zero errors
- [ ] No `# type: ignore` without an explanatory comment
- [ ] `Protocol` classes used for structural subtyping at dependency boundaries (model clients, vector stores, evaluators)
- [ ] `TypeGuard` used for type narrowing functions
- [ ] No `Any` without justification — prefer `object` with type guards for unknown data

## 9. Testing Completeness

- [ ] All public functions and classes have test coverage
- [ ] Error paths tested explicitly — not just happy path
- [ ] `@pytest.mark.parametrize` used for multiple input/output scenarios
- [ ] Fixtures used for setup and teardown — not manual setup in each test
- [ ] Async tests use `pytest-asyncio` (`@pytest.mark.asyncio`)
- [ ] Property-based tests (Hypothesis) used for parsing, validation, and data transformation functions
- [ ] Mocks isolated to external boundaries — internal code tested with real objects
- [ ] Mock model clients used for unit tests — deterministic responses via `Protocol`-based test doubles
- [ ] Evaluation tests use `@pytest.mark.evaluation` marker and load golden datasets from fixtures
- [ ] Expensive tests (real API calls) marked with `@pytest.mark.expensive` — never run in CI without opt-in
- [ ] Prompt regression tests verify template rendering with known inputs (deterministic, not evaluation)

## 10. Code Hygiene

- [ ] No bare `TODO` comments without a tracking reference or explanation
- [ ] No commented-out code
- [ ] No unused imports (enforced by linter, but verify after refactoring)
- [ ] PEP 8 naming: `snake_case` for functions/variables/modules, `CamelCase` for classes, `UPPER_SNAKE_CASE` for constants
- [ ] `__all__` defined for public API modules
- [ ] No `from module import *`
