#!/usr/bin/env bash
# test-md2pdf.sh — regression tests for the pandoc reader config and sanitize-md.py.
#
# Every assertion here corresponds to a defect that was observed in the wild:
# front matter printed in the body, setext headings demoted, blank lines injected
# into code fences, horizontal rules and headings swallowed by phantom tables,
# lists flattened into prose, and Obsidian syntax printed verbatim.
#
# Usage: ./test-md2pdf.sh          structural checks + one end-to-end PDF build
#        ./test-md2pdf.sh --fast   structural checks only (no LaTeX needed)
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIXTURES="$SCRIPT_DIR/fixtures"
# shellcheck source=pandoc-reader.sh
source "$SCRIPT_DIR/pandoc-reader.sh"

FAST=""
[ "${1:-}" = "--fast" ] && FAST="true"

PASS=0
FAIL=0

# Render a fixture exactly as md2pdf.sh would: sanitise, then read with PANDOC_READER.
render() {
  local fixture="$FIXTURES/$1"
  local tmp="$fixture.test-tmp.$$.md"
  "$SCRIPT_DIR/sanitize-md.py" --quiet "$fixture" "$tmp" || { echo "sanitize failed"; return 1; }
  pandoc "$tmp" -f "$PANDOC_READER" -t html 2>&1
  rm -f "$tmp"
}

check() { # check <description> <expected> <actual>
  if [ "$2" = "$3" ]; then
    PASS=$((PASS + 1))
    printf '  ok   %s\n' "$1"
  else
    FAIL=$((FAIL + 1))
    printf '  FAIL %s — atteso %s, ottenuto %s\n' "$1" "$2" "$3"
  fi
}

count() { grep -o "$2" <<<"$1" | wc -l | tr -d ' '; }

echo "reader: $PANDOC_READER"
echo

echo "front-matter.md — il front matter non deve finire nel corpo"
OUT="$(render front-matter.md)"
check "nessun 'status: active' nel corpo" 0 "$(count "$OUT" 'status: active')"
check "il titolo reale resta un h1"        1 "$(count "$OUT" '<h1')"

echo "setext-heading.md — un heading setext non va declassato"
OUT="$(render setext-heading.md)"
check "heading setext preservato" 1 "$(count "$OUT" '<h2')"
check "nessuna riga orizzontale spuria" 0 "$(count "$OUT" '<hr')"

echo "code-fence.md — dentro un fence non si tocca nulla"
OUT="$(render code-fence.md)"
check "il fence resta un blocco di codice" 1 "$(count "$OUT" '<pre')"
check "le righe '- alpha/- beta' non diventano una lista" 0 "$(count "$OUT" '<ul')"

echo "separators-and-lists.md — regole orizzontali e liste che interrompono un paragrafo"
OUT="$(render separators-and-lists.md)"
check "entrambi i '---' sono regole orizzontali" 2 "$(count "$OUT" '<hr')"
check "entrambi gli h2 sopravvivono"             2 "$(count "$OUT" '<h2')"
check "la lista numerata resta una lista"        1 "$(count "$OUT" '<ol')"

echo "obsidian-syntax.md — wikilink e callout"
OUT="$(render obsidian-syntax.md)"
check "nessun '[[' stampato alla lettera" 0 "$(count "$OUT" '\[\[')"
check "due wikilink risolti"              2 "$(count "$OUT" 'class="wikilink"')"
check "nessun marcatore '\[!' residuo"    0 "$(count "$OUT" '\[!')"
check "il titolo del callout è in grassetto" 2 "$(count "$OUT" '<strong>')"

if [ -z "$FAST" ]; then
  echo "task-list.md — build PDF end-to-end (le checkbox richiedono amssymb nel template)"
  for tpl in sourcesense standard; do
    out="$FIXTURES/.task-list-$tpl.pdf"
    "$SCRIPT_DIR/md2pdf.sh" --template "$tpl" "$FIXTURES/task-list.md" "$out" >/dev/null 2>&1
    check "template $tpl converte senza errori" 0 "$?"
    rm -f "$out"
  done
fi

echo
echo "── $PASS superati, $FAIL falliti su $((PASS + FAIL)) asserzioni ──"
[ "$FAIL" -eq 0 ]
