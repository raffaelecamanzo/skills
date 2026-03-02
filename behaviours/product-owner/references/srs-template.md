# Software Requirements Specification — Template

Use this template for the output file `docs/specs/software-spec.md`. This document synthesizes the FRS (`analyst-frs.md`), UAT (`analyst-UAT.md`), and NFR (`writer-nfr.md`) into a unified specification. Adapt sections based on relevance.

```markdown
# Software Requirements Specification — [System/Feature Name]

> Source: [link to or name of the analyzed request document]
> FRS: docs/specs/analyst-frs.md
> UAT: docs/specs/analyst-UAT.md
> NFR: docs/specs/writer-nfr.md
> Author: Product Owner (AI-assisted)
> Date: [generation date]
> Status: Draft — pending stakeholder review
> Version: 1.0

## 1. Executive Summary

[3-5 sentences: what was analyzed, the scope of the specification, key business capabilities, and the most critical quality attributes. This should give a reader the full picture without reading further.]

## 2. System Context

### 2.1 Purpose
[What problem does this system solve and for whom?]

### 2.2 Scope
**In scope:**
- [Functional area 1]
- [Functional area 2]

**Out of scope:**
- [Excluded area 1 — reason]
- [Excluded area 2 — reason]

### 2.3 Stakeholders & Actors

| Actor | Type | Description |
|-------|------|-------------|
| [Actor name] | Primary / Secondary / System | [Role and interaction] |

### 2.4 Constraints
- [Hard constraint — source: regulatory/business/technical]

### 2.5 Assumptions

| ID | Assumption | Source | Impact if Wrong | Validated? |
|----|-----------|--------|----------------|------------|
| AS-01 | [Assumption statement] | FRS / NFR / Scoping | [What breaks] | Yes / No |

## 3. Requirements by Functional Area

[Group related functional and non-functional requirements together by area. This is the SRS's key organizational contribution — showing FR and NFR side-by-side for each capability.]

### 3.1 [Functional Area Name] (e.g., User Authentication)

#### Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria | Source |
|----|-------------|----------|-------------------|--------|
| FR-[AA]-01 | [Requirement statement] | Must / Should / Could | [Testable criterion] | FRS §5.x |

#### Area-Specific Non-Functional Requirements

| ID | Requirement | Priority | Acceptance Criterion | Source |
|----|-------------|----------|---------------------|--------|
| NFR-[XX]-01 | [Requirement statement] | Must / Should / Could | [Measurable criterion] | NFR §X |

#### Business Rules
- [Rules specific to this area]

[Repeat section 3.x for each functional area]

## 4. Cross-Cutting Non-Functional Requirements

[NFRs that apply across all functional areas — not tied to a single capability.]

| ID | Requirement | Categories | Priority | Acceptance Criterion | Source |
|----|-------------|-----------|----------|---------------------|--------|
| NFR-CC-01 | [Requirement] | [Cat1, Cat2] | Must / Should / Could | [Criterion] | NFR §X |

## 5. Data Requirements

### 5.1 Data Entities

| Entity | Key Attributes | Constraints | Lifecycle |
|--------|---------------|-------------|-----------|
| [Entity name] | [Core attributes] | [Validation rules] | [Created → updated → archived/deleted] |

### 5.2 Data Validation Rules

| ID | Field/Entity | Rule | Error Handling |
|----|-------------|------|----------------|
| DV-01 | [Field] | [Rule] | [On failure] |

### 5.3 Data Management NFRs

| ID | Requirement | Priority | Acceptance Criterion | Source |
|----|-------------|----------|---------------------|--------|
| NFR-DM-01 | [Data-specific NFR] | Must / Should / Could | [Criterion] | NFR §X |

## 6. Interface Requirements

### 6.1 User Interfaces
- [Screen/component — key functional behaviors]

### 6.2 System Interfaces
- [Integration point — data exchanged, protocol, frequency]

### 6.3 Reporting Requirements

| ID | Report | Trigger | Content | Audience |
|----|--------|---------|---------|----------|
| RP-01 | [Report name] | [Trigger] | [Key data] | [Consumer] |

## 7. Conflict Resolutions

[This section documents every conflict identified during the PO's cross-reference review (Phase 3) and how it was resolved. This is the PO's unique value-add.]

| ID | Conflict | FR Reference | NFR Reference | Resolution | Rationale |
|----|----------|-------------|---------------|------------|-----------|
| CR-01 | [Description of conflict] | FR-XX-01 | NFR-XX-01 | [How it was resolved] | [Why this resolution] |

**Impact on requirements:**
- [CR-01: Requirement FR-XX-01 was modified to... / NFR-XX-01 was adjusted to...]

## 8. Risk Register

[Consolidated risks from both FRS and NFR perspectives.]

| ID | Risk | Source | Likelihood | Impact | Mitigation | Owner |
|----|------|--------|-----------|--------|------------|-------|
| RK-01 | [Risk description] | FRS / NFR / Review | High/Med/Low | High/Med/Low | [Mitigation strategy] | [TBD] |

## 9. Open Questions

[Consolidated from both sub-documents, deduplicated.]

| ID | Question | Source | Impacts | Owner | Due Date |
|----|----------|--------|---------|-------|----------|
| OQ-01 | [Question] | FRS / NFR / Review | [Affected requirements] | [Who] | [Date] |

## 10. Traceability Matrix

| Business Need | Functional Req | Non-Functional Req | UAT Test Case | Conflict Resolution |
|--------------|---------------|-------------------|---------------|-------------------|
| [BN-01] | FR-XX-01 | NFR-XX-01 | UAT-XX-01 | CR-01 (if applicable) |

## 11. Decision Log

[All decisions made during scoping, analysis, and review.]

| ID | Decision | Phase | Alternatives Considered | Rationale |
|----|----------|-------|------------------------|-----------|
| DL-01 | [What was decided] | Scoping / BA / Technical Writer / Review | [Options] | [Why] |

## 12. Source Document Summary

| Document | Path | Generated By | Key Content |
|----------|------|-------------|-------------|
| Functional Requirements Specification | docs/specs/analyst-frs.md | Business Analyst | FRs, business rules, data requirements |
| User Acceptance Test Cases | docs/specs/analyst-UAT.md | Business Analyst | Test cases, coverage matrix |
| Non-Functional Requirements | docs/specs/writer-nfr.md | Technical Writer | NFRs, trade-offs, risk register |
```

## Priority Definitions

- **Must**: System cannot go live without this. Core business capability or non-negotiable quality attribute.
- **Should**: Important for target experience. Expected for production release.
- **Could**: Enhances the system. Can be deferred without blocking launch.
