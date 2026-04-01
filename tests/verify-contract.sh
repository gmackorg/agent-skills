#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

example_skill="$root/skills/example-reference-skill/SKILL.md"
example_metadata="$root/skills/example-reference-skill/skill.json"
example_reference="$root/skills/example-reference-skill/references/checklist.md"
audit_skill="$root/skills/reference-layout-audit/SKILL.md"
audit_metadata="$root/skills/reference-layout-audit/skill.json"
audit_script="$root/skills/reference-layout-audit/scripts/inspect-reference-layout.sh"
audit_reference="$root/skills/reference-layout-audit/references/report-template.md"
installable_config_file="$root/catalog/installable-skills.json"
installable_config_verifier="$root/scripts/verify-installable-skills-config.sh"
smol_agent_reference_file="$root/catalog/smol-agent.reference.json"
smol_agent_builder="$root/scripts/build-smol-agent-source-config.sh"
flake_file="$root/flake.nix"
module_file="$root/nix/home-manager-module.nix"
tool_metadata_file="$root/tools/skill-bootstrap/tool.json"
tool_script_file="$root/tools/skill-bootstrap/bootstrap-skills.sh"
agent_metadata_file="$root/agents/reference-generalist/agent-metadata.json"
agent_definition_file="$root/agents/reference-generalist/agent.json"
branch_model_doc="$root/docs/reference-branch-model.md"
runtime_adoption_doc="$root/docs/runtime-adoption-guide.md"
openclaw_plugin_doc="$root/docs/openclaw-plugin-example.md"
agents_doc="$root/AGENTS.md"

test -f "$example_skill"
test -f "$example_metadata"
test -f "$example_reference"
test -f "$audit_skill"
test -f "$audit_metadata"
test -f "$audit_script"
test -f "$audit_reference"
test -f "$installable_config_file"
test -f "$installable_config_verifier"
test -f "$smol_agent_reference_file"
test -f "$smol_agent_builder"
test -f "$flake_file"
test -f "$module_file"
test -f "$tool_metadata_file"
test -f "$tool_script_file"
test -f "$agent_metadata_file"
test -f "$agent_definition_file"
test -f "$branch_model_doc"
test -f "$runtime_adoption_doc"
test -f "$openclaw_plugin_doc"
test -f "$agents_doc"

grep -q '^name: example-reference-skill$' "$example_skill"
grep -q '^name: reference-layout-audit$' "$audit_skill"

jq -e '.id == "example-reference-skill" and .kind == "skill"' "$example_metadata" >/dev/null
jq -e '.id == "reference-layout-audit" and .kind == "skill"' "$audit_metadata" >/dev/null

chmod +x "$audit_script" "$smol_agent_builder" "$installable_config_verifier" "$tool_script_file"
"$audit_script" --help >/dev/null
"$installable_config_verifier"
"$smol_agent_builder" "$root/catalog/smol-agent.reference.generated.json"
cmp -s "$smol_agent_reference_file" "$root/catalog/smol-agent.reference.generated.json"
rm "$root/catalog/smol-agent.reference.generated.json"

jq -e '
  .id == "skill-bootstrap" and
  .kind == "tool" and
  .entrypoint == "tools/skill-bootstrap/bootstrap-skills.sh"
' "$tool_metadata_file" >/dev/null

jq -e '
  .id == "reference-generalist" and
  .kind == "agent" and
  .definitionFile == "agents/reference-generalist/agent.json" and
  (.skillIds | index("example-reference-skill")) != null
' "$agent_metadata_file" >/dev/null

grep -q 'openclawPlugin =' "$flake_file"
grep -q 'name = "agent-skills-reference"' "$flake_file"
nix eval --impure --raw "$root#openclawPlugin.name" | grep -qx 'agent-skills-reference'
