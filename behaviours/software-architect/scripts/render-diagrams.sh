#!/usr/bin/env bash
# Batch re-render all Mermaid diagrams to PNG.
# Usage: bash render-diagrams.sh [project-root]
# Defaults to current directory if no argument given.

set -euo pipefail

ROOT="${1:-.}"
DIAGRAMS_DIR="$ROOT/docs/specs/architecture/diagrams"
IMAGES_DIR="$ROOT/docs/specs/architecture/images"

if [ ! -d "$DIAGRAMS_DIR" ]; then
  echo "Error: diagrams directory not found: $DIAGRAMS_DIR" >&2
  exit 1
fi

mkdir -p "$IMAGES_DIR"

count=0
errors=0

for mmd in "$DIAGRAMS_DIR"/*.mmd; do
  [ -f "$mmd" ] || continue
  name="$(basename "$mmd" .mmd)"
  out="$IMAGES_DIR/$name.png"
  echo "Rendering $name.mmd → $name.png"
  if npx -y @mermaid-js/mermaid-cli mmdc -i "$mmd" -o "$out" -b white; then
    count=$((count + 1))
  else
    echo "  FAILED: $name.mmd" >&2
    errors=$((errors + 1))
  fi
done

echo ""
echo "Done: $count rendered, $errors failed."
[ "$errors" -eq 0 ] || exit 1
