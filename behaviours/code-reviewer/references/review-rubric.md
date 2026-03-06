# Review Rubric

Evaluation criteria for each of the 5 review agents. Each agent uses its section to systematically evaluate the implementation.

---

## 1. Spec Compliance

Verify that the implementation satisfies the stated requirements completely and correctly.

| Check | What to Look For | Severity |
|-------|-------------------|----------|
| Criterion coverage | Every acceptance criterion from the sprint task has a corresponding implementation | Must-fix |
| Correctness | Implementation behavior matches the requirement intent, not just the letter | Must-fix |
| Scope boundaries | No under-delivery (missing criteria) and no scope creep (unrequested features) | Must-fix / Should-fix |
| Edge cases | Requirements-implied edge cases are handled (empty inputs, boundary values, concurrent access) | Must-fix |
| Input/output contracts | Data formats, response codes, and error messages match spec expectations | Must-fix |

**How to evaluate:**
1. List every acceptance criterion from the sprint document
2. For each criterion, locate the implementing code and verify it satisfies the criterion
3. Check for implicit requirements from the software spec that the sprint task inherits
4. Flag any implemented behavior that has no corresponding requirement (potential scope creep)
5. Trace edge cases mentioned in requirements through to their handling code

---

## 2. Architecture Compliance

Verify that the implementation respects the project's architectural decisions and structure.

| Check | What to Look For | Severity |
|-------|-------------------|----------|
| ADR adherence | Each relevant ADR's decision is followed in the implementation | Must-fix |
| Component placement | Files and packages are in the correct locations per the architecture | Should-fix |
| Communication patterns | Inter-component communication follows defined patterns (API boundaries, event flows) | Must-fix |
| Error strategy | Error handling follows the architecture's prescribed error propagation model | Must-fix |
| Dependency direction | Dependencies flow in the correct direction (no circular imports, no upstream dependencies from lower layers) | Must-fix |
| Interface contracts | Public interfaces match the architecture's defined contracts | Must-fix |

**How to evaluate:**
1. Identify which ADRs are relevant to the implemented components
2. For each ADR, verify the implementation follows the stated decision
3. Check that new files are placed in architecturally correct packages
4. Trace error propagation paths and verify they match the architecture's error strategy
5. Verify dependency directions using import statements

---

## 3. Code Quality

Verify that the code is correct, maintainable, and secure at the implementation level.

| Check | What to Look For | Severity |
|-------|-------------------|----------|
| Logic correctness | Algorithms produce correct results; no off-by-one, nil dereference, or type confusion | Must-fix |
| Resource management | Connections, file handles, goroutines, and channels are properly created, used, and cleaned up | Must-fix |
| Error handling | Errors are checked, wrapped with context, and propagated — no silent discards | Must-fix |
| Security | Input validation at boundaries, no injection vectors, no sensitive data in logs/errors | Must-fix |
| Naming clarity | Names accurately describe purpose; no misleading or ambiguous identifiers | Should-fix |
| Complexity | Functions are focused; no deeply nested logic or excessive cyclomatic complexity | Should-fix |
| Consistency | Style matches existing codebase conventions (formatting, patterns, idioms) | Should-fix |

**How to evaluate:**
1. Read each function and trace its logic path, checking for correctness
2. Identify all resource acquisitions and verify matching cleanup (defer, close, cancel)
3. Check every error return — is it handled, wrapped, or explicitly justified if ignored?
4. Scan for security surface area: user input handling, SQL/command construction, credential management
5. Assess naming and complexity only where it materially impacts readability

---

## 4. Test Coverage

Verify that the test suite adequately validates the implementation.

| Check | What to Look For | Severity |
|-------|-------------------|----------|
| Exported function coverage | Every new exported function/method has at least one test | Must-fix |
| Error path testing | Error conditions are tested, not just happy paths | Must-fix |
| Edge case testing | Boundary values, empty inputs, and concurrent scenarios are tested | Should-fix |
| Assertion quality | Assertions check specific expected values, not just "no error" | Should-fix |
| Test structure | Tests are organized (table-driven where appropriate, named sub-cases) | Should-fix |
| Test isolation | Tests don't depend on external state, ordering, or other tests | Must-fix |

**How to evaluate:**
1. List all new exported functions and verify each has test coverage
2. For each function, check that at least one test exercises an error path
3. Review assertions — do they verify the right thing with specific expected values?
4. Check for test isolation: shared mutable state, file system dependencies, network calls
5. Assess whether table-driven structure would improve clarity (only flag if clearly beneficial)

---

## 5. Simplification

Identify opportunities to reduce complexity without losing correctness or readability.

| Check | What to Look For | Severity |
|-------|-------------------|----------|
| Duplication | Repeated logic blocks that could be consolidated into a shared function | Should-fix |
| Over-engineering | Abstractions, interfaces, or patterns that serve only one use case | Should-fix |
| Dead code | Unreachable code, unused variables, commented-out blocks | Should-fix |
| Unnecessary complexity | Complex solutions where a simpler approach achieves the same result | Should-fix |
| Premature generalization | Configuration, feature flags, or extension points for hypothetical future needs | Should-fix |

**How to evaluate:**
1. Look for code blocks that are structurally similar — could they share a helper?
2. Check each abstraction: is it used by more than one caller? If not, is the indirection justified?
3. Scan for dead code: unused imports, unreachable branches, vestigial functions
4. For each complex pattern, ask: is there a simpler way that is equally correct?
5. Only flag simplifications that are clearly beneficial — three similar lines are better than a premature abstraction
