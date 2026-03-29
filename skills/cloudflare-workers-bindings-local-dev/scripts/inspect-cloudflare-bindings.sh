#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  inspect-cloudflare-bindings.sh --repo /path/to/project [--format text|json]

Options:
  --repo PATH           Project repo root. Required.
  --format FORMAT       Output format: text or json. Default: text.
  --help                Show this help.
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

if [[ -z "$repo" ]]; then
  echo "--repo is required" >&2
  usage >&2
  exit 1
fi

if [[ ! -d "$repo" ]]; then
  echo "repo not found: $repo" >&2
  exit 1
fi

repo="$(cd "$repo" && pwd)"

find_top_level_files_json() {
  local expr=("$@")
  find "$repo" -maxdepth 1 "${expr[@]}" -print 2>/dev/null \
    | sed "s|$repo/||" \
    | sort -u \
    | jq -R . \
    | jq -s 'map(select(length > 0))'
}

wrangler_file=""
if [[ -f "$repo/wrangler.jsonc" ]]; then
  wrangler_file="$repo/wrangler.jsonc"
elif [[ -f "$repo/wrangler.toml" ]]; then
  wrangler_file="$repo/wrangler.toml"
fi

extract_wrangler_lines_json() {
  local pattern="$1"
  if [[ -n "$wrangler_file" ]]; then
    rg -n "$pattern" "$wrangler_file" 2>/dev/null \
      | sed "s|$repo/||" \
      | jq -R . \
      | jq -s 'map(select(length > 0))'
  else
    printf '[]'
  fi
}

env_files_json="$(find_top_level_files_json \( -name '.dev.vars' -o -name '.dev.vars.*' -o -name '.env' -o -name '.env.*' \))"
wrangler_files_json="$(find_top_level_files_json \( -name 'wrangler.jsonc' -o -name 'wrangler.toml' \))"

env_sections_json="$(extract_wrangler_lines_json '(^|\\s)(\\[env\\.|\"env\"\\s*:|env\\s*=)')"
d1_lines_json="$(extract_wrangler_lines_json 'd1_databases|preview_database_id')"
kv_lines_json="$(extract_wrangler_lines_json 'kv_namespaces')"
r2_lines_json="$(extract_wrangler_lines_json 'r2_buckets')"
queue_lines_json="$(extract_wrangler_lines_json 'queues')"
durable_object_lines_json="$(extract_wrangler_lines_json 'durable_objects')"
workflow_lines_json="$(extract_wrangler_lines_json 'workflows')"
service_binding_lines_json="$(extract_wrangler_lines_json 'services|service = ')"
remote_binding_lines_json="$(extract_wrangler_lines_json 'remote\\s*=|\"remote\"\\s*:')"

binding_usage_json="$(
  rg -l --hidden --glob '!node_modules' --glob '!\.git' \
    'env\.[A-Z0-9_]+|process\.env|getCloudflareContext|D1Database|KVNamespace|R2Bucket|DurableObjectNamespace|WorkflowEntrypoint' \
    "$repo" 2>/dev/null \
    | sed "s|$repo/||" \
    | sort -u \
    | jq -R . \
    | jq -s 'map(select(length > 0))'
)"

emit_text() {
  printf 'repo\t%s\n' "$repo"
  printf 'wrangler_files\t%s\n' "$(jq -r 'if length > 0 then join(",") else "missing" end' <<<"$wrangler_files_json")"
  printf 'env_files\t%s\n' "$(jq -r 'if length > 0 then join(",") else "none" end' <<<"$env_files_json")"
  printf 'env_sections\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$env_sections_json")"
  printf 'd1_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$d1_lines_json")"
  printf 'kv_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$kv_lines_json")"
  printf 'r2_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$r2_lines_json")"
  printf 'queue_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$queue_lines_json")"
  printf 'durable_object_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$durable_object_lines_json")"
  printf 'workflow_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$workflow_lines_json")"
  printf 'service_binding_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$service_binding_lines_json")"
  printf 'remote_binding_markers\t%s\n' "$(jq -r 'if length > 0 then join(" | ") else "none" end' <<<"$remote_binding_lines_json")"
  printf 'binding_usage_files\t%s\n' "$(jq -r 'if length > 0 then join(",") else "none" end' <<<"$binding_usage_json")"
}

emit_json() {
  jq -cn \
    --arg repo "$repo" \
    --argjson wranglerFiles "$wrangler_files_json" \
    --argjson envFiles "$env_files_json" \
    --argjson envSections "$env_sections_json" \
    --argjson d1Markers "$d1_lines_json" \
    --argjson kvMarkers "$kv_lines_json" \
    --argjson r2Markers "$r2_lines_json" \
    --argjson queueMarkers "$queue_lines_json" \
    --argjson durableObjectMarkers "$durable_object_lines_json" \
    --argjson workflowMarkers "$workflow_lines_json" \
    --argjson serviceBindingMarkers "$service_binding_lines_json" \
    --argjson remoteBindingMarkers "$remote_binding_lines_json" \
    --argjson bindingUsageFiles "$binding_usage_json" \
    '{
      repo: $repo,
      wranglerFiles: $wranglerFiles,
      envFiles: $envFiles,
      envSections: $envSections,
      d1Markers: $d1Markers,
      kvMarkers: $kvMarkers,
      r2Markers: $r2Markers,
      queueMarkers: $queueMarkers,
      durableObjectMarkers: $durableObjectMarkers,
      workflowMarkers: $workflowMarkers,
      serviceBindingMarkers: $serviceBindingMarkers,
      remoteBindingMarkers: $remoteBindingMarkers,
      bindingUsageFiles: $bindingUsageFiles
    }'
}

case "$format" in
  text)
    emit_text
    ;;
  json)
    emit_json
    ;;
  *)
    echo "unsupported format: $format" >&2
    exit 1
    ;;
esac
