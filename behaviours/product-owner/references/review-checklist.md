# Cross-Reference Review Checklist

Use this checklist during Phase 3 to systematically cross-reference the FRS (`analyst-frs.md`), UAT (`analyst-UAT.md`), and NFR (`writer-nfr.md`) documents. Work through each category and document every finding.

---

## 1. FR-NFR Conflict Detection

Check for direct contradictions between functional and non-functional requirements.

### Performance vs. Functionality
- [ ] Do any FRs imply real-time behavior while NFRs specify eventual consistency?
- [ ] Do any FRs require complex computations that conflict with response time NFRs?
- [ ] Do batch processing FRs fit within the performance windows defined in NFRs?
- [ ] Do data volume assumptions in FRs align with scalability targets in NFRs?

### Security vs. Usability
- [ ] Do authentication FRs conflict with usability NFRs? (e.g., MFA friction vs. "seamless experience")
- [ ] Do data access FRs align with security NFRs on data classification and authorization?
- [ ] Do integration FRs expose data that security NFRs classify as restricted?

### Availability vs. Complexity
- [ ] Do availability NFRs (uptime targets) account for the deployment complexity implied by FRs?
- [ ] Do FRs with external dependencies conflict with reliability NFRs?
- [ ] Are failover requirements in NFRs compatible with stateful workflows in FRs?

### Cost vs. Quality
- [ ] Do cost NFRs allow for the infrastructure implied by performance/scalability NFRs?
- [ ] Do "nice-to-have" FRs conflict with strict resource constraints in NFRs?

---

## 2. Coverage Gap Analysis

Identify functional areas without NFR coverage and vice versa.

### FRs without NFR coverage
- [ ] For each functional area in the FRS, is there at least one relevant NFR category addressed?
- [ ] Do user-facing features have usability NFRs?
- [ ] Do data-intensive features have data management NFRs?
- [ ] Do integration features have reliability and security NFRs?
- [ ] Do features with business-critical workflows have availability NFRs?

### NFRs without functional context
- [ ] For each NFR, is it clear which functional areas it applies to?
- [ ] Are there generic NFRs that need to be made specific to functional areas?
- [ ] Are there NFR categories addressed that have no corresponding functionality? (may indicate scope creep)

### UAT gaps
- [ ] Does every Must-priority FR have at least one UAT test case?
- [ ] Do UAT test cases cover NFR-sensitive scenarios? (e.g., testing under load, testing access controls)
- [ ] Are there FRs in the traceability matrix with no test coverage?

---

## 3. Consistency Audit

Check for internal consistency across all three documents.

### Terminology
- [ ] Are the same concepts named consistently across FRS, NFR, and UAT? (e.g., "user" vs. "customer" vs. "account holder")
- [ ] Are actors named identically across documents?
- [ ] Are system components or modules named consistently?

### Assumptions
- [ ] Are assumptions in the FRS consistent with assumptions in the NFR doc?
- [ ] Are there contradictory assumptions between documents?
- [ ] Are "validated" assumptions in one document still marked "unvalidated" in another?

### Priorities
- [ ] Are requirements that are Must-priority in FRS also reflected as high-priority in related NFRs?
- [ ] Are there Should/Could FRs that depend on Must-priority NFRs (or vice versa)?

### Data and entities
- [ ] Are data entities described consistently across FRS data requirements and NFR data management sections?
- [ ] Do data validation rules in the FRS align with data integrity NFRs?

### Scope boundaries
- [ ] Do both documents agree on what is in scope and out of scope?
- [ ] Are there NFRs that reference functionality not covered in the FRS?
- [ ] Are there FRs that imply architectural constraints not captured in NFRs?

---

## 4. Completeness Check

Verify that the combined output is comprehensive.

### Business coverage
- [ ] Does the original request document have any stated or implied needs not covered by either FRS or NFR?
- [ ] Were all scoping decisions from Phase 1 honored? (nothing added or dropped without acknowledgment)

### Standard areas
- [ ] Error handling: FRs define user-facing errors, NFRs define system-level error handling — both present?
- [ ] Audit and logging: FRs define what's auditable, NFRs define how — both present?
- [ ] Notifications: FRs define triggers and content, NFRs define delivery guarantees — both present?
- [ ] Data lifecycle: FRs define CRUD, NFRs define retention/archival/backup — both present?

### Traceability
- [ ] Can every requirement in both documents be traced to the original request, a user answer, or an explicit assumption?
- [ ] Are open questions from both documents accounted for with clear ownership and impact?

---

## Severity Classification

When reporting findings, classify each by severity:

| Severity | Definition | Action |
|----------|-----------|--------|
| **Conflict** | Direct contradiction between FR and NFR — cannot implement both as written | Must resolve before SRS generation |
| **Gap** | Missing coverage — a functional area lacks NFR support or vice versa | Must acknowledge; fill or explicitly defer |
| **Inconsistency** | Same concept described differently — not contradictory but confusing | Should resolve for clarity |
| **Observation** | Minor issue or improvement opportunity | Note in SRS, resolve if time permits |
