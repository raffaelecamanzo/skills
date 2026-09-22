#!/usr/bin/env bash
# md2pdf.sh — Convert Markdown files to PDF using Pandoc + XeLaTeX
# Usage:
#   ./md2pdf.sh <file.md> [output.pdf]                       Single-file (default template)
#   ./md2pdf.sh --template standard <file.md> [output.pdf]   Single-file with template
#   ./md2pdf.sh --landscape <file.md>                        Landscape orientation
#   ./md2pdf.sh --all [--template standard] [--landscape]    Batch mode
#   ./md2pdf.sh --no-sanitize <file.md>                     Feed pandoc the file verbatim
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
TEMPLATES_DIR="$SKILL_DIR/assets/templates"
LOGO_DIR="$SKILL_DIR/assets/logo"
PDF_DIR="$PROJECT_ROOT/pdf/output"

# Defaults
TEMPLATE_NAME="sourcesense"
LANDSCAPE=""
SANITIZE="true"

# Pandoc reader configuration (shared with test-md2pdf.sh)
# shellcheck source=pandoc-reader.sh
source "$SCRIPT_DIR/pandoc-reader.sh"

# Add MacTeX to PATH if xelatex isn't found
if ! command -v xelatex &>/dev/null; then
  export PATH="/Library/TeX/texbin:$PATH"
fi

# Verify dependencies
for cmd in pandoc xelatex; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd not found. Please install it first." >&2
    exit 1
  fi
done

# ── Parse flags ──────────────────────────────────────────────────
parse_flags() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --template|-t)
        shift
        TEMPLATE_NAME="${1:?Error: --template requires a name (sourcesense, standard)}"
        shift
        ;;
      --landscape|-l)
        LANDSCAPE="true"
        shift
        ;;
      --no-sanitize)
        SANITIZE=""
        shift
        ;;
      *)
        REMAINING_ARGS+=("$1")
        shift
        ;;
    esac
  done
}

REMAINING_ARGS=()
parse_flags "$@"
set -- "${REMAINING_ARGS[@]+"${REMAINING_ARGS[@]}"}"

