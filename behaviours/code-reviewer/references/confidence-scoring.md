# Confidence Scoring Rubric

Every finding from the review agents must pass through this scoring rubric before it can survive to the verdict. The goal is to eliminate false positives, speculative concerns, and vague commentary — only evidence-based, impactful, actionable findings reach the builder.

## Scoring Dimensions

Total score: 0-100, composed of three dimensions.

### Evidence Strength (0-40)

How specific and verifiable is the finding?

| Score | Criteria |
|-------|----------|
| 36-40 | Cites specific file, line number, and the exact requirement/ADR it violates. Verifiable by reading the cited locations. |
| 26-35 | Cites file and function but requirement link is indirect or implied. |
| 16-25 | Cites file but location is approximate. Requirement connection requires interpretation. |
| 6-15 | General observation about a module or pattern. No specific line reference. |
| 0-5 | Speculative concern with no concrete code reference. |

### Impact Magnitude (0-30)

What is the real-world consequence if this finding is ignored?

| Score | Criteria |
|-------|----------|
| 25-30 | Production bug, security vulnerability, data loss, or silent correctness failure. |
| 18-24 | Functional issue that would surface in testing or specific user flows. Compliance violation against a stated requirement. |
| 10-17 | Maintainability issue that increases future bug risk or slows development. |
| 4-9 | Style or convention inconsistency with no functional consequence. |
| 0-3 | Cosmetic preference with no measurable impact. |

### Actionability (0-30)

How concrete is the suggested fix?

| Score | Criteria |
|-------|----------|
| 25-30 | Specifies exact file, location, and the concrete change to make. Builder can act immediately. |
| 18-24 | Specifies file and general approach but leaves some implementation detail to the builder. |
| 10-17 | Identifies the problem area but the fix requires investigation or design work. |
| 4-9 | Suggests a direction ("consider refactoring") without specifics. |
| 0-3 | Vague concern with no suggested action ("this could be improved"). |

## Threshold

**Findings scoring >= 75 survive. All others are discarded.**

This threshold requires strong performance across all three dimensions — a finding cannot survive on evidence alone if it has no impact, and a high-impact concern cannot survive without evidence to back it.

## Severity Classification

Surviving findings (>= 75) are classified into two severity levels:

### Must-Fix

A finding is must-fix if ANY of these conditions are true:
- Total score >= 85
- Impact category is production bug, security vulnerability, or correctness failure (impact score >= 25) regardless of total score
- Finding represents a compliance violation against an explicit acceptance criterion

### Should-Fix

A finding is should-fix if:
- Total score is 75-84 AND
- Impact category is NOT production bug, security, or correctness AND
- Finding is NOT a compliance violation against an explicit acceptance criterion

## Edge Cases

### Duplicate Findings Across Agents

When multiple agents flag the same issue (same file, same location, same root cause):
1. Keep the finding with the highest total score
2. Discard the others
3. Note in the surviving finding which agents independently identified it (strengthens confidence)

### Conflicting Findings Between Agents

When two agents reach opposite conclusions about the same code (e.g., Agent 3 says error handling is incorrect, Agent 2 says it follows the architecture's error strategy):
1. Keep both findings
2. Flag the conflict explicitly in the review summary
3. Present both perspectives for user judgment
4. Do not attempt to resolve the conflict — the reviewer identifies, the builder decides

### Borderline Scores (73-76)

When a finding scores in the 73-76 range:
1. Re-evaluate the finding once against all three dimensions
2. If the score remains below 75 after re-evaluation, discard it
3. If the score rises to 75 or above, it survives
4. Principle: when in doubt, discard. A false negative (missed real issue) is correctable; a false positive (noisy finding) erodes trust in the review process.
