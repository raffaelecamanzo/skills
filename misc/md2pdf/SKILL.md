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
| `--no-sanitize` | — | sanitize | Feed pandoc the file verbatim — debugging only, see *Markdown dialect* |

Output goes to `pdf/output/` (relative to project root) by default.

## Workflow

1. Run the script with the chosen template — **do not pre-edit the Markdown**. Obsidian
   syntax, front matter, task lists and `---` separators are all handled; see
   *Markdown dialect* below for what is handled and how.
2. Check exit code — non-zero means conversion failed
3. PDF is written to `pdf/output/<filename>.pdf` unless a custom path is given

The only thing worth checking by hand is that image paths are relative to the document
directory.

## Markdown Features Supported

- Pipe tables (`| col | col |`)
- Fenced code blocks with syntax highlighting (Tango theme)
- Auto-generated heading IDs
- Table of contents (depth 3 by default)
- Inline images (resolved from document directory, `images/` subdirs, and skill's `assets/logo/`)

## Markdown dialect

Documents written in Obsidian are not plain pandoc Markdown. The gap is closed in two
places, neither of which touches the source file:

- **Reader configuration** — [scripts/pandoc-reader.sh](scripts/pandoc-reader.sh) holds the
  pandoc reader string and a comment explaining why each extension is on or off. It is the
  single source of truth, shared with the test suite.
- **Sanitisation** — [scripts/sanitize-md.py](scripts/sanitize-md.py) writes a sanitised copy
  next to the source (removed on exit) and handles the two things the reader cannot: leading
  YAML front matter and Obsidian callout markers.

| Input | Handled by | Result |
|-------|-----------|--------|
| Leading YAML front matter | sanitiser | Removed — it is metadata, not body text |
| `> [!note] Title` callouts | sanitiser | Marker unwrapped to a bold title |
| `---` separators between sections | reader (`-simple_tables -multiline_tables`) | Horizontal rule |
| `---` pairs mid-document | reader (`-yaml_metadata_block`) | Horizontal rules, not a metadata block |
| Lists interrupting a paragraph | reader (`+lists_without_preceding_blankline`) | A real list |
| `[[page\|label]]`, `![[image.png]]` | reader (`+wikilinks_title_after_pipe`) | Link text / embedded image |
| `- [ ]` / `- [x]` task lists | template (`amssymb`) | Checkbox glyphs |

> **Why this matters.** With plain `markdown` as the reader, `---` followed by a non-blank
> line is read as a *table rule*: the separator and every heading after it disappear into a
> phantom table. It does not raise an error — it produces a clean-looking PDF with a third of
> the document structure missing.

### Tests

[scripts/test-md2pdf.sh](scripts/test-md2pdf.sh) asserts the above against
[scripts/fixtures/](scripts/fixtures/). Run it after any change to the reader string, the
sanitiser or the templates:

```bash
$SKILL_DIR/scripts/test-md2pdf.sh          # structural checks + end-to-end PDF build
$SKILL_DIR/scripts/test-md2pdf.sh --fast   # structural checks only, no LaTeX needed
```

Exit code is non-zero if any assertion fails.

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Error parsing YAML metadata` | A `---` pair in the body read as a metadata block | Should not happen — check `-yaml_metadata_block` is still in `pandoc-reader.sh`, then run the tests |
| Headings or `---` missing from the PDF, no error | `simple_tables`/`multiline_tables` swallowing them into a phantom table | Check `-simple_tables -multiline_tables` are still in `pandoc-reader.sh`, then run the tests |
| Front matter printed in the body | Sanitisation skipped | Drop `--no-sanitize` |
| `xelatex not found` | MacTeX not installed or not in PATH | Install MacTeX; script auto-detects `/Library/TeX/texbin` |
| `Font not found: Helvetica Neue` | Font missing on system | Install font or set `--variable mainfont="DejaVu Sans"` |
| Image not rendering | Image path not resolvable | Place images in same dir as .md or in `images/` subdirectory |
