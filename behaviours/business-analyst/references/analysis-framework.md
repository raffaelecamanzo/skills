# Analysis Framework — Functional Decomposition

Use this framework to systematically analyze a request document and identify gaps. Work through each lens to ensure comprehensive coverage.

## 1. Actor Analysis

**Core concern:** Who interacts with the system and what are their distinct needs?

**Probing questions:**
- Who are all the actors? (end users, admins, system integrations, background processes)
- What distinguishes each actor's permissions and capabilities?
- Are there actor transitions? (e.g., unauthenticated → authenticated → admin)
- What happens when an actor's role changes mid-process?
- Are there delegation or impersonation scenarios?

## 2. Data Lifecycle

**Core concern:** What data flows in, through, and out of the system?

**Probing questions:**
- What entities does the system manage? What are their core attributes?
- What creates each entity? What modifies it? What deletes/archives it?
- What validation rules apply at each lifecycle stage?
- Are there state machines governing entity transitions?
- What happens to related data when a parent entity is deleted?
- What data must be preserved for audit, compliance, or rollback?

## 3. Business Rules & Decision Logic

**Core concern:** What conditional logic governs system behavior?

**Probing questions:**
- What business rules constrain operations? (e.g., "orders over $10K require approval")
- Are there time-based rules? (deadlines, SLAs, expiration, business hours)
- What calculation or derivation rules exist? (pricing, scoring, eligibility)
- When rules conflict, which takes precedence?
- Are rules configurable by users/admins, or hardcoded?
- What exceptions to the rules exist and who can invoke them?

## 4. Process & Workflow

**Core concern:** What multi-step processes does the system support?

**Probing questions:**
- What are the end-to-end workflows? (happy path start → finish)
- What are the alternative paths? (branches, optional steps, shortcuts)
- What are the error/exception paths? (what can go wrong at each step?)
- Can processes be paused, resumed, cancelled, or reversed?
- Are there parallel or concurrent steps?
- What notifications or escalations trigger at each step?
- What happens if a process stalls? (timeouts, reminders, auto-escalation)

## 5. Integration Points

**Core concern:** How does the system interact with external systems?

**Probing questions:**
- What systems send data to this system? In what format and frequency?
- What systems receive data from this system?
- What happens when an integration is unavailable? (retry, queue, degrade?)
- Are there data transformation or mapping requirements?
- Who owns the contract? What happens when the external system changes?

## 6. Error Handling & Edge Cases

**Core concern:** How does the system behave when things go wrong?

**Probing questions:**
- What error messages does the user see? Are they actionable?
- What happens on partial failure? (3 of 5 items succeed)
- What concurrency scenarios exist? (two users editing the same record)
- What happens at data boundaries? (empty lists, maximum volumes, zero values)
- How are duplicate submissions handled?
- What happens when a prerequisite condition is no longer valid mid-process?

## 7. Reporting & Visibility

**Core concern:** What information does the system surface for decision-making?

**Probing questions:**
- What do users need to see to do their job? (dashboards, lists, search results)
- What management or compliance reports are needed?
- Are there real-time vs. batch reporting needs?
- What filtering, sorting, and export capabilities are required?
- Who can see what? (data visibility rules by role)

## 8. Notifications & Communication

**Core concern:** How does the system proactively inform users?

**Probing questions:**
- What events trigger notifications?
- What channels? (email, SMS, in-app, push)
- Are notifications configurable by the user? (opt-in, opt-out, frequency)
- What is the notification content and who is the audience?
- What happens if notification delivery fails?

## Completeness Checklist

Before generating the FRS, verify:
- [ ] Every actor has at least one functional requirement
- [ ] Every data entity has create, read, update, and delete behavior defined (or explicitly excluded)
- [ ] Every business rule has an exception path or explicit "no exceptions" statement
- [ ] Every workflow has a happy path, at least one alternative flow, and error handling
- [ ] Every integration point has a failure/unavailability scenario
- [ ] Every user-facing action has an error message or feedback specification
- [ ] Every "the system should..." statement has been converted to a measurable requirement
