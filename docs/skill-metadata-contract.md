# Skill Metadata Contract

This repo uses a simple split:

- `SKILL.md`: agent-facing instructions
- `skill.json`: machine-facing metadata

## Example `skill.json`

```json
{
  "id": "example-reference-skill",
  "kind": "skill",
  "version": 1,
  "runtimePackages": ["bash"],
  "supportedAgents": ["codex", "claude-code"],
  "helperTools": [],
  "mcpServers": [],
  "outputs": {
    "skillPath": "skills/example-reference-skill",
    "skillFile": "skills/example-reference-skill/SKILL.md"
  }
}
```

## Related Files

- `tools/<tool-name>/tool.json`
- `agents/<agent-name>/agent-metadata.json`

This contract is intentionally small. Teams can extend it in their own repos if needed.
