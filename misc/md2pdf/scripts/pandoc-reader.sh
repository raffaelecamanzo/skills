#!/usr/bin/env bash
# Single source of truth for the pandoc reader configuration.
# Sourced by md2pdf.sh and by test-md2pdf.sh so both always agree.
#
# Why each deviation from plain `markdown` (all verified against fixtures/):
#
#   -yaml_metadata_block   A `---` … `---` pair anywhere in the body is otherwise
#                          read as a metadata block and aborts the run with a YAML
#                          parse error. Leading front matter is stripped by
#                          sanitize-md.py instead.
#   -simple_tables         `---` followed by a non-blank line is otherwise read as a
#   -multiline_tables      table rule: the rule and every heading after it are
#                          silently swallowed into a phantom table. This fails
#                          quietly — it produces a PDF, just not yours.
#   +lists_without_preceding_blankline
#                          Obsidian (and CommonMark) let a list interrupt a
#                          paragraph; plain pandoc markdown does not, and flattens
#                          the list into prose.
#   +wikilinks_title_after_pipe
#                          Renders `[[target|label]]` as `label` instead of printing
#                          the brackets verbatim. Also makes `![[image.png]]` resolve.
#
# Deliberately NOT enabled:
#   +mark                  `==highlight==` is unused across the vault; enabling it
#                          would add a LaTeX dependency for no observed input.

PANDOC_READER='markdown+pipe_tables+fenced_code_blocks+backtick_code_blocks+auto_identifiers-yaml_metadata_block-simple_tables-multiline_tables+lists_without_preceding_blankline+wikilinks_title_after_pipe'
