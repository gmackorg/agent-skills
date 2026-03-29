#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  plan-opennext-adoption.sh --repo /path/to/app [--format text|json]

Options:
  --repo PATH           App repo root. Required.
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

has_file() {
  [[ -e "$repo/$1" ]]
}

read_package_json_field() {
  local query="$1"
  if [[ -f "$repo/package.json" ]]; then
    jq -r "$query // empty" "$repo/package.json"
  fi
}

has_package() {
  local package_name="$1"
  [[ -f "$repo/package.json" ]] || return 1
  jq -e --arg package_name "$package_name" '
    (.dependencies // {})[$package_name] != null or
    (.devDependencies // {})[$package_name] != null
  ' "$repo/package.json" >/dev/null
}

detect_router() {
  local app_router="false"
  local pages_router="false"

  if has_file app || has_file src/app; then
    app_router="true"
  fi

  if has_file pages || has_file src/pages; then
    pages_router="true"
  fi

  if [[ "$app_router" == "true" && "$pages_router" == "true" ]]; then
    printf 'mixed'
  elif [[ "$app_router" == "true" ]]; then
    printf 'app'
  elif [[ "$pages_router" == "true" ]]; then
    printf 'pages'
  else
    printf 'unknown'
  fi
}

detect_deploy_target() {
  if has_package "@opennextjs/cloudflare" || has_file wrangler.jsonc || has_file wrangler.toml; then
    printf 'cloudflare-workers'
  elif has_file vercel.json || has_package "vercel"; then
    printf 'vercel'
  elif [[ "$(read_package_json_field '.scripts.start')" == *"next start"* ]]; then
    printf 'node-server'
  elif [[ "$(read_package_json_field '.scripts.export')" == *"next export"* ]]; then
    printf 'static-export'
  else
    printf 'unknown'
  fi
}

collect_matches() {
  local pattern="$1"
  find "$repo" -maxdepth 2 -name "$pattern" -print 2>/dev/null \
    | sed "s|$repo/||" \
    | sort -u
}

env_files_json="$(
  find "$repo" -maxdepth 1 \( -name '.env' -o -name '.env.*' -o -name '.dev.vars' -o -name '.dev.vars.*' \) -print 2>/dev/null \
    | sed "s|$repo/||" \
    | sort -u \
    | jq -R . \
    | jq -s 'map(select(length > 0))'
)"

binding_markers_json="$(
  rg -l --hidden --glob '!node_modules' --glob '!\.git' \
    'getCloudflareContext|process\.env|env\.[A-Z0-9_]+|KVNamespace|D1Database|R2Bucket|DurableObjectNamespace' \
    "$repo" 2>/dev/null \
    | sed "s|$repo/||" \
    | sort -u \
    | jq -R . \
    | jq -s 'map(select(length > 0))'
)"

wrangler_files_json="$(
  {
    collect_matches 'wrangler.jsonc'
    collect_matches 'wrangler.toml'
  } | sort -u | jq -R . | jq -s 'map(select(length > 0))'
)"

opennext_config_json="$(
  {
    collect_matches 'open-next.config.*'
    collect_matches 'opennext.config.*'
  } | sort -u | jq -R . | jq -s 'map(select(length > 0))'
)"

router="$(detect_router)"
deploy_target="$(detect_deploy_target)"

emit_text() {
  printf 'repo\t%s\n' "$repo"
  printf 'has_package_json\t%s\n' "$(has_file package.json && echo present || echo missing)"
  printf 'next_dependency\t%s\n' "$(has_package next && echo present || echo missing)"
  printf 'router\t%s\n' "$router"
  printf 'deploy_target\t%s\n' "$deploy_target"
  printf 'opennext_adapter\t%s\n' "$(has_package "@opennextjs/cloudflare" && echo present || echo missing)"
  printf 'open_next_package\t%s\n' "$(has_package "open-next" && echo present || echo missing)"
  printf 'wrangler_config\t%s\n' "$(jq -r 'if length > 0 then join(",") else "missing" end' <<<"$wrangler_files_json")"
  printf 'opennext_config\t%s\n' "$(jq -r 'if length > 0 then join(",") else "missing" end' <<<"$opennext_config_json")"
  printf 'env_files\t%s\n' "$(jq -r 'if length > 0 then join(",") else "none" end' <<<"$env_files_json")"
  printf 'binding_markers\t%s\n' "$(jq -r 'if length > 0 then join(",") else "none" end' <<<"$binding_markers_json")"
}

emit_json() {
  jq -cn \
    --arg repo "$repo" \
    --arg router "$router" \
    --arg deployTarget "$deploy_target" \
    --argjson hasPackageJson "$(has_file package.json && echo true || echo false)" \
    --argjson nextDependency "$(has_package next && echo true || echo false)" \
    --argjson opennextAdapter "$(has_package "@opennextjs/cloudflare" && echo true || echo false)" \
    --argjson openNextPackage "$(has_package "open-next" && echo true || echo false)" \
    --argjson wranglerFiles "$wrangler_files_json" \
    --argjson opennextConfig "$opennext_config_json" \
    --argjson envFiles "$env_files_json" \
    --argjson bindingMarkers "$binding_markers_json" \
    '{
      repo: $repo,
      hasPackageJson: $hasPackageJson,
      nextDependency: $nextDependency,
      router: $router,
      deployTarget: $deployTarget,
      opennextAdapter: $opennextAdapter,
      openNextPackage: $openNextPackage,
      wranglerFiles: $wranglerFiles,
      opennextConfig: $opennextConfig,
      envFiles: $envFiles,
      bindingMarkers: $bindingMarkers
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
