# Code Quality Standards

Opinionated defaults for decisions where the TypeScript compiler and ESLint are silent. **Existing project conventions always take priority** — adopt the codebase style, then apply these where no convention exists.

---

## 1. Project Layout

- Follow the existing project structure. Do not reorganise without explicit approval.
- If starting fresh: feature-based directory structure over type-based:
  ```
  src/
  ├── features/
  │   └── orders/
  │       ├── components/
  │       ├── hooks/
  │       ├── api/
  │       ├── types.ts
  │       └── index.ts       # public API barrel
  ├── shared/
  │   ├── components/        # design system primitives
  │   ├── hooks/
  │   ├── utils/
  │   └── types/
  ├── pages/ or app/         # routing entry points
  └── test/                  # test utilities and setup
  ```
- Co-locate tests beside the code they test (`user-profile.test.tsx` next to `user-profile.tsx`).
- Barrel files (`index.ts`) only at feature boundaries — avoid deep barrel chains that defeat tree-shaking.

## 2. Naming

- Components: PascalCase files matching the component name (`UserProfile.tsx` or `user-profile.tsx` — match project convention).
- Hooks: `use` prefix, camelCase: `useAuth`, `useOrderFilters`.
- Types/interfaces: PascalCase, no `I` prefix: `User`, `OrderStatus`, `ApiResponse<T>`.
- Constants: UPPER_SNAKE_CASE for true constants, camelCase for derived/computed values.
- Event handlers: `handle` prefix for definitions, `on` prefix for props:
  ```tsx
  // Definition in parent
  const handleSubmit = () => { ... };
  // Prop name in child
  <Form onSubmit={handleSubmit} />
  ```
- Avoid boolean prop names that read as commands: `isDisabled` over `disabled` when ambiguity exists, but prefer native HTML attribute names when wrapping DOM elements.

## 3. TypeScript Patterns

- `tsconfig.json` strict mode is non-negotiable:
  ```json
  { "strict": true, "noUncheckedIndexedAccess": true, "exactOptionalPropertyTypes": true }
  ```
- Discriminated unions for state machines:
  ```tsx
  type AsyncState<T> =
    | { status: "idle" }
    | { status: "loading" }
    | { status: "success"; data: T }
    | { status: "error"; error: Error };
  ```
- Branded types for domain IDs to prevent accidental swaps:
  ```tsx
  type UserId = string & { readonly __brand: "UserId" };
  type OrderId = string & { readonly __brand: "OrderId" };
  ```
- Prefer `unknown` over `any` at boundaries. Use type guards to narrow:
  ```tsx
  function isApiError(err: unknown): err is ApiError {
    return err instanceof Error && "code" in err;
  }
  ```
- Use `satisfies` for type-checked object literals that should infer their precise type:
  ```tsx
  const config = { timeout: 5000, retries: 3 } satisfies Config;
  ```
- Avoid type assertions (`as`) — use type guards or schema validation instead.

## 4. Component Patterns

- Prefer composition over configuration — use children and render props instead of flag props:
  ```tsx
  // Prefer:
  <Card><Card.Header>Title</Card.Header><Card.Body>...</Card.Body></Card>
  // Over:
  <Card title="Title" showHeader={true} headerVariant="bold" />
  ```
- Separate data-fetching from presentation: container components (or hooks) fetch, presentational components render.
- Use `forwardRef` when wrapping DOM elements or when consumers will need ref access.
- Custom hooks extract reusable logic — if a component has 3+ `useState`/`useEffect` calls for the same concern, extract a hook.
- Memoize callbacks passed to child components that use `React.memo` — otherwise the memo is defeated.

## 5. Testing Style

- Use Testing Library's query priority: `getByRole` > `getByLabelText` > `getByText` > `getByTestId`. Avoid querying by className or internal structure.
- Use `userEvent` (not `fireEvent`) for interactions — it simulates real browser behavior (focus, pointer, keyboard).
- Test behavior, not implementation: assert on visible outcomes (text, accessibility attributes, navigation), not on internal state or hook calls.
- Name test files to match: `user-profile.test.tsx` beside `user-profile.tsx`.
- Use `describe` blocks for grouping related scenarios; `it` for individual assertions:
  ```tsx
  describe("UserProfile", () => {
    it("displays the user name", () => { ... });
    it("shows an error when the API fails", () => { ... });
  });
  ```
- Mock at the network layer (`msw`) rather than at the module level when possible — this tests more of the real code path.

## 6. Data Fetching and Caching

- Use a data-fetching library (React Query, SWR, RTK Query) — do not hand-roll fetch-in-useEffect for server state.
- Configure stale times intentionally — do not leave defaults without reviewing them.
- Implement error and loading states exhaustively. Every query has three states: loading, error, success. Handle all three.
- Optimistic updates require rollback logic — always provide an `onError` handler that reverts the optimistic cache update.
- Invalidate related queries after mutations — do not rely on users refreshing the page.
- Prefetch data for likely next actions (next page, hover intent) to improve perceived performance.
