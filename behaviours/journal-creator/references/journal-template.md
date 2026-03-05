# Journal Template

Use this template for the output file `docs/planning/journal.md`. This document transforms validated specifications into an ordered, dependency-aware backlog of implementation stories. Adapt sections based on project scope.

```markdown
# Project Journal — [System/Feature Name]

> Source: docs/specs/software-spec.md
> Architecture: docs/specs/architecture.md
> Frontend Design: docs/specs/frontend-design.md (if applicable)
> Author: Journal Creator (AI-assisted)
> Date: [generation date]
> Status: Draft — pending review
> Version: 1.0

## 1. Executive Summary

[3-5 sentences: what system is being built, how many stories were derived,
the critical path through the dependency graph, and key implementation risks.]

## 2. Journal Overview

| Metric | Value |
|--------|-------|
| Total stories | [N] |
| User stories | [N] |
| Technical stories | [N] |
| Parallel groups | [N] (Groups A through [X]) |
| Foundation stories (no deps) | [N] |
| Critical path length | [N] stories |

### Parallel Groups Summary

| Group | Theme | Stories | Can start after |
|-------|-------|---------|----------------|
| Group A | Foundation & Setup | S-001, S-002, ... | Immediately |
| Group B | [Theme] | S-NNN, ... | Group A complete |
| ... | ... | ... | ... |

## 3. Stories

[Ordered list of all stories — each following the story format below.
Stories are ordered by dependency: no story appears before its dependencies.]

### S-001: [Title]
- **Type:** User | Technical
- **Depends on:** None
- **Parallel group:** Group A
- **Refs:** [requirement IDs, e.g., FR-AU-01, NFR-SE-01, ADR-01]
- **Architecture:** [reference if applicable, e.g., "Auth service — architecture.md §4.2"]

[2-3 sentence description of what this story delivers and why it matters.]

**Acceptance criteria:**
- [Criterion extracted from requirements — testable and specific]
- [Criterion]
- [Criterion]

**Status:** Not started

---

[...repeat for all stories, maintaining sequential S-NNN numbering...]

## 4. Traceability Matrix

[Maps every source requirement to the story that implements it.
Every FR, architecturally-significant NFR, and implementation-relevant ADR
must appear in this matrix.]

| Requirement ID | Story ID | Story Title |
|---------------|----------|-------------|
| FR-XX-## | S-NNN | [Title] |
| NFR-XX-## | S-NNN | [Title] |
| ADR-## | S-NNN | [Title] |

## 5. Open Questions & Risks

[Carried forward from spec documents — only items that affect story scope or ordering.
If no open questions affect stories, state "No open questions affect story scope."]

| Source ID | Question/Risk | Affected Stories | Impact |
|-----------|--------------|-----------------|--------|
| OQ-01 | [Question] | S-NNN, S-NNN | [What changes if resolved differently] |
```
