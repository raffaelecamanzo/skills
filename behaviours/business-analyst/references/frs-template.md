# Functional Requirements Specification — Template

Use this template for the output file `docs/specs/analyst-frs.md`. Adapt sections based on relevance. Every requirement must have clear acceptance criteria and traceability.

```markdown
# Functional Requirements Specification — [System/Feature Name]

> Source: [link to or name of the analyzed request document]
> Author: Business Analyst (AI-assisted)
> Date: [generation date]
> Status: Draft — pending stakeholder review
> Version: 1.0

## 1. Executive Summary

[2-3 sentences: what was analyzed, the scope of functional coverage, and the key business capabilities being specified.]

## 2. Scope & Boundaries

### In Scope
- [Functional area 1]
- [Functional area 2]

### Out of Scope
- [Explicitly excluded area 1 — reason]
- [Explicitly excluded area 2 — reason]

### Dependencies
- [External system/service dependency — nature of dependency]

## 3. Stakeholders & Actors

| Actor | Type | Description |
|-------|------|-------------|
| [Actor name] | Primary / Secondary / System | [Role and interaction with the system] |

## 4. Business Rules

| ID | Rule | Source | Exceptions |
|----|------|--------|------------|
| BR-01 | [Business rule statement] | [Stakeholder / regulation / policy] | [Exception conditions, if any] |

## 5. Functional Requirements

### 5.1 [Functional Area Name] (e.g., User Authentication)

| ID | Requirement | Priority | Acceptance Criteria | Source | Dependencies |
|----|-------------|----------|-------------------|--------|--------------|
| FR-[AA]-01 | [Clear, atomic requirement statement] | Must / Should / Could | [Measurable, testable criterion] | [Request doc / challenge round / assumption] | [Related FR IDs] |
| FR-[AA]-02 | ... | ... | ... | ... | ... |

**Processing Rules:**
- [Rule 1: specific input → processing → output behavior]
- [Rule 2: ...]

**Business Constraints:**
- [Constraint that limits implementation options]

[Repeat section 5.x for each functional area]

## 6. Data Requirements

### 6.1 Data Entities

| Entity | Key Attributes | Constraints | Lifecycle |
|--------|---------------|-------------|-----------|
| [Entity name] | [Core attributes] | [Validation rules, uniqueness, etc.] | [Created when → updated when → archived/deleted when] |

### 6.2 Data Validation Rules

| ID | Field/Entity | Rule | Error Handling |
|----|-------------|------|----------------|
| DV-01 | [Field] | [Validation rule] | [What happens on validation failure] |

## 7. Interface Requirements

### 7.1 User Interfaces
- [Screen/component — key functional behaviors expected]

### 7.2 System Interfaces
- [Integration point — data exchanged, protocol, frequency]

### 7.3 Reporting Requirements
| ID | Report | Trigger | Content | Audience |
|----|--------|---------|---------|----------|
| RP-01 | [Report name] | [On-demand / scheduled / event] | [Key data points] | [Who consumes it] |

## 8. Assumptions & Decisions

### Assumptions
| ID | Assumption | Impact if Wrong | Validated? |
|----|-----------|----------------|------------|
| AS-01 | [Assumption statement] | [What breaks] | Yes / No |

### Decisions
| ID | Decision | Alternatives Considered | Rationale |
|----|----------|------------------------|-----------|
| DE-01 | [What was decided] | [Options explored] | [Why this option] |

## 9. Open Questions

| ID | Question | Impacts | Owner | Due Date |
|----|----------|---------|-------|----------|
| OQ-01 | [Unresolved question] | [Which FRs are affected] | [Who should answer] | [Target date] |

## 10. Traceability Matrix

| Business Need | Functional Requirement(s) | UAT Test Case(s) |
|--------------|--------------------------|-------------------|
| [BN-01: description] | FR-XX-01, FR-XX-02 | UAT-XX-01, UAT-XX-02 |
```

## ID Convention

Use this pattern for requirement IDs:
- `FR-AU-##` — Authentication & Authorization
- `FR-UM-##` — User Management
- `FR-DM-##` — Data Management
- `FR-WF-##` — Workflow & Process
- `FR-NT-##` — Notifications
- `FR-RP-##` — Reporting
- `FR-IN-##` — Integration
- `FR-SR-##` — Search
- `FR-CF-##` — Configuration
- `FR-XX-##` — Other (use domain-specific 2-letter codes as appropriate)

For business rules: `BR-##`
For data validation: `DV-##`
For assumptions: `AS-##`
For decisions: `DE-##`
For open questions: `OQ-##`

## Priority Definitions

- **Must**: System cannot go live without this. Core business capability.
- **Should**: Important for target user experience. Expected for production release.
- **Could**: Enhances the system. Can be deferred without blocking launch.
