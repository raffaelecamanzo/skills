---
name: journal-creator
description: Read the SRS, architecture, and frontend-design specs to produce a comprehensive, dependency-ordered journal of user and technical stories at docs/planning/journal.md. Use when the user asks to "create a journal", "generate stories", "plan the backlog", "create a story map", or "break down the specs into stories". Can be invoked standalone after the product-owner and design-coordinator workflows complete, or with explicit file paths.
---

# Journal Creator — Story Journal

## Purpose

Read validated specification documents and produce one deliverable:
1. **`docs/planning/journal.md`** — Dependency-ordered journal of user and technical stories

The journal creator's primary value is **bridging specs to implementation** — transforming validated requirements, architecture decisions, and design specifications into an actionable, ordered backlog where every story traces to its source, every dependency is explicit, and every parallel opportunity is surfaced. If a requirement isn't captured in a story, it will be lost in implementation.

---

## Journal Creator Mindset

Embody these qualities throughout the process:

- **Completeness obsession** — if a requirement isn't captured in a story, it will be lost in implementation. Every FR, every architecturally-significant NFR, every ADR must have a home.
- **Dependency precision** — incorrect ordering wastes parallel capacity or causes blocked work. Dependencies must be genuine (data/API/infrastructure), not assumed.
- **Traceability discipline** — every story must trace back to its source requirements and architecture decisions so downstream phases can work without re-reading all specs.

---

## Workflow

### Phase 0: Locate & Read Inputs

1. **If invoked with file arguments**, use those files directly (e.g., `/journal-creator path/to/software-spec.md path/to/architecture.md`).
2. If the user specifies files in conversation, use those.
3. Otherwise, look for the default paths listed below.
4. If required files are not found, ask the user to provide them — do not proceed without them.

**Required inputs:**
- `docs/specs/software-spec.md` (SRS)
- `docs/specs/architecture.md`

**Optional inputs:**
- `docs/specs/frontend-design.md` (skip gracefully if absent — backend-only projects are valid)

Read and deeply internalize ALL documents before any analysis. Announce: "Reading specification documents..."

---

### Phase 1: Internal Extraction (internal, not shown to user)

Before synthesizing stories, silently extract structured data from each document:

**From SRS (`software-spec.md`):**
- All FRs grouped by functional area (Section 3.x)
- Cross-cutting NFRs (Section 4)
- Data requirements and entities (Section 5)
- Interface requirements (Section 6)
- Business rules
- Assumptions, risks, open questions

**From Architecture (`architecture.md`):**
- Component decomposition (Section 4) — map components to functional areas
- ADRs (Section 11) — which decisions create implementation work
- Technology stack (Section 5) — foundation stories
- Integration points (Section 7) — external system stories
- Security architecture (Section 8) — security stories
- Deployment architecture (Section 9) — infrastructure stories
- Cross-cutting concerns (Section 10) — observability, error handling stories

**From Frontend Design (`frontend-design.md`, if present):**
- Component hierarchy → UI implementation stories
- Page layouts → page-level stories
- Interaction patterns → UX stories
- Responsive/accessibility requirements → cross-cutting UI stories

---

### Phase 2: Story Synthesis

Map extracted data to stories following these rules:

| Source | Story Type | Mapping Strategy |
|--------|-----------|-----------------|
| FR group (SRS §3.x) | User | One story per functional area, or split if area has distinct capabilities |
| NFR (SRS §4) | Technical | Group related NFRs into stories (e.g., all performance NFRs → one perf story) |
| Data entities (SRS §5) | Technical | Data model/schema story per bounded context |
| ADR (Arch §11) | Technical | Infrastructure/setup stories for technology decisions |
| Component (Arch §4) | Technical | When component requires standalone implementation work |
| Integration (Arch §7) | Technical | One story per external system integration |
| Security (Arch §8) | Technical | Auth story, data protection story, etc. |
| Deployment (Arch §9) | Technical | CI/CD, IaC, environment setup stories |
| Cross-cutting (Arch §10) | Technical | Observability, error handling, config stories |
| UI component (Frontend) | User | One story per page or major component group |

**Story ID convention:** `S-NNN` (sequential, zero-padded to 3 digits)

**Each story includes:**
- `### S-NNN: [Title]`
- `**Type:** User | Technical`
- `**Depends on:** S-NNN, S-NNN` (or "None")
- `**Parallel group:** Group [Letter]`
- `**Refs:** FR-XX-##, NFR-XX-##, ADR-##` (source requirement/decision IDs)
- `**Architecture:** [Brief architecture reference when applicable]`
- 2-3 sentence description
- **Acceptance criteria:** 3-5 bullets extracted from requirements
- `- [ ] Not started` (checklist mark)

---

### Phase 3: Dependency Analysis & Ordering

Build a dependency graph following these tiers:

1. **Foundation stories first** — project setup, data model, auth infrastructure (these have no dependencies)
2. **Core service stories next** — depend on foundation
3. **Feature stories** — depend on core services and data model
4. **Integration stories** — depend on the components they connect
5. **Cross-cutting/polish stories** — observability, performance tuning, deployment (depend on features being built)
6. **Frontend stories** — depend on the backend APIs they consume

**Dependency rules:**
- A story depends on another ONLY if it needs that story's output (API, data schema, infrastructure, shared component)
- Do NOT create false dependencies from logical grouping alone
- Cross-cutting concerns (logging, auth) that are consumed everywhere depend on being built once, then stories that need them declare the dependency

**Parallel group assignment:**
- Stories with the same set of dependencies (or no dependencies) that don't depend on each other → same parallel group
- Use alphabetical group labels: Group A (foundation), Group B, Group C...
- A group represents "these stories can all be worked on simultaneously"

**Topological sort:**
- Order stories so no story appears before its dependencies
- Within the same dependency tier, order by: foundation → data → backend → frontend → cross-cutting

Announce when moving to journal generation and summarize the story counts and dependency structure.

---

### Phase 4: Generate Journal

Create `docs/planning/journal.md` following the template in [references/journal-template.md](references/journal-template.md).

**Before writing:**
```bash
mkdir -p docs/planning
```

**Ensure:**
- Every FR from SRS Section 3 is covered by at least one story
- Every ADR that implies implementation work has a corresponding story
- Stories are numbered sequentially in dependency order
- Parallel groups are consistent (no circular references)

---

### Phase 5: Present & Highlight

After generation, present the journal and highlight:

- Total story count (user vs technical breakdown)
- Number of parallel groups and estimated critical path length
- 3-5 most critical stories (foundation or high-risk)
- Stories based on unvalidated assumptions (from SRS/architecture assumption tables)
- Any open questions from specs that affect story scope
- Coverage gaps (if any requirements couldn't be mapped to stories — this should be zero)

---

## Quality Checks (mandatory)

Before presenting the document, verify:

- [ ] Every FR from SRS Section 3 is represented in at least one story
- [ ] Every architecturally-significant NFR has a corresponding technical story
- [ ] Every ADR that implies implementation work has a story
- [ ] All stories have at least one requirement reference (Refs field)
- [ ] No story appears before its dependencies in the ordered list
- [ ] Parallel groups contain no cross-dependent stories
- [ ] Foundation stories (Group A) have no dependencies
- [ ] Every story has 3-5 acceptance criteria
- [ ] Story IDs are sequential with no gaps
- [ ] Frontend stories (if any) depend on their backend API stories
- [ ] The journal is self-contained — readable without the spec documents (but references them)
- [ ] Missing optional docs (frontend-design.md) don't cause gaps — backend-only is valid
