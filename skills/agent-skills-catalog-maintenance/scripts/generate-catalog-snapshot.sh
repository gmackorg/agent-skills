#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-$(pwd)}"

find "$repo_root" \
  \( -path '*/skills/*/skill.json' -o -path '*/tools/*/tool.json' -o -path '*/agents/*/agent-metadata.json' \) \
  -type f \
  -print \
  2>/dev/null \
| while read -r file; do
    jq -c --arg file "${file#$repo_root/}" '. + {sourceFile: $file}' "$file"
  done
