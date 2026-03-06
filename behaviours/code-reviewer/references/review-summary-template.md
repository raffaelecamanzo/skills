# Review Summary Template

Use this template when writing `docs/planning/sprints/sprint-review-N.md`. The review summary must be self-contained — the builder must be able to act on every finding without re-reading specs or re-analyzing code.

```markdown
> Source: Sprint N Review
> Author: Code Reviewer (AI-assisted)
> Date: [generation date]
> Status: Draft — pending builder action
> Version: 1.0

# Sprint N — Review Summary

## Overview

| Metric | Count |
|--------|-------|
| Tasks reviewed | N |
| Approved | N |
| Changes needed | N |
| Must-fix findings | N |
| Should-fix findings | N |

---

## [Story ID] / [Task Title]

**Verdict:** Changes needed | Approved (with recommendations)

### Must-Fix Issues

| # | Agent | Category | File | Location | Finding | Expected | Suggested Action |
|---|-------|----------|------|----------|---------|----------|------------------|
| 1 | Spec Compliance | Criterion coverage | `path/to/file.go` | Line 47 / `FuncName` | [What is wrong — specific and factual] | [What should be true — cite requirement or ADR] | [Concrete action — exact change to make] |

### Should-Fix Issues

| # | Agent | Category | File | Location | Finding | Expected | Suggested Action |
|---|-------|----------|------|----------|---------|----------|------------------|
| 1 | Simplification | Duplication | `path/to/file.go` | Lines 30-45 | [What is wrong] | [What should be true] | [Concrete action] |

---

<!-- Repeat ## [Story ID] / [Task Title] section for each reviewed task -->
```

## ID Convention

Findings are numbered sequentially per task section, starting at 1. No cross-document ID scheme — findings are scoped to their task section.

## Append-Only Rules

1. **Never overwrite** an existing review section. When re-reviewing, append a new section below the existing one.
2. **Re-review heading format:** `## [Story ID] / [Task Title] — Re-review #N` where N starts at 1 and increments.
3. **Re-reviews reference prior findings:** if a must-fix from a previous review is now resolved, state "Previously #3 (must-fix) — resolved" in the re-review section. Do not modify the original section.
4. **Version increment:** bump the version in the header block on each append (1.0 → 1.1 → 1.2).
5. **Update the Overview table** to reflect cumulative totals across all review rounds.

## Priority Definitions

- **Must-fix** — blocks approval. Correctness, security, or compliance issue that must be resolved before the task can be approved.
- **Should-fix** — recommended improvement. Does not block approval but would improve the implementation. Builder may defer with justification.
