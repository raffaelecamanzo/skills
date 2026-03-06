# Self-Review Checklist

Walk through every section before delivering code. Sections are ordered by bug severity — concurrency and resource issues crash production; style issues do not.

---

## 1. Goroutine Lifecycle

- [ ] Every goroutine has a clear termination condition
- [ ] Context cancellation propagates to all child goroutines
- [ ] WaitGroups are used when the caller must wait for goroutine completion
- [ ] `defer` is used for cleanup in goroutines that own resources
- [ ] No fire-and-forget goroutines without shutdown signalling
- [ ] Goroutines spawned in loops capture loop variables correctly

## 2. Channel Safety

- [ ] No orphaned channels (every channel has a reader and writer that will complete)
- [ ] Bounded (buffered) channels are preferred where unbounded growth is a risk
- [ ] `select` includes `ctx.Done()` or timeout to prevent indefinite blocking
- [ ] Only the sender closes a channel; receiver never closes
- [ ] Nil channels are used intentionally (to disable select cases), never by accident

## 3. Error Handling

- [ ] No silently discarded errors (`_ = fn()` without justification comment)
- [ ] Errors are wrapped with context at each boundary (`fmt.Errorf("doing X: %w", err)`)
- [ ] Sentinel errors are defined for conditions callers need to inspect (`errors.Is`)
- [ ] Custom error types are used when callers need structured error data (`errors.As`)
- [ ] No sensitive data (passwords, tokens, PII) appears in error messages
- [ ] Errors from deferred `Close()` calls are handled (logged or returned via named return)

## 4. Resource Management

- [ ] `defer Close()` appears immediately after successful open/acquire
- [ ] HTTP response bodies are closed even on non-2xx status codes
- [ ] Database connections/rows/statements are closed after use
- [ ] Temporary files are cleaned up (defer os.Remove or equivalent)
- [ ] File descriptors are not leaked in loops (close inside loop body, not deferred)

## 5. Context Discipline

- [ ] `ctx context.Context` is the first parameter in functions that accept it
- [ ] Context is never stored in a struct field
- [ ] `context.Background()` is used only at program entry points (main, init, top-level handler)
- [ ] No `context.TODO()` in delivered code — resolve to a real context
- [ ] Long-running operations check `ctx.Err()` periodically

## 6. Concurrency Correctness

- [ ] Maps accessed from multiple goroutines are protected (`sync.Mutex`, `sync.Map`, or channel serialisation)
- [ ] `go test -race` passes with zero data race warnings
- [ ] Mutex unlock is deferred immediately after lock
- [ ] No nested lock acquisitions that could deadlock (or lock ordering is documented)
- [ ] Shared mutable state is minimised — prefer message passing or immutable data

## 7. Input Validation and Security

- [ ] All external input (HTTP params, file content, env vars) is validated before use
- [ ] SQL queries use parameterised statements — no string interpolation
- [ ] File paths from external input are sanitised against path traversal
- [ ] `crypto/rand` is used for security-sensitive randomness, never `math/rand`
- [ ] No hardcoded secrets, API keys, or credentials in source code

## 8. API and Interface Design

- [ ] Exported functions and types have doc comments
- [ ] Interfaces are defined where they are used (consumer side), not at the implementation
- [ ] Interfaces are small — prefer single-method interfaces composed as needed
- [ ] Accept interfaces, return concrete structs
- [ ] Zero values are useful (or documented when they are not)

## 9. Testing Completeness

- [ ] All exported functions have test coverage
- [ ] Table-driven tests are used for functions with multiple input/output combinations
- [ ] Error paths are tested explicitly (not just happy path)
- [ ] Edge cases are covered (empty input, nil, zero values, boundary values)
- [ ] `t.Parallel()` is used where tests are independent
- [ ] Test helpers use `t.Helper()` for accurate failure line reporting

## 10. Code Hygiene

- [ ] No bare `TODO` comments without a tracking reference or explanation
- [ ] No commented-out code
- [ ] No unused imports (enforced by compiler, but verify after refactoring)
- [ ] Package names are lowercase, single-word, and descriptive
- [ ] File names use snake_case
