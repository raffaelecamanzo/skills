---
name: marp-deck-workflow
description: End-to-end workflow to build a MARP deck from definition → plan → visuals (including Mermaid diagrams) → final deck → visual QA on rendered PDF. Use as the single entry point to generate/refresh all artifacts deterministically.
---

# Marp Deck Workflow Orchestrator

## Purpose

Single entry point that executes the full deck pipeline in order:

1) Plan the deck
2) Design visuals + generate Mermaid diagrams
3) Generate the final MARP deck
4) Render PDF and run visual QA (auto-fix loop via deck-gen if flaws found)

This orchestrator must be deterministic and stop on mismatches instead of guessing.

---

## Inputs (mandatory)

- `definition/deck-definition.md`
- `references/deck-template.md`

## Outputs (generated/updated)

- `planning/deck-plan.md`
- `planning/deck-visual-design.md`
- `diagrams/*.mmd` (as needed)
- `assets/*.png` (generated from Mermaid)
- `slides/deck.md`
- `slides/deck-notes.md`
- `output/<slugified-title>_<date>.pdf` (from `task pdf`)
- `themes/deck-theme.css` (only if unavoidable and explicitly required)

---

## Workflow

### Phase 0 — Preconditions

- Verify `definition/deck-definition.md` exists
- Verify `references/deck-template.md` exists
- If missing: stop and report exact missing paths

Style preferences (required for consistent output):
- Check `definition/deck-definition.md` for an explicit style choice:
  - Cover variant: `cover-1` .. `cover-6`
  - Section variant: `section-1` .. `section-5`
- If missing, ask the user to choose (or accept defaults), then update `definition/deck-definition.md` to record:
  - `Style preferences: cover=cover-<n>, section=section-<n>`

---

### Phase 1 — Deck planning (planner behavior)

Goal: produce `planning/deck-plan.md` as a planning artifact only.

Rules:
- Extract deck title, sections, key messages, constraints
- Create 1–3 intro slides if needed
- For each section: section divider + 2–5 slides
- Ensure every key message appears at least once
- Do not generate diagrams or Mermaid
- `## Image` (if present) must be descriptive only

Output:
- Write `planning/deck-plan.md`

Hard gate:
- If any section has no slides planned: stop

---

### Phase 2 — Visual design + Mermaid generation (designer behavior)

Goal: produce `planning/deck-visual-design.md` and diagram assets.

Rules:
- Slide order must match `planning/deck-plan.md` exactly
- For each slide: Layout + Content placement (+ Visual design if planned)
- When Visual design is diagrammatic:
  - Create `diagrams/<diagramname>.mmd` (minimal and readable)
  - Render with `task mermaid-file FILE=diagrams/<diagramname>.mmd` (or `task mermaid` to rebuild all)
  - Run `task mermaid-check-file FILE=diagrams/<diagramname>.mmd` and adjust the `.mmd` if the output is too flat/tall
  - Reference as `assets/<diagramname>.png` inside `planning/deck-visual-design.md`
  - Choose slide class first, then design the diagram to fit (`visual-split` by default; add `image-wide` / `image-tall` based on validated aspect ratio)

Hard gates:
- If slide count/order mismatches plan: stop
- If a planned diagram cannot be expressed minimally: stop and report

Outputs:
- `planning/deck-visual-design.md`
- `diagrams/*.mmd`
- `assets/*.png` (from Mermaid)

---

### Phase 3 — Deck generation (generator behavior)

Goal: generate `slides/deck.md` and `slides/deck-notes.md` deterministically.

Rules:
- Authority order:
  1) `references/deck-template.md`
  2) `planning/deck-visual-design.md`
  3) `planning/deck-plan.md`
  4) `definition/deck-definition.md`
- Keep frontpage and closing structure unchanged (frontpage cover variant may be applied)
- Insert user slides between them
- Layout mapping must comply with template
- Visual placement rules:
  - If image is inside HTML layout containers: use `<img src="../assets/...">`
  - If image is standalone (no HTML wrapper): Markdown `![](../assets/...)` allowed
- Do not invent new slides or content

Outputs:
- `slides/deck.md`
- `slides/deck-notes.md`
- `themes/deck-theme.css` only if strictly required and justified

Hard gates:
- If any referenced asset is missing: stop
- If no template mapping exists for a layout: stop

---

### Phase 4 — Visual QA (checker behavior)

Goal: detect rendering and layout flaws in the rendered PDF and fix them.

Steps:
1. Run `task pdf` to produce the PDF.
2. Invoke `marp-deck-checker` via Skill tool.
3. The checker reads the PDF page-by-page and evaluates each slide against 12 flaw categories.

Output:
- **PASS**: inline message only, no file written — pipeline complete.
- **FLAWS FOUND**: checker invokes `marp-deck-gen` with a targeted fix prompt (layout/structure fixes only; content shortened only as a last resort for unresolvable overflow).

Feedback loop:
- If `marp-deck-gen` was invoked: re-run `task pdf`, then re-invoke `marp-deck-checker` to confirm fixes.
- Repeat until PASS.

Hard gate:
- Do not claim pipeline completion until the checker reports PASS.

---

## Non-goals

- No background execution
- No partial guessing when artifacts disagree
- No diagram generation unless visual design calls for it
- No aesthetic changes not justified by template rules

This orchestrator is the single entry point for the deck pipeline.
