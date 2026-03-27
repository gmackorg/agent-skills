#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-$(pwd)}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$script_dir/../../.." && pwd)"

"$repo_dir/skills/local-agent-context-discovery/scripts/discover-local-agent-context.sh" "$repo_root"