# Resolve template path
TEMPLATE="$TEMPLATES_DIR/$TEMPLATE_NAME.latex"
if [ ! -f "$TEMPLATE" ]; then
  echo "Error: Template '$TEMPLATE_NAME' not found at $TEMPLATE" >&2
  echo "Available templates:" >&2
  for t in "$TEMPLATES_DIR"/*.latex; do
    echo "  - $(basename "$t" .latex)" >&2
  done
  exit 1
fi

# Sanitised copies are written next to their source (so relative image paths keep
# resolving) and removed on exit, including when pandoc aborts under `set -e`.
TMP_FILES=()
cleanup_tmp() {
  if [ ${#TMP_FILES[@]} -gt 0 ]; then rm -f "${TMP_FILES[@]}"; fi
}
trap cleanup_tmp EXIT

# Extract title from first '# ' line in a Markdown file
extract_title() {
  grep -m1 '^# ' "$1" | sed 's/^# //' || basename "$1" .md
}

# Convert a single Markdown file to PDF
convert_one() {
  local input="$1"
  local output="$2"

  # Obsidian-flavoured input needs two fixes the reader config cannot make:
  # leading YAML front matter and callout markers. See scripts/sanitize-md.py.
  local src="$input"
  if [ -n "$SANITIZE" ]; then
    src="${input%.md}.md2pdf-tmp.$$.md"
    TMP_FILES+=("$src")
    "$SCRIPT_DIR/sanitize-md.py" "$input" "$src"
  fi

  local title
  title="$(extract_title "$src")"

  local input_dir
  input_dir="$(cd "$(dirname "$input")" && pwd)"

  # Build resource-path: input dir (for doc images), logo dir, and any images subdir
  local resource_path="$input_dir:$LOGO_DIR"
  if [ -d "$input_dir/images" ]; then
    resource_path="$input_dir/images:$resource_path"
  fi
  # Also check for sibling directory named like the file (e.g., architecture/ for architecture.md)
  local basename_no_ext
  basename_no_ext="$(basename "$input" .md)"
  if [ -d "$input_dir/$basename_no_ext/images" ]; then
    resource_path="$input_dir/$basename_no_ext/images:$resource_path"
  fi
  if [ -d "$input_dir/$basename_no_ext" ]; then
    resource_path="$input_dir/$basename_no_ext:$resource_path"
  fi

  # TEXINPUTS lets XeLaTeX find the logo and doc images via \includegraphics
  local texinputs="$LOGO_DIR:$input_dir:"
  if [ -d "$input_dir/$basename_no_ext/images" ]; then
    texinputs="$input_dir/$basename_no_ext/images:$texinputs"
  fi
  if [ -d "$input_dir/$basename_no_ext" ]; then
    texinputs="$input_dir/$basename_no_ext:$texinputs"
  fi
  if [ -d "$input_dir/images" ]; then
    texinputs="$input_dir/images:$texinputs"
  fi

  local orientation="portrait"
  local pandoc_extra=()
  if [ "$LANDSCAPE" = "true" ]; then
    orientation="landscape"
    pandoc_extra+=(--variable=landscape:true)
  fi

  echo "Converting: $input → $output  [template: $TEMPLATE_NAME, $orientation]"
  TEXINPUTS="$texinputs" \
  pandoc "$src" \
    -o "$output" \
    --template="$TEMPLATE" \
    --pdf-engine=xelatex \
    --resource-path="$resource_path" \
    --metadata title="$title" \
    --toc \
    --syntax-highlighting=tango \
    --variable=graphics:true \
    "${pandoc_extra[@]+"${pandoc_extra[@]}"}" \
    -f "$PANDOC_READER"
}

# ── Batch mode ───────────────────────────────────────────────────
if [ "${1:-}" = "--all" ]; then
  shift  # consume --all
  mkdir -p "$PDF_DIR"

  FILES=(
    docs/requests/desk-picker-req.md
    docs/specs/analyst-frs.md
    docs/specs/analyst-UAT.md
    docs/specs/writer-nfr.md
    docs/specs/software-spec.md
    docs/specs/architecture.md
    docs/specs/frontend-design.md
    docs/planning/journal.md
    docs/planning/sprint-log.md
    docs/planning/sprints/sprint-1.md
  )

  errors=0
  for f in "${FILES[@]}"; do
    full_path="$PROJECT_ROOT/$f"
    if [ ! -f "$full_path" ]; then
      echo "Warning: $f not found, skipping." >&2
      continue
    fi
    out_name="$(basename "$f" .md).pdf"
    if convert_one "$full_path" "$PDF_DIR/$out_name"; then
      echo "  ✓ $out_name"
    else
      echo "  ✗ $out_name FAILED" >&2
      errors=$((errors + 1))
    fi
  done

  echo ""
  echo "Output directory: $PDF_DIR"
  total=${#FILES[@]}
  echo "Done: $((total - errors))/$total files converted."
  [ "$errors" -eq 0 ] || exit 1

# ── Single-file mode ────────────────────────────────────────────
else
  if [ $# -lt 1 ]; then
    echo "Usage:" >&2
    echo "  $0 <file.md> [output.pdf]                       Convert a single file" >&2
    echo "  $0 --template <name> <file.md> [output.pdf]     Convert with a specific template" >&2
    echo "  $0 --landscape <file.md>                        Landscape orientation" >&2
    echo "  $0 --all [--template <name>] [--landscape]      Convert all project docs" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --template, -t <name>   Template: sourcesense (default), standard" >&2
    echo "  --landscape, -l         Landscape page orientation (default: portrait)" >&2
    echo "" >&2
    echo "Templates:" >&2
    for t in "$TEMPLATES_DIR"/*.latex; do
      echo "  - $(basename "$t" .latex)" >&2
    done
    exit 1
  fi

  INPUT="$1"
  if [ ! -f "$INPUT" ]; then
    echo "Error: File not found: $INPUT" >&2
    exit 1
  fi

  mkdir -p "$PDF_DIR"
  OUTPUT="${2:-$PDF_DIR/$(basename "$INPUT" .md).pdf}"
  convert_one "$INPUT" "$OUTPUT"
  echo "  ✓ $OUTPUT"
fi
