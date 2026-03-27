#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-$(pwd)}"
format="text"

if [[ "${2:-}" == "--format" ]]; then
  format="${3:-text}"
fi

if [[ ! -d "$repo_root" ]]; then
  echo "repo root not found: $repo_root" >&2
  exit 1
fi

repo_root="$(cd "$repo_root" && pwd)"
repo_parent="$(dirname "$repo_root")"

emit_result() {
  local source="$1"
  local file="$2"

  case "$format" in
    text)
      printf '%s\t%s\n' "$source" "$file"
      ;;
    json)
      jq -cn --arg source "$source" --arg path "$file" '{source: $source, path: $path}'
      ;;
    *)
      echo "unsupported format: $format" >&2
      exit 1
      ;;
  esac
}

search_dir() {
  local source="$1"
  local dir="$2"

  if [[ ! -d "$dir" ]]; then
    return
  fi

  find "$dir" -type f \
    \( -name 'SKILL.md' -o -name 'skill.md' -o -name 'AGENTS.md' -o -name '*PLAN*.md' -o -name '*DESIGN*.md' -o -name '*REVIEW*.md' -o -name '*TODO*.md' -o -path '*/docs/*' \) \
    -print 2>/dev/null \
  | while IFS= read -r file; do
      emit_result "$source" "$file"
    done
}

search_dir "current-repo" "$repo_root"
search_dir "sibling-smol-agent" "$repo_parent/smol-agent"
search_dir "sibling-tiered-router" "$repo_parent/tiered-router"
search_dir "sibling-nix-config" "$repo_parent/nix-config"
search_dir "home-claude" "$HOME/.claude"
search_dir "home-codex" "$HOME/.codex"
