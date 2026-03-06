# Security Patterns

Go-specific secure coding patterns. These are not generic OWASP guidelines — they address the concrete APIs and idioms where Go code becomes vulnerable.

---

## 1. Input Handling

- Validate at the system boundary — before the value enters business logic.
- Use `strconv.Atoi` / `strconv.ParseInt` over `fmt.Sscanf` for numeric conversion (Sscanf silently ignores trailing garbage).
- Bound string lengths before processing: reject or truncate at the handler layer.
- For JSON request bodies:
  ```go
  dec := json.NewDecoder(io.LimitReader(r.Body, maxBytes))
  dec.DisallowUnknownFields()
  ```
- Use `io.LimitReader` for file uploads and streaming input to prevent memory exhaustion.
- Reject unexpected Content-Types early in middleware.

## 2. SQL and Data Access

- Always use parameterised queries (`db.QueryContext(ctx, "SELECT ... WHERE id = $1", id)`).
- Never build SQL with `fmt.Sprintf` or string concatenation.
- Use `sqlc` or similar code generation where the project supports it.
- Always `defer rows.Close()` after `db.Query` — even if you plan to read all rows.
- Transaction pattern:
  ```go
  tx, err := db.BeginTx(ctx, nil)
  if err != nil { return err }
  defer tx.Rollback() // no-op after commit
  // ... operations ...
  return tx.Commit()
  ```

## 3. Cryptography

- Use `crypto/rand.Read` for all security-sensitive random values. Never `math/rand`.
- Password hashing: `bcrypt` (golang.org/x/crypto/bcrypt) or `argon2` (golang.org/x/crypto/argon2). Never SHA/MD5 for passwords.
- Token comparison: `subtle.ConstantTimeCompare` to prevent timing attacks.
- TLS minimum version 1.2:
  ```go
  tlsConfig := &tls.Config{MinVersion: tls.VersionTLS12}
  ```
- Never set `InsecureSkipVerify: true` in production code.

## 4. HTTP Server Hardening

- Set all four timeouts to prevent slowloris and resource exhaustion:
  ```go
  srv := &http.Server{
      ReadTimeout:       5 * time.Second,
      ReadHeaderTimeout: 2 * time.Second,
      WriteTimeout:      10 * time.Second,
      IdleTimeout:       120 * time.Second,
  }
  ```
- Use `http.MaxBytesReader` on request bodies to enforce size limits at the handler level.
- Set security headers in middleware: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Strict-Transport-Security`.
- Use `http.Error` for error responses — never write raw strings to `w` for errors.

## 5. HTTP Client Hardening

- Always set a `Timeout` on `http.Client` — the default client has no timeout:
  ```go
  client := &http.Client{Timeout: 30 * time.Second}
  ```
- Set `CheckRedirect` to limit or prevent open redirect following.
- Always close `response.Body` even on error status codes:
  ```go
  defer resp.Body.Close()
  ```
- Validate TLS certificates — do not use custom transports that skip verification.

## 6. Secrets and Configuration

- No hardcoded secrets in source code — load from environment, secret manager, or config files excluded from VCS.
- Redact secrets from logs by implementing `fmt.Stringer` that masks the value:
  ```go
  type Secret string
  func (s Secret) String() string { return "[REDACTED]" }
  ```
- Never include secrets in error messages or structured log fields.
- Prefer config structs over scattered `os.Getenv` calls — centralise and validate at startup.

## 7. Dependency Supply Chain

- Run `govulncheck ./...` before delivery to check for known vulnerabilities.
- Prefer stdlib over third-party packages for common operations (HTTP, JSON, crypto, testing).
- When evaluating a dependency: check maintenance activity, open CVEs, license compatibility, and transitive dependency count.
- `go.sum` pins exact versions — do not delete or regenerate without review.
- If the project vendors dependencies, maintain `vendor/` with `go mod vendor`.

## 8. Concurrency Security

- `time.After` leaks in loops — use `time.NewTimer` with explicit `Stop()` and drain:
  ```go
  timer := time.NewTimer(duration)
  defer timer.Stop()
  ```
- Bounded concurrency with semaphore pattern:
  ```go
  sem := make(chan struct{}, maxConcurrent)
  sem <- struct{}{}       // acquire
  defer func() { <-sem }() // release
  ```
- Implement rate limiting for external-facing endpoints (token bucket or sliding window).
- Protect against goroutine bombs: limit goroutine creation from untrusted input with a worker pool or semaphore.
