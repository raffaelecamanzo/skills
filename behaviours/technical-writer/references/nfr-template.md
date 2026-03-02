# NFR Document Template

Use this template for the output file `docs/specs/writer-nfr.md`. Adapt sections based on relevance — omit categories that genuinely don't apply. Every included requirement must have a measurable acceptance criterion.

```markdown
# Non-Functional Requirements — [System/Feature Name]

> Source: [link to or name of the analyzed request document]
> Author: Technical Writer (AI-assisted)
> Date: [generation date]
> Status: Draft — pending stakeholder review

## Executive Summary

[2-3 sentences: what was analyzed, key quality concerns identified, and the most critical quality attributes for this system.]

## Context & Assumptions

### System Context
[Brief description of the system's purpose, boundaries, and role within the broader landscape.]

### Key Assumptions
- [Assumption 1 — validated/unvalidated]
- [Assumption 2 — validated/unvalidated]

### Constraints
- [Hard constraint 1 — source: regulatory/business/technical]
- [Hard constraint 2 — source]

---

## Non-Functional Requirements

### [Category Name] (e.g., Performance & Efficiency)

| ID | Requirement | Priority | Acceptance Criterion | Rationale |
|----|-------------|----------|---------------------|-----------|
| NFR-XX-01 | [Concise requirement statement] | Must / Should / Could | [Measurable criterion] | [Why this matters] |
| NFR-XX-02 | ... | ... | ... | ... |

**Trade-offs & Decisions:**
- [Explicit trade-off: e.g., "Chose eventual consistency over strong consistency to support horizontal scaling — acceptable for this use case because..."]

[Repeat for each relevant NFR category]

---

## Cross-Cutting Concerns

[Requirements that span multiple categories — e.g., "All services must emit structured logs that include correlation IDs" touches both Operability and Security.]

| ID | Requirement | Categories | Priority | Acceptance Criterion |
|----|-------------|-----------|----------|---------------------|
| NFR-CC-01 | ... | [Cat1, Cat2] | ... | ... |

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|-----------|--------|------------|-------|
| [Risk description] | High/Med/Low | High/Med/Low | [Mitigation strategy] | [TBD] |

---

## Open Questions

[Questions that emerged during analysis but remain unresolved. These block finalizing specific NFRs.]

1. [Question — impacts NFR-XX-XX]
2. [Question — impacts NFR-XX-XX]

---

## Appendix: Decision Log

| Decision | Context | Alternatives Considered | Rationale |
|----------|---------|------------------------|-----------|
| [What was decided] | [Why it came up] | [What else was considered] | [Why this option won] |
```

## ID Convention

Use this pattern for requirement IDs:
- `NFR-PE-##` — Performance & Efficiency
- `NFR-SC-##` — Scalability
- `NFR-RA-##` — Reliability & Availability
- `NFR-SE-##` — Security
- `NFR-MA-##` — Maintainability
- `NFR-UX-##` — Usability & Developer Experience
- `NFR-PC-##` — Portability & Compatibility
- `NFR-OO-##` — Operability & Observability
- `NFR-CR-##` — Compliance & Regulatory
- `NFR-DM-##` — Data Management
- `NFR-CE-##` — Cost & Resource Efficiency
- `NFR-CC-##` — Cross-Cutting Concerns

## Priority Definitions

- **Must**: System cannot launch without this. Non-negotiable.
- **Should**: Significant risk or degraded experience without this. Expected for production.
- **Could**: Desirable improvement. Can be deferred to a later phase.
