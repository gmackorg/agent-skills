#!/usr/bin/env bash
set -euo pipefail

source_ref="${1:-}"

if [[ -z "$source_ref" ]]; then
  echo "usage: skill-bootstrap <repo-or-path> [skill-id ...]" >&2
  exit 1
fi

shift || true

if [[ "$#" -eq 0 ]]; then
  printf 'npx skills add %q --global --skill "*"\n' "$source_ref"
  exit 0
fi

for skill_id in "$@"; do
  printf 'npx skills add %q --global --skill %q\n' "$source_ref" "$skill_id"
done
