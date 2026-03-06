# Security Patterns

Python-specific secure coding patterns for AI/ML and GenAI systems. These are not generic OWASP guidelines — they address the concrete APIs and idioms where Python code becomes vulnerable, with additional sections for the unique attack surface of LLM-integrated applications.

---

## 1. Input Handling

- Validate at the system boundary — before the value enters business logic.
- Use `int()` / `float()` for numeric conversion — never dynamic code evaluation for type coercion.
- Bound string lengths before processing: reject or truncate at the handler layer.
- For JSON request bodies: use Pydantic models or `marshmallow` schemas to validate structure and types at ingestion.
- Use framework request size limits (FastAPI's `UploadFile` with size checks, Django's `DATA_UPLOAD_MAX_MEMORY_SIZE`).
- Reject unexpected `Content-Type` headers early in middleware.

## 2. SQL and Data Access

- Always use parameterised queries:
  - SQLAlchemy: `text("SELECT ... WHERE id = :id")` with `.params(id=value)`, or ORM `.filter()` methods
  - Django ORM: `.filter()`, `.exclude()`, `.get()` — never raw SQL with string formatting
  - Raw DB-API: `cursor.execute("SELECT ... WHERE id = ?", (value,))`
- Never build SQL with f-strings, `.format()`, or `%` string interpolation.
- Django's `extra()`, `raw()`, and `RawSQL` are injection vectors — avoid, or parameterise meticulously.
- Transaction pattern:
  ```python
  with session.begin():
      # operations — commit on exit, rollback on exception
  ```
- Connection pool management: configure pool size, overflow, and recycle in SQLAlchemy; use Django's `CONN_MAX_AGE`.

## 3. Dangerous Built-ins and Deserialization

- **Never** use dynamic code evaluation functions (`eval()`, `exec()`, `compile()`) on external input — these execute arbitrary Python code.
- **Never** deserialize untrusted data with `pickle` — pickle deserialization can execute arbitrary code (RCE vector). Use JSON, MessagePack, or Protocol Buffers for data interchange.
- **Always** `yaml.safe_load()` — never `yaml.load()` (which can instantiate arbitrary Python objects).
- `json.loads()` is safe for parsing, but always validate the resulting structure with Pydantic or equivalent.
- `subprocess`: always use list arguments, never `shell=True` with user input:
  ```python
  subprocess.run(["git", "log", "--oneline"], check=True)  # safe
  # Never: subprocess.run(f"git log {user_input}", shell=True)
  ```
- `importlib` dynamic imports: only from an explicit allowlist, never from user-controlled strings.
- `__import__` and `getattr` on user input are equivalent to arbitrary code execution.

## 4. Cryptography

- `secrets.token_urlsafe()` / `secrets.token_hex()` for tokens and session IDs — never `random`.
- Password hashing: `bcrypt` (via `bcrypt` or `passlib`) or `argon2-cffi`. Never SHA/MD5 for passwords.
- Timing-safe comparison: `hmac.compare_digest()` — never `==` for secret comparison.
- TLS certificate verification: never `verify=False` in production `requests` / `httpx` calls.
- Use `cryptography` library for symmetric/asymmetric encryption — never hand-roll crypto.

## 5. HTTP Server Hardening

