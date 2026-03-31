#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

metadata_file="$root/skills/expo-build-validation/skill.json"
second_metadata_file="$root/skills/expo-build-submit/skill.json"
validation_skill_file="$root/skills/expo-build-validation/SKILL.md"
submit_skill_file="$root/skills/expo-build-submit/SKILL.md"
nextjs_project_init_skill_file="$root/skills/nextjs-project-init/SKILL.md"
saas_turbo_bootstrap_skill_file="$root/skills/saas-turbo-bootstrap/SKILL.md"
stripe_skill_file="$root/skills/stripe-payments-integration/SKILL.md"
validation_reference_file="$root/skills/expo-build-validation/references/release-validation-checklist.md"
submit_reference_file="$root/skills/expo-build-submit/references/submission-sequence.md"
installable_config_file="$root/catalog/installable-skills.json"
installable_config_verifier="$root/scripts/verify-installable-skills-config.sh"
smol_agent_reference_file="$root/catalog/smol-agent.reference.json"
smol_agent_builder="$root/scripts/build-smol-agent-source-config.sh"
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
test -f "$nextjs_project_init_skill_file"
test -f "$saas_turbo_bootstrap_skill_file"
test -f "$stripe_skill_file"
test -f "$validation_reference_file"
test -f "$submit_reference_file"
test -f "$installable_config_file"
test -f "$installable_config_verifier"
test -f "$smol_agent_reference_file"
test -f "$smol_agent_builder"
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

if rg -q 'Clerk|clerk' "$nextjs_project_init_skill_file"; then
  echo "nextjs-project-init still contains Clerk-specific guidance" >&2
  exit 1
fi

if rg -q 'Clerk|clerk' "$saas_turbo_bootstrap_skill_file"; then
  echo "saas-turbo-bootstrap still contains Clerk-specific guidance" >&2
  exit 1
fi

if rg -q 'Clerk|clerk' "$stripe_skill_file"; then
  echo "stripe-payments-integration still contains Clerk-specific guidance" >&2
  exit 1
fi

"$installable_config_verifier"
chmod +x "$smol_agent_builder"
"$smol_agent_builder" "$root/catalog/smol-agent.reference.generated.json"
cmp -s "$smol_agent_reference_file" "$root/catalog/smol-agent.reference.generated.json"
rm "$root/catalog/smol-agent.reference.generated.json"

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
