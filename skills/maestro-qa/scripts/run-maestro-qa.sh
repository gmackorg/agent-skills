#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  run-maestro-qa.sh --repo /path/to/repo [options]

This is a thin wrapper around the report-only Maestro runner.
Use it to keep artifact paths and invocation shape consistent before
entering the fix-and-rerun loop described in the skill.

Options:
  --repo PATH               App repo root. Required.
  --flow-path PATH          Flow file or workspace path relative to repo. Default: .maestro
  --output-dir PATH         Artifact output directory relative to repo. Default: build/maestro-results
  --report-format FORMAT    Maestro report format: html, html-detailed, or junit. Default: html-detailed
  --report-file PATH        Report file path relative to repo. Default depends on format.
  --debug-output-dir PATH   Optional debug output directory relative to repo.
  --include-tags TAGS       Optional Maestro include-tags value.
  --dry-run                 Print the delegated Maestro command without executing it.
  --help                    Show this help.
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
report_runner="$repo_root/skills/maestro-qa-report/scripts/run-maestro-qa-report.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ ! -x "$report_runner" ]]; then
  echo "report runner not found or not executable: $report_runner" >&2
  exit 1
fi

printf 'mode\tfix-capable\n'
printf 'note\tstart with report-only evidence, then fix one verified issue at a time\n'

"$report_runner" "$@"
