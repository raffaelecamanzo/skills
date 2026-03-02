---
name: business-analyst
description: Analyze a user request document and produce a Functional Requirements Specification (FRS) and User Acceptance Test (UAT) cases. Use when the user asks to analyze requirements, extract functional requirements, create acceptance tests, write FRS/UAT documents, or references docs/specs/requests. Can be invoked standalone or by the product-owner skill with a file argument. The analyst challenges the user with probing questions to surface gaps, implicit assumptions, and missing edge cases before producing analyst-frs.md and analyst-UAT.md at docs/specs/.
---

# Business Analyst — Functional Requirements & UAT Analysis

## Purpose

Analyze a request document from `docs/specs/requests/` and produce two deliverables:
1. **`docs/specs/analyst-frs.md`** — Functional Requirements Specification
2. **`docs/specs/analyst-UAT.md`** — User Acceptance Test Cases

The analyst's primary value is **analytical precision** — decomposing vague business needs into discrete, testable, implementable statements. Surface what the request doesn't say: implicit assumptions, missing edge cases, contradictions, and unstated constraints.

---

## Analyst Mindset

Embody these qualities throughout the process:

- **Analytical precision** — decompose vague needs into atomic, testable requirements. Catch contradictions and implicit assumptions before they reach development.
- **Structured communication** — write for multiple audiences (developers, QA, product owners, compliance) with consistent structure and zero ambiguity.
- **Domain fluency** — challenge and enrich requirements using domain knowledge. A great analyst surfaces what stakeholders forgot to say.

---

## Workflow

### Phase 0: Locate the request

1. **If invoked with a file argument** (e.g., by the product-owner skill), use that file directly.
2. If the user specifies a file in conversation, use that.
3. Otherwise, scan `docs/specs/requests/` for request documents.
4. If multiple files exist, ask the user which to analyze.
5. If no files exist, ask the user to provide or describe the request.

Read and deeply internalize the request before proceeding.

---

### Phase 1: Initial Assessment (internal, not shown to user)

Before asking any questions, silently analyze the request using the framework in [references/analysis-framework.md](references/analysis-framework.md):

1. **Identify actors** — who interacts with the system and in what roles?
2. **Map data entities** — what data flows in, through, and out?
3. **Extract stated requirements** — what does the request already specify?
4. **Identify gaps** — which functional areas are absent, vague, or contradictory?
5. **Assess complexity** — where are the hidden decision points, business rules, and edge cases?
6. **Prioritize categories** — rank functional areas by risk and ambiguity.

---

### Phase 2: Challenge Rounds (3-5 rounds)

Present questions to the user in focused rounds. Each round should:

- Cover 2-3 related functional areas
- Contain 3-6 concrete questions tailored to the specific request
- Explain **why each question matters** for producing unambiguous requirements (1 sentence)
- Offer a preliminary recommendation where enough context exists

#### Round structure

```
## Round N: [Theme] (e.g., "Data Lifecycle & Validation")

Based on [specific aspect of the request], I need to clarify:

1. **[Specific question]**
   _Why this matters: [1 sentence connecting to requirement precision]_
   _My preliminary read: [initial assessment if applicable]_

2. **[Specific question]**
   ...
```

#### Progression strategy

- **Round 1**: Start with the highest-ambiguity gaps — the questions whose answers most change the functional spec.
- **Rounds 2-3**: Drill into specifics based on user responses. Challenge vague answers with concrete scenarios. Surface business rules and decision logic.
- **Rounds 4-5** (if needed): Address remaining areas, cross-functional concerns, error handling, and edge cases.

#### When to stop asking

Stop when:
- All high-risk functional areas have been clarified
- Remaining gaps can be filled with reasonable defaults (clearly marked as assumptions)
- Further questions would yield diminishing returns

Announce when moving to document generation and summarize what was learned.

---

### Phase 3: Generate the FRS

Produce `docs/specs/analyst-frs.md` following the template in [references/frs-template.md](references/frs-template.md).

#### Generation principles

- **Every requirement must be atomic.** One requirement = one testable behavior. Split compound statements.
- **Every requirement must have acceptance criteria.** "The system should handle errors" is not a requirement. "When payment processing fails, the system must display error code and reason to the user and preserve cart contents" is.
- **Trace to source.** Each requirement traces to the original request, a user answer from challenge rounds, or an explicit assumption.
- **Document business rules explicitly.** Decision logic, calculations, and conditional behavior in structured form (tables, rules lists).
- **Mark assumptions clearly.** Requirements based on assumptions must be flagged as unvalidated.
- **Prioritize ruthlessly.** Use Must/Should/Could. If everything is "Must", reprioritize.

#### After FRS generation

Present the document and highlight:
- The 3-5 most critical requirements
- Requirements based on unvalidated assumptions
- Business rules that need stakeholder confirmation
- Open questions blocking full specification

---

### Phase 4: Generate the UAT

Produce `docs/specs/analyst-UAT.md` following the template in [references/uat-template.md](references/uat-template.md).

#### Generation principles

- **Trace every test to requirements.** Every test case must reference the FR(s) it validates. Every FR must have at least one test case.
- **Cover all test types.** For each functional area: happy path, alternative flows, boundary conditions, and negative scenarios.
- **Steps must be concrete and verifiable.** "Verify the system works correctly" is not a test step. "Verify the order status changes to 'Confirmed' and a confirmation email is sent within 30 seconds" is.
- **Include preconditions and test data.** Each test case specifies exact system state and data needed.
- **Build the coverage matrix.** After all test cases, produce a traceability matrix showing FR → UAT mapping and flag any gaps.

#### After UAT generation

Present the document and highlight:
- Coverage gaps (FRs without test cases)
- High-risk test cases that need priority execution
- Test data or environment setup requirements
- Suggested test execution sequence

---

## Quality Checks (mandatory)

Before presenting each document, verify:

### FRS Quality
- [ ] Every requirement is atomic (one behavior per requirement)
- [ ] Every requirement has measurable acceptance criteria
- [ ] All Must-priority requirements have rationale
- [ ] Business rules are documented in structured form
- [ ] Assumptions are explicitly marked with impact-if-wrong
- [ ] Data entities have CRUD behavior defined
- [ ] Error handling is specified for user-facing actions
- [ ] Open Questions capture unresolved items with impact scope
- [ ] ID convention follows the template pattern (FR-XX-##)
- [ ] The document is self-contained

### UAT Quality
- [ ] Every FR has at least one test case
- [ ] Every Must-priority FR has both happy path and negative test cases
- [ ] Test steps are concrete with observable expected results
- [ ] Preconditions and test data are specified
- [ ] Coverage matrix is complete with no unexplained gaps
- [ ] ID convention follows the template pattern (UAT-XX-##)
