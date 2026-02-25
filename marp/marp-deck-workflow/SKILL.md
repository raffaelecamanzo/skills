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

### Phase 1 — Deck planning

Goal: produce `planning/deck-plan.md`.

1. Invoke `marp-deck-planner` via Skill tool.
2. Gate: verify `planning/deck-plan.md` exists and contains at least one section divider.
3. If gate fails: stop and report.

---

### Phase 2 — Visual design + Mermaid/Excalidraw generation

Goal: produce `planning/deck-visual-design.md` and all diagram assets.

1. Invoke `marp-deck-visual-designer` via Skill tool.
2. Gate:
   - `planning/deck-visual-design.md` exists
   - Slide count and order match `planning/deck-plan.md`
   - Every `## Image` reference in the visual design points to an existing file in `assets/`
3. If any gate fails: stop and report exact mismatch.

---

### Phase 3 — Deck generation

Goal: produce `slides/deck.md` and `slides/deck-notes.md`.

1. Invoke `marp-deck-gen` via Skill tool.
2. Gate:
   - `slides/deck.md` exists
   - `slides/deck-notes.md` exists
3. If gate fails: stop and report.

---

### Phase 4 — Visual QA

Goal: detect rendering and layout flaws in the rendered PDF and fix them.

1. Run `task pdf`, then invoke `marp-deck-checker` via Skill tool.
2. Output:
   - **PASS**: pipeline complete.
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
