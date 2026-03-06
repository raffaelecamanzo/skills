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
      ├── llm/
      │   ├── __init__.py
      │   ├── clients.py       # Unified model client abstraction
      │   ├── prompts/         # Versioned prompt templates
      │   │   ├── __init__.py
      │   │   └── v1/
      │   │       ├── __init__.py
      │   │       └── summarise.py
      │   └── output_parsers.py
      ├── rag/
      │   ├── __init__.py
      │   ├── chunking.py      # Document chunking strategies
      │   ├── embeddings.py    # Embedding model client
      │   ├── retrieval.py     # Vector store query + relevance filtering
      │   └── assembly.py      # Context window assembly with token budgeting
      ├── pipelines/
      │   ├── __init__.py
      │   ├── ingestion.py     # Document ingestion pipeline
      │   └── evaluation.py    # Evaluation pipeline runner
      └── config.py
  tests/
  ├── conftest.py
  ├── fixtures/
  │   ├── prompts/             # Test prompt inputs and expected outputs
  │   ├── documents/           # Test documents for RAG pipeline
  │   └── golden/              # Golden datasets for evaluation
  ├── domain/
  │   └── test_services.py
  ├── infrastructure/
  │   └── test_database.py
  ├── llm/
  │   └── test_clients.py
  ├── rag/
  │   └── test_retrieval.py
  └── evaluation/
      └── test_eval_summarise.py
  ```
- Tests in `tests/` mirroring `src/` structure. `conftest.py` at appropriate levels for shared fixtures.
- Thin entry points: `__main__.py` or a CLI module parses args, wires dependencies, calls the application.
- **AI/ML directory conventions:**
  - `llm/prompts/` — versioned prompt templates as Python modules (not loose strings), organised by version (`v1/`, `v2/`)
  - `rag/` — each stage of the RAG pipeline is a separate module with a clear interface
  - `pipelines/` — orchestration-level code that composes `llm/` and `rag/` components
  - `tests/fixtures/` — test data separated by type (prompts, documents, golden datasets)
  - `tests/evaluation/` — evaluation tests that measure model behavior quality, kept separate from unit/integration tests

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
- **AI/ML naming conventions:**
  - Prompt templates: `<action>_<subject>_prompt` — e.g., `summarise_document_prompt`, `classify_intent_prompt`
  - Prompt template classes: `<Action><Subject>Prompt` — e.g., `SummariseDocumentPrompt`
  - Evaluation functions: `eval_<metric>` or `evaluate_<aspect>` — e.g., `eval_faithfulness`, `evaluate_relevance`
  - Model client methods: `generate`, `embed`, `complete` — not `call`, `run`, `invoke` (be specific about the operation)
  - Embedding functions: `embed_<what>` — e.g., `embed_documents`, `embed_query`
  - Retrieval functions: `retrieve_<what>` — e.g., `retrieve_relevant_chunks`, `retrieve_by_metadata`
  - Pipeline stages: `<verb>_stage` or `<verb>_step` — e.g., `chunking_stage`, `embedding_step`

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
- **AI/ML exception hierarchy** — categorise by recoverability:
  ```python
  class AIError(AppError):
      """Base exception for AI/ML operations."""

  # --- Retryable (transient failures) ---
  class ModelProviderError(AIError):
      """Model provider returned a transient error (5xx, timeout)."""

  class RateLimitError(AIError):
      """Rate limit exceeded — retry with backoff."""
      def __init__(self, retry_after: float | None = None) -> None:
          super().__init__("Rate limit exceeded")
          self.retry_after = retry_after

  # --- Terminal (do not retry) ---
  class ContextWindowExceeded(AIError):
      """Input exceeds model's context window — reduce input, do not retry."""

  class ContentFilterError(AIError):
      """Content blocked by safety filter — do not retry with same input."""

  class RetrievalError(AIError):
      """Vector store query failed or returned no results."""

  class EvaluationError(AIError):
      """Evaluation pipeline failure — test infrastructure, not model behavior."""
  ```
  - Retry only `ModelProviderError` and `RateLimitError` — all others are terminal or require input changes.
  - Include `retry_after` on `RateLimitError` when the provider returns it in response headers.

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
- **AI/ML testing conventions:**
  - **`@pytest.mark.evaluation`** — tests that measure model output quality (accuracy, faithfulness, relevance). These are non-deterministic and may be slow/expensive. Run separately from unit tests: `pytest -m evaluation`.
  - **`@pytest.mark.integration`** — tests that call real model providers or vector stores. Require API keys and network. Run separately: `pytest -m integration`.
  - **`@pytest.mark.expensive`** — tests that incur significant API cost. Never run in CI without explicit opt-in. Combine with `integration`: `pytest -m "integration and not expensive"`.
  - **Golden dataset pattern** — store expected inputs and outputs in `tests/fixtures/golden/` as JSON or JSONL files. Evaluation tests load these and compare model outputs against golden answers using appropriate metrics (not exact match).
  - **Mock model clients for unit tests** — create `Protocol`-based model client interfaces and provide deterministic mock implementations for unit tests. Never mock internal logic, only the model provider boundary:
    ```python
    class MockModelClient:
        def __init__(self, responses: dict[str, str]) -> None:
            self._responses = responses

        async def generate(self, prompt: str, **kwargs: Any) -> str:
            return self._responses.get(prompt, "default mock response")
    ```
  - **Prompt regression tests** — test that prompt templates render correctly with known inputs. These are deterministic unit tests, not evaluation tests.

## 6. Logging and Observability

- Use structured logging: `structlog`, `logging` with JSON formatter, or match the project's approach.
- Log at the handling site, not at the origination site. The function that decides what to do with an error logs it; functions that propagate errors do not.
- Include request/trace IDs in log context for request-scoped operations.
- Appropriate log levels: `error` for failures requiring attention, `warning` for recoverable issues, `info` for significant events, `debug` for development.
- Never log secrets, tokens, or PII.
- Configure logging at the application entry point — not at the library/module level.
- **AI/ML observability:**
  - **Token usage logging** — log `prompt_tokens`, `completion_tokens`, `total_tokens` on every model call at `info` level. Include model name and request ID for cost attribution:
    ```python
    logger.info("model_call_complete", model=model_name, prompt_tokens=usage.prompt_tokens,
                completion_tokens=usage.completion_tokens, latency_ms=elapsed_ms, request_id=request_id)
    ```
  - **Retrieval metrics** — log `chunks_retrieved`, `chunks_after_filtering`, `relevance_scores` at `info` level for RAG pipeline observability.
  - **Prompt template version tracking** — include prompt template name and version in log context. This enables tracing regressions to specific prompt changes.
  - **Never log full prompts or completions in production** — they may contain PII, sensitive context, or proprietary data. Log prompt template name, version, and parameter keys only. Full content logging is acceptable in development/debug mode only.

## 7. Prompt Engineering Standards

Prompts are engineering artifacts — versioned, parameterised, tested, and documented. Treat prompt development with the same rigour as API contract design.

- **Prompts as versioned artifacts** — store prompt templates in `llm/prompts/v<N>/` directories. Each version is a Python module exporting a Pydantic model. Never use inline string literals for prompts in business logic:
  ```python
  # llm/prompts/v1/summarise.py
  from pydantic import BaseModel

  class SummarisePrompt(BaseModel):
      system: str = "You are a technical document summariser. Produce concise summaries."
      user_template: str = "Summarise the following document in {max_sentences} sentences:\n\n{document}"

      def render_user(self, document: str, max_sentences: int = 3) -> str:
          return self.user_template.format(document=document, max_sentences=max_sentences)
  ```
- **Template parameterisation via Pydantic** — all variable parts of a prompt are typed fields with validation. This prevents injection via template variables and makes prompt inputs discoverable.
- **System/user/assistant roles explicit** — always use the message role structure (`system`, `user`, `assistant`). System messages set behavior and constraints; user messages provide the task and input; assistant messages provide few-shot examples.
- **Output format specification** — when structured output is needed, specify the format explicitly in the prompt (JSON schema, XML tags, or delimiters). Validate the output against the specification using Pydantic:
  ```python
  class SummaryOutput(BaseModel):
      summary: str
      key_points: list[str]
      confidence: float = Field(ge=0.0, le=1.0)
  ```
- **Prompt testing requirements:**
  - Deterministic tests: prompt templates render correctly with known inputs (unit tests)
  - Regression tests: known input/output pairs produce acceptable results (evaluation tests)
  - Edge case tests: empty input, maximum-length input, special characters, multilingual content

## 8. Model Integration Patterns

- **Unified client abstraction** — define a `Protocol` for model interactions. All model providers implement the same interface. Business logic depends on the Protocol, not on provider SDKs:
  ```python
  class ModelClient(Protocol):
      async def generate(self, messages: list[Message], **kwargs: Any) -> ModelResponse: ...
      async def embed(self, texts: list[str]) -> list[list[float]]: ...
  ```
- **Config-driven model parameters** — model name, temperature, max tokens, top-p, and other parameters live in configuration (Pydantic settings), not in code. This enables model swaps without code changes:
  ```python
  class ModelConfig(BaseSettings):
      model_name: str = "claude-sonnet-4-20250514"
      temperature: float = 0.0
      max_tokens: int = 4096
  ```
- **Token budget management** — calculate token counts before sending requests. Use the model's tokenizer (or a conservative estimate) to verify the prompt fits within the context window. Reserve tokens for the completion:
  ```python
  available = model_config.context_window - model_config.max_tokens - SAFETY_MARGIN
  if prompt_tokens > available:
      raise ContextWindowExceeded(prompt_tokens=prompt_tokens, available=available)
  ```
- **Streaming via async generators** — for long completions, stream responses to reduce time-to-first-token. Expose streaming as `AsyncIterator[str]` or `AsyncIterator[ChunkEvent]`:
  ```python
  async def generate_stream(self, messages: list[Message], **kwargs: Any) -> AsyncIterator[str]:
      async for chunk in self._provider.stream(messages, **kwargs):
          yield chunk.text
  ```
- **Retry policy** — exponential backoff with jitter for rate limits (`RateLimitError`); fail-fast for content filters (`ContentFilterError`) and context window errors (`ContextWindowExceeded`). Never retry terminal errors:
  ```python
  @retry(retry=retry_if_exception_type(RateLimitError),
         wait=wait_exponential(multiplier=1, min=1, max=60) + wait_random(0, 2),
         stop=stop_after_attempt(5))
  async def _call_with_retry(self, messages: list[Message], **kwargs: Any) -> ModelResponse:
      ...
  ```
- **Cost tracking** — log estimated cost per request based on token usage and model pricing. Aggregate by request path, user, or feature for cost attribution. Expose cost metrics for monitoring.
