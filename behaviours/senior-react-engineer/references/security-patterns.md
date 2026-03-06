# Security Patterns

React and frontend-specific secure coding patterns. These are not generic OWASP guidelines — they address the concrete APIs and browser behaviors where frontend code becomes vulnerable.

---

## 1. XSS Prevention

- React's JSX escapes by default — this is the primary defense. Never bypass it without justification.
- Raw HTML injection requires DOMPurify (or equivalent) sanitization of the input before rendering.
- Never construct HTML strings from user input and inject them into the DOM.
- URL values from user input must be validated before use in `href` or `src`:
  ```tsx
  const isSafe = /^https?:\/\//.test(url);
  ```
  Reject `javascript:`, `data:`, and `vbscript:` schemes.
- Template literals in dynamic class names are safe — but template literals building HTML or SQL are not.

## 2. Authentication and Token Management

- Access tokens in SPAs: prefer `httpOnly` cookies set by the backend. If cookies are not viable, use in-memory storage (module-scoped variable or context) — never `localStorage`.
- Refresh tokens: always `httpOnly`, `Secure`, `SameSite=Strict` cookies. Never accessible to JavaScript.
- Implement silent refresh (iframe or refresh endpoint) before token expiry — do not wait for 401.
- PKCE (Proof Key for Code Exchange) is mandatory for OAuth 2.0 Authorization Code flow in SPAs.
- Clear all auth state on logout — memory, cookies (via backend), and any cached queries.
- Route guards must check auth state before rendering protected content — not after.

## 3. Content Security Policy

- Configure CSP headers server-side (not via `<meta>` tags, which are weaker):
  - `default-src 'self'`
  - `script-src 'self'` — no `'unsafe-inline'` or `'unsafe-eval'`
  - `style-src 'self' 'unsafe-inline'` (required by most CSS-in-JS; use nonces if possible)
  - `img-src 'self' data: https:` (adjust to actual image sources)
- Use nonces for inline scripts when unavoidable (SSR hydration scripts).
- `connect-src` must whitelist API origins explicitly — do not use `*`.
- Report violations: `report-uri` or `report-to` directive with a monitoring endpoint.

## 4. Input Sanitization

- Validate at the boundary: form submission handlers, URL parameter parsing, and API response consumption.
- Use Zod, Yup, or similar runtime validation for API responses — TypeScript types are compile-time only and do not protect against malformed runtime data:
  ```tsx
  const UserSchema = z.object({ id: z.string(), name: z.string() });
  const user = UserSchema.parse(apiResponse);
  ```
- Sanitize search/filter parameters before passing to API calls — prevent injection into backend queries.
- File uploads: validate type, size, and name on the client (defense in depth; backend validates authoritatively).
- Numeric inputs: `parseInt`/`parseFloat` with explicit radix and NaN checks.

## 5. Dependency Supply Chain

- Run `npm audit` (or `pnpm audit` / `yarn audit`) before delivery.
- Evaluate new packages against: bundle size (`bundlephobia.com`), maintenance activity, open CVEs, type quality, and transitive dependency count.
- Prefer native browser APIs and React built-ins over utility libraries for common operations.
- Lock file (`package-lock.json` / `pnpm-lock.yaml`) pins exact versions — do not delete or regenerate without review.
- Configure Dependabot or Renovate for automated security updates in CI.
- Audit `postinstall` scripts in new dependencies — disable with `--ignore-scripts` when evaluating.

## 6. CORS and API Communication

- API calls use relative paths or a configured base URL — never hardcode full URLs with credentials.
- Credentials mode: `credentials: 'include'` only for same-site or explicitly trusted origins.
- Validate `Content-Type` headers on API responses before parsing.
- Do not trust CORS to protect sensitive operations — CORS is a browser mechanism, not a security boundary. Server-side authorization is the real gate.
- Implement CSRF protection: `SameSite` cookies + custom header (`X-Requested-With`) or CSRF tokens.

## 7. Sensitive Data Handling

- Never store sensitive data in:
  - `localStorage` / `sessionStorage` (accessible to any script on the origin)
  - URL parameters or hash fragments (logged in browser history, server logs, referrer headers)
  - Redux DevTools-visible state (disable in production or exclude sensitive slices)
- Mask sensitive fields in forms: `type="password"`, `autocomplete="off"` for OTPs.
- Clear sensitive data from component state on unmount (auth tokens, personal data in forms).
- Client-side encryption is defense in depth, not a substitute for transport-layer (TLS) and server-side security.

## 8. Third-Party Integration Security

- Embed third-party scripts via `<script>` tags with `integrity` (SRI) and `crossorigin` attributes.
- Iframe embeds: use `sandbox` attribute with minimal permissions. Default to `sandbox=""` (all restrictions) and add only what is needed.
- PostMessage communication: always validate `origin` in the message handler:
  ```tsx
  window.addEventListener("message", (event) => {
    if (event.origin !== "https://trusted.example.com") return;
    // process event.data
  });
  ```
- Third-party analytics/tracking: load asynchronously, after critical rendering. Audit what data they collect and where they send it.
- Never pass auth tokens or sensitive data to third-party SDKs unless contractually and technically justified.
