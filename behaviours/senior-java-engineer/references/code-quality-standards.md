# Code Quality Standards

Opinionated defaults for decisions where the compiler and SpotBugs are silent. **Existing project conventions always take priority** — adopt the codebase style, then apply these where no convention exists.

---

## 1. Project Layout

- Follow the existing project structure. Do not reorganise without explicit approval.
- If starting fresh: Maven/Gradle standard layout (`src/main/java`, `src/test/java`), package-by-feature over package-by-layer:
  ```
  com.example.app/
  ├── order/
  │   ├── OrderService.java
  │   ├── OrderRepository.java
  │   ├── OrderController.java
  │   └── dto/
  ├── user/
  │   ├── UserService.java
  │   └── ...
  └── config/
  ```
- Keep the `Application` class thin — `@SpringBootApplication` annotation, `SpringApplication.run()`, nothing else.
- Tests mirror the main source tree: `src/test/java/com/example/app/order/OrderServiceTest.java`.

## 2. Naming

- Classes: PascalCase. No `Impl` suffix — use descriptive names (`JpaOrderRepository`, not `OrderRepositoryImpl`).
- Interfaces: PascalCase noun describing the capability: `OrderRepository`, `PaymentGateway`, `NotificationSender`.
- Static factory methods: `of()`, `from()`, `create()` — avoid `new` prefix on static methods.
- Builder pattern for 3+ optional parameters:
  ```java
  OrderRequest.builder()
      .customerId(id)
      .currency(Currency.USD)
      .build();
  ```
- Avoid stuttering: `OrderService.createOrder()` not `OrderService.createOrderService()`.
- Package names: lowercase, single-word, no underscores.

## 3. Exception Handling Style

- Use unchecked exceptions for domain errors — callers should not be forced to catch business rule violations:
  ```java
  public class OrderNotFoundException extends RuntimeException {
      private final String orderId;
      public OrderNotFoundException(String orderId) {
          super("Order not found: " + orderId);
          this.orderId = orderId;
      }
  }
  ```
- Reserve checked exceptions for system boundary failures where the caller must make a recovery decision (e.g., retryable I/O).
- Build a custom exception hierarchy rooted in a project-specific base exception.
- Use `@ControllerAdvice` with `@ExceptionHandler` for centralized error translation to HTTP responses.
- Never catch `Throwable` or `Exception` broadly — catch the most specific type possible.
- Never use exceptions for control flow.

## 4. Method Signatures

- Use parameter objects when 3+ parameters share the same type or when a method signature grows beyond 4 parameters:
  ```java
  // Bad:  createOrder(String customerId, String productId, String currency, String address)
  // Good: createOrder(CreateOrderRequest request)
  ```
- Return `Optional<T>` for query methods that may not find a result. Never return null from a method that could return `Optional`.
- Never pass `null` as a method argument — use `Objects.requireNonNull()` at public API boundaries:
  ```java
  public OrderService(OrderRepository repository) {
      this.repository = Objects.requireNonNull(repository, "repository must not be null");
  }
  ```
- Prefer specific return types over `Object` or raw types. Return `List<Order>` not `List`.

## 5. Testing Style

- JUnit 5 exclusively. Use `@Nested` classes to group related scenarios:
  ```java
  class OrderServiceTest {
      @Nested
      class WhenCreatingOrder {
          @Test void shouldPersistOrder() { ... }
          @Test void shouldRejectDuplicateOrder() { ... }
      }
  }
  ```
- Use `@ParameterizedTest` with `@MethodSource` or `@CsvSource` for data-driven tests.
- AssertJ for fluent assertions: `assertThat(result).isNotNull().extracting(Order::status).isEqualTo(CREATED)`.
- Mockito judiciously — prefer real collaborators and Testcontainers over mocks for repositories and external services.
- Test naming: `should[ExpectedBehavior]` or `should[ExpectedBehavior]When[Condition]`.
- Test helpers and fixtures in a `testutil` package or `@TestConfiguration` classes.

## 6. Logging and Observability

- Always use the SLF4J facade — never `System.out.println` or direct logger implementations:
  ```java
  private static final Logger log = LoggerFactory.getLogger(OrderService.class);
  ```
- Use MDC (Mapped Diagnostic Context) for correlation IDs in request-scoped operations:
  ```java
  MDC.put("correlationId", correlationId);
  try { ... } finally { MDC.remove("correlationId"); }
  ```
- Configure structured JSON logging in production (Logback `LogstashEncoder` or similar).
- Use parameterized messages — never string concatenation in log calls:
  ```java
  // Good: log.info("Order created: orderId={}, customerId={}", orderId, customerId);
  // Bad:  log.info("Order created: " + orderId + " for " + customerId);
  ```
- Never log secrets, tokens, passwords, or full request/response bodies containing PII.

## 7. Dependency Injection

- Constructor injection only — no field `@Autowired`:
  ```java
  @Service
  public class OrderService {
      private final OrderRepository repository;
      private final EventPublisher publisher;

      public OrderService(OrderRepository repository, EventPublisher publisher) {
          this.repository = repository;
          this.publisher = publisher;
      }
  }
  ```
- No circular dependencies — if detected, redesign the dependency graph.
- Use `@Qualifier` with descriptive names when multiple beans of the same type exist.
- Prefer `@ConfigurationProperties` over scattered `@Value` annotations for configuration.

## 8. Concurrency Patterns

- Use `CompletableFuture` with explicit exception handling — never leave unhandled completion stages:
  ```java
  CompletableFuture.supplyAsync(() -> fetchOrder(id), executor)
      .thenApply(this::enrichOrder)
      .exceptionally(ex -> { log.error("Failed to fetch order", ex); return fallback; });
  ```
- Virtual threads (Java 21+): prefer for I/O-bound workloads. Use `Executors.newVirtualThreadPerTaskExecutor()`.
- Always manage `ExecutorService` lifecycle — shutdown gracefully:
  ```java
  executor.shutdown();
  if (!executor.awaitTermination(30, TimeUnit.SECONDS)) {
      executor.shutdownNow();
  }
  ```
- Prefer immutable DTOs (records in Java 16+) for data transfer between threads.
- Use `ConcurrentHashMap` over synchronized `HashMap`. Use `AtomicReference`/`AtomicLong` over `volatile` + manual CAS.
