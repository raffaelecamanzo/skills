# Code Quality Standards

Opinionated defaults for decisions where `gofmt`, `go vet`, and `staticcheck` are silent. **Existing project conventions always take priority** — adopt the codebase style, then apply these where no convention exists.

---

## 1. Project Layout

- Follow the existing project structure. Do not reorganise without explicit approval.
- If starting fresh: `cmd/<binary>/main.go` for entry points, `internal/` for private packages, one primary type per file, tests beside the code they test (`foo_test.go` next to `foo.go`).
- Avoid `pkg/` unless the project already uses it.
- Keep `main.go` thin — parse flags/config, wire dependencies, call `run(ctx)`.

## 2. Naming

- Single-method interfaces use the `-er` suffix: `Reader`, `Closer`, `Validator`.
- Multi-method interfaces use noun names describing the capability: `Store`, `Notifier`, `AuthService`.
- Constructors follow `New[Type]`: `NewServer`, `NewOrderService`.
- Functional options pattern for 3+ optional parameters:
  ```go
  type Option func(*config)
  func WithTimeout(d time.Duration) Option { return func(c *config) { c.timeout = d } }
  ```
- Avoid stuttering: `http.Server` not `http.HTTPServer`; `store.New` not `store.NewStore`.
- Unexported helpers use concise names — the package scope provides context.

## 3. Error Handling Style

- Wrap at every boundary with a verb phrase describing the operation:
  ```go
  return fmt.Errorf("fetching user %d: %w", id, err)
  ```
- Do not prefix with "error" or "failed to" — the caller already knows it is an error.
- Define custom error types when callers need to inspect error data:
  ```go
  type NotFoundError struct{ Resource string; ID string }
  func (e *NotFoundError) Error() string { return e.Resource + " " + e.ID + " not found" }
  ```
- Define sentinel errors for well-known conditions callers check with `errors.Is`:
  ```go
  var ErrNotFound = errors.New("not found")
  ```
- Never use `log.Fatal` or `os.Exit` outside `main` — return errors to the caller.

## 4. Function Signatures

- `ctx context.Context` is always the first parameter.
- Use an options struct instead of boolean parameters:
  ```go
  // Bad:  CreateUser(ctx, name, true, false)
  // Good: CreateUser(ctx, name, CreateUserOpts{Admin: true})
  ```
- Return order: `(result, error)`. Multiple results before error.
- Named return values only when they improve readability (e.g., documenting what two same-typed returns mean). Never use naked returns.

## 5. Testing Style

- Table-driven tests with `t.Run` for named sub-cases:
  ```go
  tests := []struct{ name string; input int; want int }{...}
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) { ... })
  }
  ```
- Naming: `Test[Function]_[scenario]` — e.g., `TestParseConfig_missing_file`.
- Use `testify` only if the project already uses it. Otherwise, plain `if got != want` comparisons.
- Use `t.Parallel()` for independent tests.
- Golden files (`testdata/`) for complex output comparison — update with `-update` flag.
- Test helpers call `t.Helper()` so failures report the caller's line.

## 6. Logging and Observability

- Always use structured logging: `slog`, `zerolog`, or `zap` — match what the project uses.
- Log at the handling site, not at the origination site. The function that decides what to do with an error logs it; functions that propagate errors do not.
- Include trace/request IDs in log context for request-scoped operations.
- Use appropriate log levels: `Error` for failures requiring attention, `Warn` for recoverable issues, `Info` for significant events, `Debug` for development.
- Never log secrets, tokens, or full request/response bodies containing PII.
