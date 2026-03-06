# Security Patterns

Python-specific secure coding patterns. These are not generic OWASP guidelines — they address the concrete APIs and idioms where Python code becomes vulnerable.

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
