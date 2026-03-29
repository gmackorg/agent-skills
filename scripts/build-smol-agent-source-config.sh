#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
catalog_file="$root/catalog/installable-skills.json"
output_file="${1:-$root/catalog/smol-agent.reference.json}"

jq '
  {
    sourceCatalog: {
      "agent-skills": {
        url: "https://github.com/gmackorg/agent-skills",
        label: "Gmackorg Agent Skills"
      }
    },
    sources: [
      { alias: "agent-skills" }
    ],
    groups: (
      reduce .groups[] as $group
        ({};
         .[$group.name] = ($group.skillIds | map("agent-skills:" + .)))
    ),
    agentDefinitions: {
      general: {
        sourceIds: [],
        defaultGroups: ["workflow-meta"],
        allowedArtifacts: []
      },
      mobile: {
        sourceIds: [],
        defaultGroups: ["workflow-meta", "mobile-qa", "expo"],
        allowedArtifacts: []
      },
      web: {
        sourceIds: [],
        defaultGroups: ["workflow-meta", "react", "nextjs-saas", "cloudflare"],
        allowedArtifacts: []
      }
    },
    defaultAgentDefinition: "general"
  }
' "$catalog_file" > "$output_file"
