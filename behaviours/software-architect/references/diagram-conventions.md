# Diagram Conventions

Architectural views map to Mermaid diagram types. Generate diagrams as `.mmd` source files, render to PNG, and reference inline in the architecture document.

## Output Directories

- **Source files:** `docs/specs/architecture/diagrams/<name>.mmd`
- **Rendered images:** `docs/specs/architecture/images/<name>.png`
- **Image references in architecture.md:** `![Title](architecture/images/<name>.png)`

## Diagram-to-View Mapping

| Architectural View | Section | Mermaid Type | Declaration | Mandatory? |
|---|---|---|---|---|
| System context | §3.1 | Flowchart | `flowchart TB` | Always |
| Component map | §4.1 | Flowchart | `flowchart TB` | Always |
| Communication patterns | §4.2 | Sequence | `sequenceDiagram` | When async or multi-hop flows exist |
| Data flow | §6.2 | Flowchart | `flowchart LR` | When transformation pipeline exists |
| External integrations | §7.3 | Sequence | `sequenceDiagram` | When 2+ external systems with distinct protocols |
| Deployment topology | §9 | Flowchart | `flowchart TB` | When 3+ infrastructure tiers |
| Data model | §6.1 | ER diagram | `erDiagram` | When relational schema is architecturally significant |
| Entity lifecycle | — | State diagram | `stateDiagram-v2` | When key entity has 4+ states |

### Why not C4 diagrams?

`C4Context` / `C4Container` require a Mermaid extension not universally available. Plain `flowchart TB` with semantic node shapes achieves the same effect with universal renderer compatibility.

## File Naming Convention

`<section>-<descriptor>.mmd`

Examples:
- `3-system-context.mmd`
- `4-component-map.mmd`
- `4-communication-patterns.mmd`
- `6-data-flow.mmd`
- `7-integrations.mmd`
- `9-deployment-topology.mmd`

## Style Rules

### Flowcharts

- `flowchart TB` for structural views (top-to-bottom hierarchy)
- `flowchart LR` for data flow / pipeline views (left-to-right progression)
- Labels: 4 words max per line; use `<br/>` for longer text
- Node shapes encode meaning:
  - `[Rectangle]` — service / application component
  - `[(Cylinder)]` — database / persistent store
  - `(Rounded)` — actor / user role
  - `>Parallelogram]` — external system
- Use `subgraph` for bounded contexts, infrastructure tiers, or team ownership boundaries
- Target 6–12 nodes per diagram; split at a logical boundary if >15

### Sequence Diagrams

- Max 6 participants
- Use `activate` / `deactivate` for async call spans
- Label messages with the operation name, not implementation details

### ER Diagrams

- Include only architecturally significant entities and relationships
- Use standard cardinality notation (`||--o{`, `}|--|{`, etc.)

### State Diagrams

- Include only states visible at the architectural level
- Use `[*]` for start/end states

## Rendering

Render each `.mmd` file immediately after writing it:

```bash
npx -y -p @mermaid-js/mermaid-cli mmdc -i <input>.mmd -o <output>.png -b white
```

Verify the PNG exists before inserting the image reference in `architecture.md`.

## Image Placement in architecture.md

Within each section, follow this order:

1. Section heading
2. Prose description
3. Diagram image reference
4. Table (if present)

Diagrams augment tables — they do not replace them. Tables carry structured data; diagrams carry spatial relationships.
