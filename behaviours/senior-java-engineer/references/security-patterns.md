# Security Patterns

Java-specific secure coding patterns. These are not generic OWASP guidelines — they address the concrete APIs and idioms where Java code becomes vulnerable.

---

## 1. Input Handling

- Validate at the system boundary using Bean Validation (`@Valid` on controller parameters):
  ```java
  @PostMapping("/orders")
  public ResponseEntity<Order> create(@Valid @RequestBody CreateOrderRequest request) { ... }
  ```
- Write custom `@Constraint` validators for domain-specific rules (e.g., valid currency code, ISO date range).
- Enforce request size limits at the server level (`spring.servlet.multipart.max-file-size`, `server.tomcat.max-swallow-size`).
- Validate `Content-Type` headers early — reject unexpected media types in middleware or via `consumes` on controller mappings.
- Bound string lengths with `@Size` and collection sizes with `@Size` before processing.

## 2. SQL and Data Access

- Always use parameterized queries — JPA named parameters or JDBC `PreparedStatement`:
  ```java
  // JPA
  @Query("SELECT o FROM Order o WHERE o.customerId = :customerId")
  List<Order> findByCustomerId(@Param("customerId") String customerId);

  // JDBC
  PreparedStatement ps = conn.prepareStatement("SELECT * FROM orders WHERE id = ?");
  ps.setString(1, orderId);
  ```
- Never build JPQL or SQL with string concatenation — JPQL is injectable too.
- Native queries (`@Query(nativeQuery = true)`) require extra scrutiny — the same parameterization rules apply.
- Beware Hibernate pitfalls: N+1 queries (`@EntityGraph` or `JOIN FETCH`), open session in view (disable it), lazy initialization exceptions.
- Use interface projections for read-only queries — avoid fetching full entities when only a few columns are needed.

## 3. Cryptography

- Use `SecureRandom` for all security-sensitive random values. Never `java.util.Random` or `Math.random()`:
  ```java
  SecureRandom random = SecureRandom.getInstanceStrong();
  byte[] token = new byte[32];
  random.nextBytes(token);
  ```
- Password hashing: bcrypt (`BCryptPasswordEncoder`) or Argon2 (`Argon2PasswordEncoder`). Never SHA/MD5 for passwords.
- Token comparison: `MessageDigest.isEqual()` to prevent timing attacks.
- TLS minimum version 1.2 — configure via `server.ssl.protocol` or custom `SSLContext`.
- Store keys in `KeyStore` — never as plaintext files or hardcoded strings.
- Prefer AES-GCM for symmetric encryption (authenticated encryption).

## 4. HTTP Server Hardening

- Spring Security filter chain as the primary defense layer:
  ```java
  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
      return http
          .headers(h -> h.contentTypeOptions(Customizer.withDefaults())
                         .frameOptions(f -> f.deny())
                         .httpStrictTransportSecurity(hsts -> hsts.maxAgeInSeconds(31536000)))
          .build();
  }
  ```
- CORS configuration: whitelist specific origins, methods, and headers — never `allowedOrigins("*")` with credentials.
- CSRF protection: enabled by default in Spring Security. Disable only for stateless APIs using token-based auth.
- Set security headers: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Strict-Transport-Security`.
- Rate limiting: use a filter or gateway-level throttle (Bucket4j, Resilience4j RateLimiter, or API gateway).
- Configure server timeouts (`server.tomcat.connection-timeout`, `spring.mvc.async.request-timeout`) to prevent slowloris.

## 5. Serialization Safety

- Configure Jackson `ObjectMapper` defensively — disable dangerous features:
  ```java
  objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, true);
  objectMapper.deactivateDefaultTyping();
  ```
- Never use `java.io.ObjectInputStream` for untrusted input — Java native deserialization is inherently unsafe.
- XXE prevention for XML processing:
  ```java
  XMLInputFactory factory = XMLInputFactory.newInstance();
  factory.setProperty(XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES, false);
  factory.setProperty(XMLInputFactory.SUPPORT_DTD, false);
  ```
- Jackson polymorphic typing (`@JsonTypeInfo`): use `@JsonSubTypes` with explicit whitelist. Never `defaultImpl` with a broad base type.
- SnakeYAML: always use `SafeConstructor` when parsing untrusted YAML — default constructor allows arbitrary object instantiation.

## 6. Secrets and Configuration

- Load secrets from environment variables, HashiCorp Vault, AWS Secrets Manager, or Spring Cloud Config — never hardcode.
- Use `@ConfigurationProperties` with type-safe binding:
  ```java
  @ConfigurationProperties(prefix = "app.database")
  public record DatabaseConfig(String url, String username, String password) {}
  ```
- Never log secrets — implement `toString()` that masks sensitive fields, or use a logging filter.
- `.gitignore` all files containing secrets (`application-local.yml`, `.env`, keystore files).
- Rotate secrets on a schedule — design configuration to support hot-reload where possible.

## 7. Dependency Supply Chain

- Run OWASP Dependency-Check (`dependency-check-maven` or Gradle plugin) before delivery.
- Maven Enforcer plugin with `dependencyConvergence` rule — prevent conflicting transitive versions:
  ```xml
  <plugin>
      <artifactId>maven-enforcer-plugin</artifactId>
      <configuration>
          <rules><dependencyConvergence/></rules>
      </configuration>
  </plugin>
  ```
- Use BOM (Bill of Materials) imports for managed dependency versions (`spring-boot-dependencies`, `spring-cloud-dependencies`).
- Monitor CVEs: subscribe to security advisories for Spring, Jackson, Log4j, and other core dependencies.
- Audit transitive dependencies — a direct dependency with 50+ transitive deps is a supply chain risk.

## 8. Authentication and Authorization

- Define `SecurityFilterChain` as a bean — never extend `WebSecurityConfigurerAdapter` (deprecated):
  ```java
  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
      return http
          .authorizeHttpRequests(auth -> auth
              .requestMatchers("/public/**").permitAll()
              .anyRequest().authenticated())
          .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()))
          .build();
  }
  ```
- JWT validation: verify `exp`, `iss`, and `aud` claims. Never trust a JWT without signature verification.
- OAuth2 resource server: use Spring Security's built-in JWT decoder with issuer validation.
- Method-level authorization: `@PreAuthorize("hasRole('ADMIN')")` for fine-grained access control.
- Service-to-service: mTLS or signed JWTs with service identity — never shared API keys.
