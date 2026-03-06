# Self-Review Checklist

Walk through every section before delivering code. Sections are ordered by bug severity — concurrency and transaction issues crash production; style issues do not.

---

## 1. Thread Safety and Concurrency

- [ ] Shared mutable state is protected (`synchronized`, `ReentrantLock`, `ConcurrentHashMap`, or immutable types)
- [ ] `ExecutorService` instances are shut down gracefully (shutdown + awaitTermination + shutdownNow)
- [ ] `CompletableFuture` chains have `exceptionally` or `handle` — no silently swallowed failures
- [ ] `volatile` is used correctly — only for visibility of single variables, not compound actions
- [ ] No fire-and-forget threads without lifecycle management
- [ ] Thread-safe collections are used where concurrent access occurs (`ConcurrentHashMap`, `CopyOnWriteArrayList`)

## 2. Resource Management

- [ ] All `Closeable`/`AutoCloseable` resources use try-with-resources
- [ ] Connection pool settings are configured explicitly (max size, timeout, idle eviction)
- [ ] `Stream` instances from I/O sources are closed (try-with-resources or explicit close)
- [ ] `EntityManager` lifecycle follows the unit-of-work pattern — no long-lived instances
- [ ] Temporary files are cleaned up (`Files.delete` in finally or try-with-resources)
- [ ] HTTP client connections are released after use (response body consumed or closed)

## 3. Exception Handling

- [ ] No empty catch blocks without a justification comment
- [ ] No broad `catch (Throwable)` or `catch (Exception)` without re-throwing or specific handling
- [ ] Checked vs unchecked exception usage is consistent with the project's exception hierarchy
- [ ] No sensitive data (passwords, tokens, PII) appears in exception messages or stack traces
- [ ] `@ControllerAdvice` handles all expected exception types with proper HTTP status codes
- [ ] Exceptions from `@Async` methods and `CompletableFuture` chains are observable

## 4. Transaction Management

- [ ] `@Transactional` propagation is intentional — not just accepting the default blindly
- [ ] Transaction isolation level is appropriate for the use case (READ_COMMITTED vs SERIALIZABLE)
- [ ] `rollbackFor` is specified for checked exceptions (`@Transactional(rollbackFor = Exception.class)`)
- [ ] Transactions are kept short — no external HTTP calls or long computations inside a transaction
- [ ] No nested `@Transactional` calls that inadvertently join the outer transaction when they should not
- [ ] Self-invocation of `@Transactional` methods within the same class is avoided (proxy bypass)

## 5. Serialization Safety

- [ ] Jackson `ObjectMapper` is configured to fail on unknown properties and has default typing disabled
- [ ] No `java.io.ObjectInputStream` usage for untrusted input
- [ ] XML processing disables external entities and DTDs (`XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES = false`)
- [ ] Jackson `@JsonTypeInfo` uses explicit `@JsonSubTypes` whitelist — no open polymorphic typing
- [ ] SnakeYAML uses `SafeConstructor` when parsing untrusted YAML
- [ ] API request/response DTOs are immutable (records or final fields with no setters)

## 6. Input Validation and Security

- [ ] Bean Validation (`@Valid`) is applied on controller request bodies and path variables
- [ ] SQL queries use parameterized statements — no string concatenation in JPQL or native queries
- [ ] File paths from external input are sanitized against path traversal (`Path.normalize()` + prefix check)
- [ ] SSRF protection: URLs from user input are validated against an allowlist before making HTTP requests
- [ ] `SecureRandom` is used for security-sensitive randomness, never `java.util.Random`
- [ ] No hardcoded secrets, API keys, or credentials in source code

## 7. Spring/Framework Discipline

- [ ] Constructor injection only — no field `@Autowired`
- [ ] No circular dependencies — redesign if detected
- [ ] Profile-specific configuration is in the correct `application-{profile}.yml`
- [ ] Bean scope is appropriate (`singleton` for stateless, `prototype`/`request` for stateful)
- [ ] `@ConfigurationProperties` is used over scattered `@Value` for grouped config
- [ ] Auto-configuration is understood — no conflicting manual bean definitions

## 8. API and Interface Design

- [ ] Interfaces follow ISP — no large interfaces forcing implementors to provide unused methods
- [ ] Classes and methods are package-private by default — only `public` when needed outside the package
- [ ] Public API methods have Javadoc explaining contract, parameters, and exceptions thrown
- [ ] DTOs are immutable — records (Java 16+) or final classes with no setters
- [ ] Return types are specific (`List<Order>` not `Object`, `Optional<Order>` not nullable `Order`)
- [ ] Builder pattern is used for types with 3+ optional parameters

## 9. Testing Completeness

- [ ] JUnit 5 lifecycle is correct — `@BeforeEach` / `@AfterEach` clean up shared state
- [ ] `@ParameterizedTest` is used for functions with multiple input/output combinations
- [ ] Testcontainers is used for integration tests against real databases/services instead of mocks
- [ ] `MockMvc` is used for controller tests with proper status code and response body assertions
- [ ] Mockito `verify` is used sparingly — prefer asserting on outputs over asserting on interactions
- [ ] Error paths and edge cases are tested explicitly (not just happy path)

## 10. Code Hygiene

- [ ] No bare `TODO` comments without a tracking reference or explanation
- [ ] No `System.out.println` or `System.err.println` — use SLF4J logger
- [ ] No star imports (`import java.util.*`) — use explicit imports
- [ ] Consistent code formatting (project formatter or standard style)
- [ ] No unused imports, dead code, or commented-out blocks
- [ ] Package names are lowercase, no underscores, following the project's reverse-domain convention
