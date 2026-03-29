#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

metadata_file="$root/skills/expo-build-validation/skill.json"
second_metadata_file="$root/skills/expo-build-submit/skill.json"
validation_skill_file="$root/skills/expo-build-validation/SKILL.md"
submit_skill_file="$root/skills/expo-build-submit/SKILL.md"
validation_reference_file="$root/skills/expo-build-validation/references/release-validation-checklist.md"
submit_reference_file="$root/skills/expo-build-submit/references/submission-sequence.md"
flake_file="$root/flake.nix"
module_file="$root/nix/home-manager-module.nix"
example_module_file="$root/nix/examples/combined-home-manager.nix"
tool_metadata_file="$root/tools/skill-bootstrap/tool.json"
tool_script_file="$root/tools/skill-bootstrap/bootstrap-skills.sh"
agent_metadata_file="$root/agents/react-frontend/agent-metadata.json"
agent_definition_file="$root/agents/react-frontend/agent.json"

test -f "$metadata_file"
test -f "$second_metadata_file"
test -f "$validation_skill_file"
test -f "$submit_skill_file"
test -f "$validation_reference_file"
test -f "$submit_reference_file"
test -f "$flake_file"
test -f "$module_file"
test -f "$example_module_file"
test -f "$tool_metadata_file"
test -f "$tool_script_file"
test -f "$agent_metadata_file"
test -f "$agent_definition_file"

jq -e '
  .id == "expo-build-validation" and
  .kind == "skill" and
  (.runtimePackages | index("jq")) != null and
  (.supportedAgents | index("codex")) != null
' "$metadata_file" >/dev/null

jq -e '
  .id == "expo-build-submit" and
  .kind == "skill" and
  (.runtimePackages | index("jq")) != null and
  (.helperTools | index("skill-bootstrap")) != null
' "$second_metadata_file" >/dev/null

grep -q '^name: expo-build-validation$' "$validation_skill_file"
grep -q '^name: expo-build-submit$' "$submit_skill_file"

if rg -q '^(allowed-tools|metadata):' "$validation_skill_file"; then
  echo "expo-build-validation SKILL.md still contains legacy frontmatter" >&2
  exit 1
fi

if rg -q '^(allowed-tools|metadata):' "$submit_skill_file"; then
  echo "expo-build-submit SKILL.md still contains legacy frontmatter" >&2
  exit 1
fi

jq -e '
  .id == "skill-bootstrap" and
  .kind == "tool" and
  .packageName == "skill-bootstrap" and
  .entrypoint == "tools/skill-bootstrap/bootstrap-skills.sh"
' "$tool_metadata_file" >/dev/null

jq -e '
  .id == "react-frontend" and
  .kind == "agent" and
  .definitionFile == "agents/react-frontend/agent.json" and
  (.supportedAgents | index("kiro-cli")) != null and
  (.skillIds | index("react-project-init")) != null
' "$agent_metadata_file" >/dev/null

flake_ref="path:$root"
current_system="$(nix eval --impure --expr 'builtins.currentSystem' --raw)"

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let flake = builtins.getFlake \"$flake_ref\";
  in flake.skillMetadata.expo-build-validation.id
" >/dev/null

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let flake = builtins.getFlake \"$flake_ref\";
  in flake.skillMetadata.expo-build-submit.id
" >/dev/null

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let flake = builtins.getFlake \"$flake_ref\";
  in flake.toolMetadata.skill-bootstrap.id
" >/dev/null

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let flake = builtins.getFlake \"$flake_ref\";
  in flake.agentMetadata.react-frontend.id
" >/dev/null

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let
    flake = builtins.getFlake \"$flake_ref\";
  in flake.packages.${current_system}.skill-bootstrap.name
" >/dev/null

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let flake = builtins.getFlake \"$flake_ref\";
  in builtins.isFunction flake.homeManagerModules.default
" >/dev/null

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let flake = builtins.getFlake \"$flake_ref\";
  in builtins.isFunction (import (flake.outPath + \"/nix/examples/combined-home-manager.nix\"))
" >/dev/null
