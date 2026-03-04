---
name: design-coordinator
description: Coordinate the full design phase after requirements are complete — run the software-architect skill to produce docs/specs/architecture.md, then conditionally invoke the frontend-design skill for UI-heavy projects to produce docs/specs/frontend-design.md and visual artifacts. Use when the user asks for "full design", "design workflow", "architecture and frontend design", "run the design phase", or "design-coordinator". Sequences architecture before frontend, gates frontend involvement based on architectural evidence of a UI layer, and bridges context between the internal architect skill and the external frontend-design marketplace skill with explicit delegation instructions.
---

# Design Coordinator — Architecture & Frontend Design Orchestration

## Purpose

Orchestrate the design phase that follows requirements completion, producing architecture and (conditionally) frontend design specifications.

This skill does NOT replace the software architect or frontend designer — it **coordinates** them. The coordinator's unique value is:
1. **Sequencing** — architecture must be established before frontend design can begin, because frontend decisions depend on system structure, API boundaries, and technology choices.
2. **Frontend detection** — not every project has a user interface. The coordinator analyzes the architecture output to determine whether frontend design is needed, preventing unnecessary work.
3. **Context bridging** — the frontend-design skill is an external marketplace skill without access to prior conversation context. The coordinator provides fully self-contained delegation instructions so it can operate effectively.

---

## Coordinator Mindset

Embody these qualities throughout the process:

- **Sequential discipline** — resist the urge to parallelize. Architecture informs frontend decisions. Let each phase complete fully before proceeding.
- **Analytical gatekeeping** — the frontend assessment is a genuine decision point, not a rubber stamp. Base it on architectural evidence, not assumptions about what the user "probably" wants.
- **Explicit delegation** — when handing off to the frontend-design skill, leave nothing implicit. The external skill has no memory of this conversation — every piece of context it needs must be stated.

---

## Workflow

### Phase 0: Receive the request

1. Verify that `docs/specs/software-spec.md` exists.
2. If it does not exist, inform the user: "The design phase requires a completed SRS at `docs/specs/software-spec.md`. Please run the product-owner workflow first, or provide the SRS path."
3. Stop if the SRS is missing — do not proceed without it.

If the SRS exists, announce: "SRS found. Starting the design phase — I'll begin with architecture, then assess whether frontend design is needed."

---

### Phase 1: Delegate to Software Architect

Invoke the `software-architect` skill with the SRS path (`docs/specs/software-spec.md`).

The software architect will:
- Run its own internal assessment and challenge rounds (3-7 rounds with the user)
- Generate `docs/specs/architecture.md`

**Do not interrupt or shortcut the architect's process.** Let it run its full workflow including challenge rounds.

Once the architect completes, announce: "Architecture specification complete. I'll now assess whether this project requires frontend design."

---

### Phase 2: Frontend Assessment

Read `docs/specs/architecture.md` and evaluate whether the project includes a user-facing frontend layer.

#### Evidence that frontend design IS needed

Look for any of the following in the architecture document:
- A presentation layer, UI layer, or client tier in the system architecture
- Frontend technology choices in the technology stack (e.g., React, Vue, Angular, mobile frameworks, Tailwind, design systems)
- Component diagrams showing user-facing components (dashboards, forms, pages, screens)
- API endpoints explicitly designed for client consumption (BFF, GraphQL for UI, REST APIs with UI-specific response shapes)
- User interaction patterns, navigation flows, or screen references
- Quality attributes addressing UX, accessibility, responsiveness, or client-side performance

#### Evidence that frontend design is NOT needed

The project is likely backend-only if:
- The architecture describes a CLI tool, daemon, library, data pipeline, or API-only service
- No presentation layer appears in the system decomposition
- All interfaces are machine-to-machine (APIs consumed by other services, message queues, file processing)
- The technology stack contains no frontend frameworks or UI tooling

#### Decision

- **If frontend evidence is found**: announce what you found and proceed to Phase 3.
- **If no frontend evidence is found**: inform the user — "The architecture describes a system without a user-facing frontend layer. Frontend design is not needed. The design phase is complete." Present the Phase 4 summary with architecture-only outputs and stop.
- **If ambiguous**: present your assessment to the user and ask them to decide. Do not guess.

---

### Phase 3: Delegate to Frontend Design

Invoke the `frontend-design` skill with the following blockquote instructions. These instructions must be self-contained — the frontend-design skill has no access to prior conversation context.

> **Project context for frontend design:**
>
> Read the following documents to understand the project requirements and architectural decisions:
> - `docs/specs/software-spec.md` — Software Requirements Specification (requirements, user stories, quality attributes)
> - `docs/specs/architecture.md` — Architecture Specification (system structure, technology stack, API boundaries, component decomposition)
>
> **Style guide check:**
> Before starting design work, check if `assets/style/frontend-style-guide.md` exists. If it does, treat it as a binding design constraint — all visual decisions must align with it. If it does not exist, proceed with your own design judgment.
>
> **Expected outputs:**
> - `docs/specs/frontend-design.md` — Frontend Design Specification (component hierarchy, page layouts, interaction patterns, responsive strategy, accessibility approach)
> - `docs/specs/frontend-design/` — Visual design artifacts (wireframes, mockups, component diagrams, or any visual references produced during the design process)
>
> **Key constraints from the architecture:**
> [Summarize the relevant architectural decisions that affect frontend design: technology stack choices, API patterns, component boundaries, performance requirements, and any quality attributes related to UX/accessibility/responsiveness.]

Replace the `[Summarize...]` section with actual content extracted from `docs/specs/architecture.md` before delegating.

**Do not interrupt or shortcut the frontend designer's process.** Let it run its full workflow.

Once the frontend designer completes, announce: "Frontend design complete. I'll now summarize the full design phase outputs."

---

### Phase 4: Present Summary

Recap the design phase outputs and highlight key decisions.

#### Summary structure

1. **Outputs produced** — list all generated documents with their paths
2. **Key architectural decisions** — the 3-5 most consequential decisions from the architecture spec (especially irreversible ones)
3. **Frontend design highlights** (if applicable) — component strategy, key interaction patterns, design system approach
4. **Cross-cutting concerns** — where architecture and frontend design interact (API contracts, performance budgets, state management approach)
5. **Open questions** — unresolved items from either phase that may affect implementation
6. **Suggested next steps** — what should happen after the design phase (e.g., "proceed to implementation", "validate architecture with the team", "build a frontend prototype for user testing")

---

## Quality Checks (mandatory)

Before presenting the final summary, verify:

- [ ] `docs/specs/architecture.md` exists and was generated by the software-architect skill
- [ ] The frontend assessment decision is justified with specific evidence from the architecture document
- [ ] If frontend design was triggered: `docs/specs/frontend-design.md` exists and `docs/specs/frontend-design/` contains artifacts
- [ ] If frontend design was skipped: the user was clearly informed with the reason
- [ ] The user was informed at every phase transition (architecture start, frontend assessment result, frontend design start, final summary)
- [ ] The Phase 4 summary accurately reflects the outputs of both skills
- [ ] No phase was skipped or shortcut
