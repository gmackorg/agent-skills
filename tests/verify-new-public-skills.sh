#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

retrospective_skill="$root/skills/llm-session-retrospective/SKILL.md"
retrospective_metadata="$root/skills/llm-session-retrospective/skill.json"
retrospective_script="$root/skills/llm-session-retrospective/scripts/discover-retrospective-context.sh"
retrospective_reference="$root/skills/llm-session-retrospective/references/output-template.md"

x402_skill="$root/skills/x402-smol-agent-workflow/SKILL.md"
x402_metadata="$root/skills/x402-smol-agent-workflow/skill.json"
catalog_skill="$root/skills/agent-skills-catalog-maintenance/SKILL.md"
catalog_metadata="$root/skills/agent-skills-catalog-maintenance/skill.json"
catalog_script="$root/skills/agent-skills-catalog-maintenance/scripts/generate-catalog-snapshot.sh"
context_skill="$root/skills/local-agent-context-discovery/SKILL.md"
context_metadata="$root/skills/local-agent-context-discovery/skill.json"
context_script="$root/skills/local-agent-context-discovery/scripts/discover-local-agent-context.sh"
maestro_skill="$root/skills/maestro-qa-report/SKILL.md"
maestro_metadata="$root/skills/maestro-qa-report/skill.json"
maestro_script="$root/skills/maestro-qa-report/scripts/run-maestro-qa-report.sh"
maestro_reference="$root/skills/maestro-qa-report/references/report-template.md"
maestro_fix_skill="$root/skills/maestro-qa/SKILL.md"
maestro_fix_metadata="$root/skills/maestro-qa/skill.json"
maestro_fix_script="$root/skills/maestro-qa/scripts/run-maestro-qa.sh"

test -f "$retrospective_skill"
test -f "$retrospective_metadata"
test -f "$retrospective_script"
test -f "$retrospective_reference"
test -f "$x402_skill"
test -f "$x402_metadata"
test -f "$catalog_skill"
test -f "$catalog_metadata"
test -f "$catalog_script"
test -f "$context_skill"
test -f "$context_metadata"
test -f "$context_script"
test -f "$maestro_skill"
test -f "$maestro_metadata"
test -f "$maestro_script"
test -f "$maestro_reference"
test -f "$maestro_fix_skill"
test -f "$maestro_fix_metadata"
test -f "$maestro_fix_script"

grep -q '^name: llm-session-retrospective$' "$retrospective_skill"
grep -q '^name: x402-smol-agent-workflow$' "$x402_skill"
grep -q '^name: agent-skills-catalog-maintenance$' "$catalog_skill"
grep -q '^name: local-agent-context-discovery$' "$context_skill"
grep -q '^name: maestro-qa-report$' "$maestro_skill"
grep -q '^name: maestro-qa$' "$maestro_fix_skill"

jq -e '.id == "llm-session-retrospective" and .kind == "skill"' "$retrospective_metadata" >/dev/null
jq -e '.id == "x402-smol-agent-workflow" and .kind == "skill"' "$x402_metadata" >/dev/null
jq -e '.id == "agent-skills-catalog-maintenance" and .kind == "skill"' "$catalog_metadata" >/dev/null
jq -e '.id == "local-agent-context-discovery" and .kind == "skill"' "$context_metadata" >/dev/null
jq -e '.id == "maestro-qa-report" and .kind == "skill"' "$maestro_metadata" >/dev/null
jq -e '.id == "maestro-qa" and .kind == "skill"' "$maestro_fix_metadata" >/dev/null

"$retrospective_script" /Volumes/dev/agent-skills >/dev/null
"$catalog_script" /Volumes/dev/agent-skills >/dev/null
"$context_script" /Volumes/dev/agent-skills >/dev/null
"$maestro_script" --help >/dev/null
"$maestro_fix_script" --help >/dev/null
