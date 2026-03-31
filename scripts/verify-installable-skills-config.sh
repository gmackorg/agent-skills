#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_file="$root/catalog/installable-skills.json"

test -f "$config_file"

listed_ids="$(
  jq -r '.groups[].skillIds[]' "$config_file" | sort -u
)"

all_skill_dirs="$(
  find "$root/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -print \
    | sed "s|$root/skills/||" \
    | sed 's|/SKILL.md$||' \
    | sort -u
)"

duplicate_ids="$(
  jq -r '.groups[].skillIds[]' "$config_file" | sort | uniq -d
)"

if [[ -n "$duplicate_ids" ]]; then
  echo "duplicate skill ids in installable-skills config:" >&2
  echo "$duplicate_ids" >&2
  exit 1
fi

missing_from_config="$(
  comm -23 <(printf '%s\n' "$all_skill_dirs") <(printf '%s\n' "$listed_ids")
)"

missing_on_disk="$(
  comm -13 <(printf '%s\n' "$all_skill_dirs") <(printf '%s\n' "$listed_ids")
)"

if [[ -n "$missing_from_config" ]]; then
  echo "installable skills missing from config:" >&2
  echo "$missing_from_config" >&2
  exit 1
fi

if [[ -n "$missing_on_disk" ]]; then
  echo "skills listed in config but missing on disk:" >&2
  echo "$missing_on_disk" >&2
  exit 1
fi
