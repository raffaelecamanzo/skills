# Self-Review Checklist

Walk through every section before delivering code. Sections are ordered by bug severity — rendering and hooks issues break production; style issues do not.

---

## 1. Component Rendering Correctness

- [ ] No infinite render loops (state updates inside render path without guards)
- [ ] Components unmount cleanly — no state updates after unmount
- [ ] Conditional hooks are never used (hooks always called in the same order)
- [ ] Key props are stable and meaningful (no array index keys on dynamic lists)
- [ ] Suspense boundaries exist around lazy-loaded components
- [ ] Error boundaries catch and handle rendering failures in critical subtrees

## 2. Hooks Safety

- [ ] `useEffect` dependencies are exhaustive and correct (no stale closures)
- [ ] `useEffect` cleanup functions cancel async work (AbortController, clearTimeout, subscription unsubscribe)
- [ ] `useRef` is used for values that must not trigger re-renders
- [ ] `useState` initializer functions are used for expensive initial values (not inline computation)
- [ ] Custom hooks return stable references where consumers depend on referential equality
- [ ] No side effects outside `useEffect` / event handlers (effects belong in effects, not in render)

## 3. Error Handling

- [ ] Async operations have try/catch with user-facing error states
- [ ] API errors display meaningful feedback — never raw error messages or stack traces
- [ ] Error boundaries exist at appropriate granularity (page-level at minimum)
- [ ] Loading and error states are handled exhaustively — no missing states in data fetching
- [ ] Form validation errors are accessible (linked to inputs via `aria-describedby`)
- [ ] No silently swallowed Promise rejections (`.catch(() => {})` without justification)

## 4. State Management

- [ ] State lives at the lowest common ancestor — no unnecessary lifting
- [ ] Server state is managed through a data-fetching library (React Query, SWR, etc.), not manually in component state
- [ ] No redundant derived state (`useMemo` for derived values, not separate `useState`)
- [ ] Form state uses controlled components or a form library — no uncontrolled/controlled hybrid
- [ ] Global state is justified — local state or composition is preferred when sufficient
- [ ] Optimistic updates have rollback handling for failure cases

## 5. TypeScript Strictness

- [ ] No `any` types without a justification comment — prefer `unknown` at boundaries
- [ ] Props interfaces are explicit — no `Record<string, any>` or spreading unknown objects
- [ ] Discriminated unions are used for state machines and variant types
- [ ] Generic components have proper constraints (`<T extends Base>`, not `<T>`)
- [ ] Event handler types are explicit (`React.MouseEvent<HTMLButtonElement>`, not `any`)
- [ ] API response types match the actual API contract — no blind type assertions

## 6. Performance

- [ ] `React.memo` is used only where measured re-renders are a problem — not reflexively
- [ ] `useMemo` / `useCallback` are justified by profiling or referential equality needs
- [ ] Large lists use virtualization (react-window, tanstack-virtual)
- [ ] Images have explicit dimensions or aspect ratios to prevent layout shift
- [ ] Code splitting is applied to routes and heavy components (`React.lazy` + Suspense)
- [ ] No blocking operations in the render path (heavy computation goes to workers or effects)

## 7. Input Validation and Security

- [ ] User input is sanitized before rendering — no raw HTML injection without DOMPurify sanitization
- [ ] URL parameters and query strings are validated before use
- [ ] Authentication tokens are stored securely (not in localStorage for high-security contexts)
- [ ] External links use `rel="noopener noreferrer"` when opening new tabs
- [ ] No secrets, API keys, or credentials in client-side code or public environment variables
- [ ] Content Security Policy headers are respected — no inline scripts or eval

## 8. Component API Design

- [ ] Props interfaces are minimal — only what the component needs
- [ ] Children and render props are used for composition over configuration
- [ ] Default props are set via destructuring defaults, not `defaultProps`
- [ ] Ref forwarding is implemented where consumers need DOM access (`forwardRef`)
- [ ] Components are single-responsibility — rendering logic, data fetching, and business logic are separated
- [ ] Exported components have JSDoc comments on their props interface

## 9. Testing Completeness

- [ ] Components are tested for behavior, not implementation (Testing Library queries by role/text, not className)
- [ ] User interactions are tested (click, type, submit) with `userEvent`, not `fireEvent`
- [ ] Async operations are tested with proper `waitFor` / `findBy` assertions
- [ ] Error states and loading states are tested — not just happy path
- [ ] Accessibility is validated in tests (`toBeVisible`, `toHaveAccessibleName`)
- [ ] Custom hooks are tested via `renderHook` or through component integration

## 10. Code Hygiene

- [ ] No bare `TODO` comments without a tracking reference or explanation
- [ ] No commented-out code or dead components
- [ ] No unused imports or dependencies
- [ ] File names use kebab-case for components (`user-profile.tsx`) or match project convention
- [ ] CSS/styles are co-located or use the project's styling convention consistently
