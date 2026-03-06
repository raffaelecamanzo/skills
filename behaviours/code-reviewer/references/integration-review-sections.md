# Integration Review Sections

Templates for the story-level and sprint-level sections appended to `docs/planning/sprints/sprint-impl-N.md`. These sections provide human-facing guidance on how to review and test the integrated work.

---

## Story-Level Section

Append this section to `sprint-impl-N.md` after verifying cross-task coherence within a story. Place it after the last task section belonging to the story.

```markdown
---

### S-NNN / [Story Title] — Story Review

**Coherence status:** Clean | Issues resolved (see below)

**Issues found and resolved:**
- [Description of cross-task conflict or unwanted interaction, how it was resolved, and which files were changed]
- Or: "No cross-task issues found"

**How to review this story (human checklist):**
1. [Specific verification step — e.g., "Start the service and confirm endpoint X returns Y when called with Z"]
2. [Step that exercises the interaction between tasks — e.g., "Create a resource via the API, then verify it appears in the listing with correct metadata"]
3. [Boundary/negative case — e.g., "Submit an invalid payload and confirm the error response matches the spec format"]
4. [End-to-end flow if applicable — e.g., "Walk through the full user journey: create → read → update → delete"]

**How to test this story:**
- **Automated:** `[command to run relevant test suite, e.g., go test ./pkg/auth/... -v]`
- **Manual steps:**
  1. [Concrete manual test step with expected outcome]
  2. [Step that specifically tests cross-task integration points]
- **What to look for:** [Key behaviors or outputs that confirm the story works correctly as a whole]

---
```

## Sprint-Level Section

Append this section to `sprint-impl-N.md` after all stories in the sprint have been story-reviewed. Place it at the end of the document, after all task and story sections.

```markdown
---

## Sprint N — Sprint Review

**Sprint coherence status:** Clean | Issues resolved (see below)

**Cross-story issues found and resolved:**
- [Description of cross-story conflict or unwanted interaction, how it was resolved, and which files were changed]
- Or: "No cross-story issues found"

**How to review this sprint (human checklist):**
1. [High-level verification — e.g., "Deploy the full sprint increment and verify the service starts without errors"]
2. [Cross-story interaction — e.g., "Verify that the new authentication from S-001 correctly gates the resources from S-003"]
3. [Integration boundary — e.g., "Confirm that error responses from the new validation layer propagate correctly through the existing middleware"]
4. [Regression check — e.g., "Run the full existing test suite to confirm no regressions from the sprint changes"]

**How to test this sprint:**
- **Automated:** `[command to run the full test suite, e.g., go test ./... -v -race]`
- **Manual integration test:**
  1. [End-to-end test step covering the sprint's combined functionality]
  2. [Step that exercises cross-story boundaries]
- **Deployment notes:** [Any environment setup, migrations, config changes, or feature flags needed before testing]
- **What to look for:** [Key behaviors that confirm the sprint increment works as an integrated whole]

---
```

## Guidelines

- **Be specific** — every review/test step must reference concrete endpoints, commands, inputs, and expected outputs. "Test that it works" is not a step.
- **Focus on integration** — individual task correctness was already verified. Story/sprint sections focus on how tasks/stories interact.
- **Include both automated and manual** — provide the exact commands for automated verification, plus manual steps for behaviors that require human judgment.
- **Resolve before documenting** — if coherence issues are found, fix them first, then document what was fixed. The section records the clean state, not a list of outstanding problems.
