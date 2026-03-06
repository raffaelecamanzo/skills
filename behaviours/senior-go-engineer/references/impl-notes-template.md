# Implementation Notes Template

Use this template for the output file `docs/planning/sprints/sprint-impl-N.md`. This document records implementation decisions and outcomes for a sprint. It is append-only — each completed task adds a new section.

```markdown
# Sprint N: Implementation Notes

> Sprint: docs/planning/sprints/sprint-N.md
> Source: docs/specs/software-spec.md, docs/specs/architecture.md
> Author: Senior Go Engineer (AI-assisted)
> Date: [date of first entry]
> Status: In progress
> Version: 1.0

## Summary

| Metric | Value |
|--------|-------|
| Tasks completed | [N] / [total] |
| Files created | [N] |
| Files modified | [N] |
| Tests added | [N] |

---

### S-NNN / [Task title]

**Files changed:**
- `path/to/new_file.go` — [one-line description]
- `path/to/modified_file.go` — [what changed and why]
- `path/to/new_file_test.go` — [test description]

**Decisions:**
- [Key implementation choice with rationale]
- [Alternative considered and why it was rejected, if notable]

**Tests:**
- [What was tested: unit, integration, fuzz, benchmark]
- [Notable edge cases covered]
- [Test execution results: pass count, race detector status]

**Security:**
- [What was addressed: input validation, auth checks, etc.]
- Or: "No security surface for this task"

**Limitations:**
- [Deferred items or known constraints]
- Or: "None"

---

[...append additional task sections as they are completed...]
```

## Maintenance Rules

- **Append only** — never remove or rewrite previous task sections.
- **Update the summary table** after each task completion.
- **Change status** to "Complete" when all sprint tasks are implemented.
- **Date** reflects the first entry; do not update it as tasks are added.
