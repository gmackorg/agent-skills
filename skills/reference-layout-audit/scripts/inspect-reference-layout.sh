#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  inspect-reference-layout.sh --repo /path/to/repo [--format text|json]
EOF
}

repo=""
format="text"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --format)
      format="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

[[ -n "$repo" ]] || { echo "--repo is required" >&2; usage >&2; exit 1; }
[[ -d "$repo" ]] || { echo "repo not found: $repo" >&2; exit 1; }

repo="$(cd "$repo" && pwd)"

has_path() {
  [[ -e "$repo/$1" ]]
}

emit_text() {
  printf 'repo\t%s\n' "$repo"
  printf 'skills\t%s\n' "$(has_path skills && echo present || echo missing)"
  printf 'agents\t%s\n' "$(has_path agents && echo present || echo missing)"
  printf 'tools\t%s\n' "$(has_path tools && echo present || echo missing)"
  printf 'catalog\t%s\n' "$(has_path catalog && echo present || echo missing)"
  printf 'docs\t%s\n' "$(has_path docs && echo present || echo missing)"
  printf 'flake\t%s\n' "$(has_path flake.nix && echo present || echo missing)"
}

emit_json() {
  jq -cn \
    --arg repo "$repo" \
    --argjson skills "$(has_path skills && echo true || echo false)" \
    --argjson agents "$(has_path agents && echo true || echo false)" \
    --argjson tools "$(has_path tools && echo true || echo false)" \
    --argjson catalog "$(has_path catalog && echo true || echo false)" \
    --argjson docs "$(has_path docs && echo true || echo false)" \
    --argjson flake "$(has_path flake.nix && echo true || echo false)" \
    '{repo: $repo, skills: $skills, agents: $agents, tools: $tools, catalog: $catalog, docs: $docs, flake: $flake}'
}

case "$format" in
  text) emit_text ;;
  json) emit_json ;;
  *) echo "unsupported format: $format" >&2; exit 1 ;;
esac
