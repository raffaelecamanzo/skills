#!/usr/bin/env python3
"""Adapt Obsidian-flavoured Markdown to what pandoc's reader accepts.

Writes a sanitised copy; the source file is never modified.

Only two transformations live here. Everything else that used to need rewriting
(horizontal rules, lists interrupting a paragraph, wikilinks, embeds) is handled
natively by the reader configuration in pandoc-reader.sh — see the comments there.

  1. Leading YAML front matter is removed.
     Required: the reader disables `yaml_metadata_block`, so front matter would
     otherwise be printed in the body of the PDF.

  2. Obsidian callout markers are unwrapped: `> [!note] Title` -> `> **Title**`.
     Pandoc has no extension for these and prints `[!note]` verbatim.

Both are skipped inside fenced code blocks. Exit codes: 0 ok, 1 usage/IO error.
"""

from __future__ import annotations

import argparse
import re
import sys

FENCE = re.compile(r"^(\s{0,3})(`{3,}|~{3,})(.*)$")
CALLOUT = re.compile(r"^(\s*>+\s*)\[!([A-Za-z]+)\][+-]?\s*(.*)$")


def strip_front_matter(lines: list[str]) -> tuple[list[str], int]:
    """Drop a YAML block only when it opens on the very first line."""
    if not lines or lines[0].strip() != "---":
        return lines, 0
    for i in range(1, len(lines)):
        if lines[i].strip() in ("---", "..."):
            rest = lines[i + 1 :]
            while rest and not rest[0].strip():
                rest.pop(0)
            return rest, i + 1
    # Unterminated: not front matter after all, leave the document alone.
    return lines, 0


def unwrap_callouts(lines: list[str]) -> tuple[list[str], int]:
    out: list[str] = []
    fence: str | None = None
    changed = 0
    for line in lines:
        m = FENCE.match(line)
        if m:
            marker = m.group(2)
            if fence is None:
                fence = marker
            elif marker[0] == fence[0] and len(marker) >= len(fence):
                fence = None
            out.append(line)
            continue
        if fence is None:
            c = CALLOUT.match(line)
            if c:
                prefix, kind, title = c.group(1), c.group(2), c.group(3).strip()
                out.append(f"{prefix}**{title or kind.capitalize()}**")
                changed += 1
                continue
        out.append(line)
    return out, changed


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("source", help="Markdown file to read (never modified)")
    ap.add_argument("dest", help="path to write the sanitised copy to")
    ap.add_argument("-q", "--quiet", action="store_true", help="suppress the summary line")
    args = ap.parse_args()

    try:
        text = open(args.source, encoding="utf-8").read()
    except OSError as exc:
        print(f"sanitize-md: cannot read {args.source}: {exc}", file=sys.stderr)
        return 1

    lines = text.split("\n")
    lines, fm = strip_front_matter(lines)
    lines, callouts = unwrap_callouts(lines)

    try:
        with open(args.dest, "w", encoding="utf-8") as fh:
            fh.write("\n".join(lines))
    except OSError as exc:
        print(f"sanitize-md: cannot write {args.dest}: {exc}", file=sys.stderr)
        return 1

    if not args.quiet and (fm or callouts):
        bits = []
        if fm:
            bits.append(f"front matter stripped ({fm} lines)")
        if callouts:
            bits.append(f"callouts unwrapped ({callouts})")
        print("  sanitised: " + ", ".join(bits))
    return 0


if __name__ == "__main__":
    sys.exit(main())
