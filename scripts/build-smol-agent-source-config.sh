#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
catalog_file="$root/catalog/installable-skills.json"
output_file="${1:-$root/catalog/smol-agent.reference.json}"

jq '
  {
    sourceCatalog: {
      "agent-skills-reference": {
        url: "https://github.com/gmackorg/agent-skills",
        label: "Gmackorg Agent Skills Reference"
      }
    },
    sources: [
      { alias: "agent-skills-reference" }
    ],
    groups: (
      reduce .groups[] as $group
        ({};
         .[$group.name] = ($group.skillIds | map("agent-skills-reference:" + .)))
    ),
    agentDefinitions: {
      general: {
        sourceIds: [],
        defaultGroups: ["examples"],
        allowedArtifacts: []
      }
    },
    defaultAgentDefinition: "general"
  }
' "$catalog_file" > "$output_file"
