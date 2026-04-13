---
name: md2pdf
description: >
  Convert Markdown files to professional PDF documents using Pandoc + XeLaTeX.
  Use when the user asks to generate a PDF, export a document, create a PDF from markdown,
  or produce a printable version of any .md file. Supports two templates: "sourcesense"
  (corporate branding with logo, red/orange palette, copyright footer) and "standard"
  (clean professional layout, blue/gray palette, no branding). Also use when asked to
  convert documentation, specs, sprint docs, or any project markdown to PDF.
---

# md2pdf

Convert Markdown to PDF with template selection.

## Prerequisites

- `pandoc` installed
- `xelatex` installed (via MacTeX on macOS: `/Library/TeX/texbin/xelatex`)

Verify before running:
```bash
command -v pandoc && (command -v xelatex || test -x /Library/TeX/texbin/xelatex)
```

## Templates

| Template | Style | Header | Footer | Best for |
|----------|-------|--------|--------|----------|
| `sourcesense` | Red/orange Sourcesense palette, logo top-right | Company logo | "© Sourcesense 2026" + page number | Client-facing deliverables, internal company docs |
| `standard` | Blue/gray neutral palette, no logo | Document title (italic) + date | Page number centered | Technical docs, external handoffs, vendor-neutral reports |

Template files: [assets/templates/](assets/templates/)

## Usage

The conversion script is at [scripts/md2pdf.sh](scripts/md2pdf.sh) inside this skill's directory.
Use the skill's **base directory** (provided at load time) to build the absolute path. Examples below use `$SKILL_DIR` as a placeholder — resolve it from the base directory shown in the system prompt.

```bash
# Single file — default template (sourcesense), portrait
$SKILL_DIR/scripts/md2pdf.sh docs/specs/architecture.md

# Single file — standard template
$SKILL_DIR/scripts/md2pdf.sh --template standard deploy_notes/guida-deploy-produzione.md

# Single file — landscape (for docs with wide tables)
$SKILL_DIR/scripts/md2pdf.sh --landscape docs/planning/journal.md

# Combined: standard template + landscape
$SKILL_DIR/scripts/md2pdf.sh --template standard --landscape input.md /tmp/output.pdf

# Batch mode — all project docs
$SKILL_DIR/scripts/md2pdf.sh --all

# Batch mode — standard template, landscape
$SKILL_DIR/scripts/md2pdf.sh --all --template standard --landscape
```

### Options

| Flag | Short | Default | Description |
|------|-------|---------|-------------|
| `--template <name>` | `-t` | `sourcesense` | LaTeX template to use |
| `--landscape` | `-l` | portrait | Landscape page orientation — use for docs with wide tables |

Output goes to `pdf/output/` (relative to project root) by default.

## Workflow

1. Ensure the markdown file has no LaTeX-incompatible syntax:
   - Replace `- [ ]` checkbox markers with `- ▢` (U+25A2) or plain `- `
   - Verify image paths are relative to the document directory
2. Run the script with the chosen template
3. Check exit code — non-zero means conversion failed
4. PDF is written to `pdf/output/<filename>.pdf` unless a custom path is given

## Markdown Features Supported

- Pipe tables (`| col | col |`)
- Fenced code blocks with syntax highlighting (Tango theme)
- Auto-generated heading IDs
- Table of contents (depth 3 by default)
- Inline images (resolved from document directory, `images/` subdirs, and skill's `assets/logo/`)

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Undefined control sequence \square` | Markdown checkboxes `- [ ]` | Replace with `- ▢` or `- ` |
| `xelatex not found` | MacTeX not installed or not in PATH | Install MacTeX; script auto-detects `/Library/TeX/texbin` |
| `Font not found: Helvetica Neue` | Font missing on system | Install font or set `--variable mainfont="DejaVu Sans"` |
| Image not rendering | Image path not resolvable | Place images in same dir as .md or in `images/` subdirectory |