- **FastAPI:** Use `Depends()` for authentication/authorisation, configure `CORSMiddleware` with explicit origins (never `allow_origins=["*"]` in production), set request body size limits via ASGI server config.
- **Django:** Enable `SECURE_SSL_REDIRECT`, `SECURE_HSTS_SECONDS`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`, `X_FRAME_OPTIONS = "DENY"`, `SECURE_CONTENT_TYPE_NOSNIFF = True`. Keep `CSRF_COOKIE_HTTPONLY` and CSRF middleware active.
- **Flask:** Configure `SESSION_COOKIE_SECURE`, `SESSION_COOKIE_HTTPONLY`, `SESSION_COOKIE_SAMESITE`. Add CSP headers via `flask-talisman` or middleware.
- Set timeouts on ASGI/WSGI servers: `uvicorn --timeout-keep-alive`, `gunicorn --timeout`, `gunicorn --graceful-timeout`.

## 6. HTTP Client Hardening

- Always set explicit `timeout=` on `httpx` / `requests` calls — the defaults may be infinite:
  ```python
  response = httpx.get(url, timeout=30.0)
  ```
- Validate redirect targets to prevent SSRF — use `httpx` with `follow_redirects=False` and inspect `Location` header, or allowlist target hosts.
- Verify TLS certificates — never `verify=False` in production.
- Validate response `Content-Type` before parsing.
- No user-controlled URLs without allowlist validation — SSRF is a common Python backend vulnerability.

## 7. Secrets and Configuration

- No hardcoded secrets in source code — load from environment variables or a secret manager.
- `.env` files must be in `.gitignore` — never committed to version control.
- Use `pydantic-settings` or `python-decouple` for typed configuration loading with validation.
- Never log secrets or include them in error messages.
- Redact sensitive fields in `__repr__`:
  ```python
  @dataclass
  class DatabaseConfig:
      host: str
      password: str
      def __repr__(self) -> str:
          return f"DatabaseConfig(host={self.host!r}, password='[REDACTED]')"
  ```
- Prefer config objects over scattered `os.environ.get()` calls — centralise and validate at startup.

## 8. Dependency Supply Chain

- Run `pip-audit` and/or `safety check` before delivery to check for known vulnerabilities.
- Run `bandit` for static application security testing (SAST) on the codebase.
- Prefer stdlib and well-maintained packages for common operations.
- Pin versions in lock file: `poetry.lock`, `requirements.txt` with hashes (`pip-compile --generate-hashes`), or `uv.lock`.
- When evaluating a dependency: check maintenance activity, open CVEs, license compatibility, transitive dependency count.
- Audit `setup.py` / `pyproject.toml` build scripts in new dependencies for post-install code execution.

## 9. Prompt Injection Defense

Prompt injection is to LLM applications what SQL injection is to databases — untrusted input that manipulates the instruction layer. Defense is layered; no single technique is sufficient.

- **Structural separation of system and user messages** — always use the model API's role-based message structure. System instructions go in the `system` role; user input goes in the `user` role. Never concatenate user input into system messages:
  ```python
  # SAFE: structural separation
  messages = [
      {"role": "system", "content": system_prompt},
      {"role": "user", "content": user_input},
  ]

  # DANGEROUS: user input in system message
  messages = [
      {"role": "system", "content": f"{system_prompt}\n\nUser said: {user_input}"},
  ]
  ```
- **Input sanitization** — strip or escape control sequences, markdown injection vectors, and role-switching patterns before inserting user input into prompts. Apply length limits to prevent context flooding:
  ```python
  def sanitise_user_input(text: str, *, max_length: int = 10_000) -> str:
      text = text[:max_length]
      for role in ("system:", "assistant:", "user:"):
          text = text.replace(role, "")
      return text.strip()
  ```
- **Delimiter-based input boundaries** — wrap user-provided content in clear delimiters that the model can distinguish from instructions:
  ```python
  user_message = (
      "Analyse the following document. The document is enclosed in <document> tags.\n\n"
      f"<document>\n{sanitised_input}\n</document>\n\n"
      "Provide your analysis based only on the document content above."
  )
  ```
- **Output-side validation** — validate model outputs before using them in downstream operations. Model outputs are untrusted data (see section 11). A successful prompt injection can make the model produce malicious output even if the input looked clean.
- **Instruction hierarchy** — place critical constraints in the system message where they are hardest to override. Repeat critical constraints at the end of the system message (recency bias). Use explicit refusal instructions for out-of-scope requests.
- **Reference:** OWASP LLM Top 10 — LLM01: Prompt Injection.

## 10. Data Leakage Prevention

Prevent sensitive data from leaking through prompts, model responses, logs, or vector store queries.

- **PII filtering before context assembly** — scan and redact PII (emails, phone numbers, SSNs, names) from retrieved documents before including them in prompts. Use pattern-based detection (regex) for structured PII and consider NER models for unstructured PII:
  ```python
  import re

  PII_PATTERNS: dict[str, re.Pattern[str]] = {
      "email": re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"),
      "phone": re.compile(r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"),
      "ssn": re.compile(r"\b\d{3}-\d{2}-\d{4}\b"),
  }

  def redact_pii(text: str) -> str:
      for pii_type, pattern in PII_PATTERNS.items():
          text = pattern.sub(f"[REDACTED_{pii_type.upper()}]", text)
      return text
  ```
- **No secrets in prompt context** — never include API keys, database credentials, internal URLs, or infrastructure details in system prompts or retrieved context. Audit system prompts for accidental secret inclusion.
- **Output sanitization for PII** — scan model responses for PII before returning them to users. The model may reproduce PII from its training data or from context that was not properly redacted.
- **Document-level access control in vector store queries** — filter vector store results by the requesting user's permissions. Never return chunks from documents the user is not authorised to access:
  ```python
  results = vector_store.query(
      query_embedding=query_embedding,
      filter={"access_groups": {"$in": user.access_groups}},
      top_k=10,
  )
  ```
- **Never log full prompts or responses containing PII** — log prompt template name, version, and parameter keys only. Full content logging is acceptable only in development mode with explicit opt-in.

## 11. Model Output Validation

Treat all model outputs as untrusted user input. The model can hallucinate, be manipulated via prompt injection, or produce malformed output.

- **Pydantic validation for structured responses** — when the model returns JSON or structured data, parse and validate with Pydantic before using the output. Reject responses that do not conform:
  ```python
  from pydantic import BaseModel, Field, ValidationError

  class ExtractedEntity(BaseModel):
      name: str
      entity_type: str
      confidence: float = Field(ge=0.0, le=1.0)

  try:
      entity = ExtractedEntity.model_validate_json(model_output)
  except ValidationError as err:
      raise OutputValidationError("Model output does not match expected schema") from err
  ```
- **Sanitize model output used in downstream operations** — if model output is used in SQL queries, file paths, API calls, shell commands, or code execution, sanitise it with the same rigour as user input:
  - SQL: parameterised queries only, never interpolate model output into SQL
  - File paths: validate against allowlist, reject path traversal (`..`)
  - URLs: validate scheme (`https://` only), domain allowlist
  - Code execution: never `eval()` or `exec()` on model output
- **Content safety filtering** — apply content safety checks to model output before displaying to users. This catches cases where the model produces inappropriate content despite system prompt constraints.
- **URL and link validation** — if the model generates URLs or references, validate that they point to legitimate domains. Model-generated URLs can be phishing vectors.
- **Confidence indicators for factual claims** — when the model makes factual assertions, surface confidence indicators or source citations. Do not present model output as authoritative without attribution.

## 12. Responsible AI and Safety

Engineering constraints for safe, accountable AI system deployment.

- **Content safety filters on input and output** — apply safety classifiers or keyword filters to both user input and model output. Block or flag content that violates usage policies. Log blocked content for review (without PII).
- **Rate limiting on GenAI endpoints** — LLM calls are expensive; an attacker can cause significant financial damage through cost-based denial of service. Apply per-user, per-IP, and per-endpoint rate limits. Set budget alerts and hard spending caps:
  ```python
  @rate_limit(max_requests=100, window_seconds=3600)
  async def generate_summary(request: SummaryRequest, user: User) -> SummaryResponse:
      ...
  ```
- **Usage tracking and cost attribution** — log every model call with user ID, feature name, token counts, and estimated cost. This enables cost monitoring, abuse detection, and per-feature ROI analysis.
- **Evaluation for bias** — include bias evaluation in the evaluation test suite. Test model outputs across demographic groups, languages, and edge cases. Document known biases and mitigation strategies.
- **Human-in-the-loop patterns** — for high-stakes decisions (medical, legal, financial), require human review before acting on model output. Design the system so model output is a recommendation, not an action:
  ```python
  class ModelRecommendation(BaseModel):
      action: str
      confidence: float
      reasoning: str
      requires_human_review: bool = True  # Default to requiring review
  ```
- **Model limitation documentation** — document what the model can and cannot do. Include known failure modes, edge cases where accuracy degrades, and scenarios where human judgment is required. This documentation is a deliverable, not an afterthought.
