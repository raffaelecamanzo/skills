---
name: sprint-planner
description: Read the journal backlog alongside the SRS, architecture, and optional frontend-design specs to plan the next sprint increment. Produces docs/planning/sprints/sprint-N.md with dependency-respecting execution order and atomic task breakdowns, creates or updates docs/planning/sprint-log.md, and marks selected journal stories as Planned. Use when the user asks to "plan a sprint", "create the next sprint", "plan the next increment", or "break the backlog into sprints".
---

# Sprint Planner — Sprint Increment Planning

## Purpose

Read the journal backlog alongside the SRS, architecture, and optional frontend-design specs to plan the next sprint increment.

Deliverables:
1. `docs/planning/sprints/sprint-N.md` — Detailed sprint document
2. `docs/planning/sprint-log.md` — Created or updated sprint log
3. Updated `docs/planning/journal.md` — Selected stories change status to "Planned"

---

## Sprint Planner Mindset

Embody these qualities throughout the process:

- **Increment coherence** — every sprint must prove something. Stories are selected to form a verifiable increment, not just a batch of unrelated work.
- **Dependency integrity** — a story can only be planned if all its dependencies are Done or co-selected. No planning on hope.
- **Right-sized ambition** — target 3-7 stories per sprint (soft guideline). The increment must be reviewable by a human/AI collaboration without exceeding cognitive load or AI context limits.

---

## Workflow

### Phase 0: Input Acquisition

Locate and read required inputs:
- `docs/planning/journal.md` (required)
- `docs/specs/software-spec.md` (required)
- `docs/specs/architecture.md` (required)
- `docs/specs/frontend-design.md` (optional, skip gracefully)
- `docs/planning/sprint-log.md` (optional — if absent, this is Sprint 1)

Determine the next sprint number from sprint-log.md. If the file doesn't exist, sprint number is 1.

Announce: "Reading journal and specification documents..."

---

### Phase 1: Internal Assessment (internal, not shown to user)

Build the sprint planning context:

1. **Parse journal stories** — extract all stories with their S-NNN IDs, types, dependencies, parallel groups, refs, architecture references, acceptance criteria, and status.

2. **Compute eligible stories** — a story is eligible when:
   - Status is `**Status:** Not started`
   - ALL dependencies are either `**Status:** DONE` or eligible and co-selectable

3. **Build dependency graph** of eligible stories — identify:
   - Foundation stories (no deps among eligible set)
   - Dependency chains and critical paths
   - Parallel groups among eligible stories

4. **Identify sprint objective candidates** — cluster eligible stories by:
   - Functional theme (stories sharing the same functional area refs)
   - Architectural concern (stories validating the same ADRs)
   - Risk reduction (stories addressing open questions or unvalidated assumptions)
   - Foundation completion (if foundation stories remain unplanned)

5. **Cross-reference with architecture** — read relevant sections of architecture.md and SRS to understand:
   - Which ADRs are most consequential/irreversible
   - Which components are on the critical path
   - Which stories would provide the most architectural validation

---

### Phase 2: Sprint Objective Proposal

Present the sprint objective proposal to the user:

- **Sprint N title** — descriptive name
- **Objective statement** — what the increment proves (functional and/or technical)
- **Rationale** — why this objective now (risk reduction, foundation completion, critical path, etc.)
- **Scope outline** — which story areas and approximate story count
- **Alternative objectives considered** — briefly note 1-2 other viable objectives and why this one was preferred

**Gate: User approves or adjusts the sprint objective.**

If the user adjusts, revise the objective and re-present.

---

### Phase 3: Sprint Composition Proposal

Based on the approved objective, present the full sprint composition:

For each selected story:
- Story ID and title
- Why it was selected (contribution to objective)
- Parallelization with other sprint stories
- Task breakdown (atomic tasks with purpose, parallel capability, architecture/SRS references)
- Acceptance criteria (from journal)
- Testing & verification approach (placeholder to be refined)

Also present:
- **Execution order** — dependency-respecting sequence showing which stories can run in parallel and which must wait
- **Sizing rationale** — total stories, total tasks, complexity assessment, why this size is manageable
- **Stories NOT selected** — brief note on eligible stories left out and why (scope, objective fit, sizing)

**Gate: User approves or adjusts the sprint composition.**

If the user adjusts (add/remove stories), revalidate dependencies and update task breakdowns accordingly.

---

### Phase 4: Document Generation

After user approval, generate all outputs:

1. **Create sprint directory** if needed:
   ```bash
   mkdir -p docs/planning/sprints
   ```

2. **Generate `docs/planning/sprints/sprint-N.md`** following [references/sprint-template.md](references/sprint-template.md)

3. **Create or update `docs/planning/sprint-log.md`** following [references/sprint-log-template.md](references/sprint-log-template.md)

4. **Update `docs/planning/journal.md`** — for each selected story, change `**Status:** Not started` to `**Status:** PLANNED`

Present a summary of what was created/updated.

---

## Quality Checks (mandatory)

Before presenting the final documents, verify:

- [ ] Every selected story has all dependencies satisfied (Done or co-selected)
- [ ] No circular dependencies within the sprint
- [ ] Sprint objective is a coherent, provable statement
- [ ] Every selected story contributes to the sprint objective
- [ ] Task breakdowns reference architecture.md and/or SRS sections where applicable
- [ ] Execution order respects all intra-sprint dependencies
- [ ] Sprint-log entry is consistent with sprint document
- [ ] Journal statuses updated correctly (only selected stories changed to PLANNED)
- [ ] Sprint number is sequential with no gaps
- [ ] Sprint document is self-contained — readable without re-consulting all spec documents
- [ ] Story and task statuses are all set to PLANNED initially
