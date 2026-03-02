# User Acceptance Test Cases — Template

Use this template for the output file `docs/specs/analyst-UAT.md`. Every test case must trace to at least one functional requirement from the FRS. Cover happy paths, alternative flows, boundary conditions, and negative scenarios.

```markdown
# User Acceptance Test Cases — [System/Feature Name]

> Source FRS: docs/specs/analyst-frs.md
> Author: Business Analyst (AI-assisted)
> Date: [generation date]
> Status: Draft — pending QA and stakeholder review
> Version: 1.0

## Test Plan Overview

### Scope
[Brief description of what these tests validate and the functional areas covered.]

### Test Environment Prerequisites
- [Environment requirement 1]
- [Test data requirement 1]
- [Access/permissions requirement 1]

### Test Execution Notes
- [Any sequencing dependencies between test cases]
- [Required test data setup instructions]

---

## [Functional Area Name] (e.g., User Authentication)

### UAT-[AA]-01: [Test Case Title — descriptive of scenario]

| Field | Value |
|-------|-------|
| **Traces to** | FR-[AA]-01, FR-[AA]-02 |
| **Priority** | Must / Should / Could |
| **Type** | Happy Path / Alternative Flow / Boundary / Negative / Edge Case |
| **Preconditions** | [System state before test begins] |

**Test Steps:**

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | [Specific user action] | [Observable, verifiable outcome] |
| 2 | [Next action] | [Expected outcome] |
| 3 | ... | ... |

**Postconditions:** [System state after successful test]

**Test Data:** [Specific data values needed, or reference to test data set]

---

### UAT-[AA]-02: [Test Case Title]

[Same structure as above]

---

[Repeat for each functional area]

## Cross-Functional Test Cases

### UAT-CF-01: [Test Case Title — tests behavior spanning multiple areas]

| Field | Value |
|-------|-------|
| **Traces to** | FR-XX-01, FR-YY-03 |
| **Priority** | Must / Should / Could |
| **Type** | Integration / End-to-End |
| **Preconditions** | [System state] |

**Test Steps:**

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | ... | ... |

---

## Coverage Matrix

| Functional Requirement | Test Case(s) | Coverage Status |
|----------------------|-------------|-----------------|
| FR-XX-01 | UAT-XX-01, UAT-XX-02 | Covered |
| FR-XX-02 | UAT-XX-03 | Covered |
| FR-XX-03 | — | GAP — needs test case |
```

## ID Convention

Mirror the FRS functional area codes:
- `UAT-AU-##` — Authentication & Authorization tests
- `UAT-UM-##` — User Management tests
- `UAT-DM-##` — Data Management tests
- `UAT-WF-##` — Workflow & Process tests
- `UAT-NT-##` — Notifications tests
- `UAT-RP-##` — Reporting tests
- `UAT-IN-##` — Integration tests
- `UAT-SR-##` — Search tests
- `UAT-CF-##` — Cross-Functional tests
- `UAT-XX-##` — Other (match FRS domain codes)

## Test Type Definitions

- **Happy Path**: Standard successful flow with valid inputs and expected conditions.
- **Alternative Flow**: Valid but non-primary path through the feature (e.g., different user role, optional step).
- **Boundary**: Tests at the edges of valid input ranges (min, max, just-inside, just-outside).
- **Negative**: Invalid inputs, unauthorized access, missing data — system must handle gracefully.
- **Edge Case**: Unusual but possible scenarios (concurrent actions, empty states, maximum data volumes).

## Coverage Standards

Every functional requirement from the FRS must have:
- At least 1 happy path test case
- At least 1 negative or boundary test case for requirements with input validation
- Edge case coverage for requirements flagged as high-risk or complex
