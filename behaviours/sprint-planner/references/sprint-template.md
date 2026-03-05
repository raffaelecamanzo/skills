# Sprint Template

Use this template for the output file `docs/planning/sprints/sprint-N.md`. This document defines a single sprint increment — a coherent subset of journal stories decomposed into atomic tasks with dependency-respecting execution order.

```markdown
# Sprint N: [Sprint Title]

> Source: docs/planning/journal.md
> SRS: docs/specs/software-spec.md
> Architecture: docs/specs/architecture.md
> Frontend Design: docs/specs/frontend-design.md (if applicable)
> Author: Sprint Planner (AI-assisted)
> Date: [generation date]
> Status: PLANNED
> Version: 1.0

## 1. Sprint Objective

[2-4 sentences: what this increment proves, which architectural decisions it validates,
what functional and/or technical capability it demonstrates.]

## 2. Value Statement

[2-3 sentences: why this increment matters to the project, what it unblocks,
what risk it reduces.]

## 3. Sprint Summary

| Metric | Value |
|--------|-------|
| Stories | [N] |
| User stories | [N] |
| Technical stories | [N] |
| Total tasks | [N] |
| Parallel tracks | [N] |

## 4. Execution Order

[Dependency-respecting sequence showing parallelization opportunities]

| Step | Stories | Can start after |
|------|---------|----------------|
| 1 | S-NNN, S-NNN | Immediately (no intra-sprint deps) |
| 2 | S-NNN | Step 1 complete (depends on S-NNN) |
| ... | ... | ... |

## 5. Stories

### S-NNN: [Title]
- **Status:** PLANNED
- **Type:** User | Technical
- **Parallel with:** S-NNN, S-NNN (or "None within this sprint")
- **Depends on (intra-sprint):** S-NNN (or "None")
- **Refs:** [requirement IDs from journal]
- **Architecture:** [architecture.md reference from journal]

#### Tasks

| # | Task | Purpose | Parallel | Status | Refs |
|---|------|---------|----------|--------|------|
| 1 | [Atomic action] | [Why this task] | Yes/No (with which tasks) | PLANNED | [arch/SRS section] |
| 2 | [Atomic action] | [Why this task] | ... | PLANNED | ... |

#### Acceptance Criteria
- [Criterion from journal]
- [Criterion]
- [Criterion]

#### Testing & Verification
[Placeholder — describe approach to verify story completion and acceptance criteria.
To be refined during implementation.]

---

[...repeat for all stories...]

## 6. References

- [SRS](../../specs/software-spec.md) — [relevant sections]
- [Architecture](../../specs/architecture.md) — [relevant sections]
- [Frontend Design](../../specs/frontend-design.md) — [if applicable]
- [Journal](../journal.md) — Stories: S-NNN, S-NNN, ...

## 7. Risks & Dependencies

[Any sprint-specific risks, cross-sprint dependencies, or assumptions that affect this sprint's success.]

| Risk/Dependency | Affected Stories | Mitigation |
|----------------|-----------------|------------|
| [Description] | S-NNN | [Mitigation approach] |
```
