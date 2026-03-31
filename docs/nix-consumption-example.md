# Nix Consumption Example

This repo exposes:

- `skillMetadata`
- `toolMetadata`
- `agentMetadata`
- `homeManagerModules.default`

Example flake input:

```nix
inputs.agent-skills-reference.url = "github:gmackorg/agent-skills";
```

Example Home Manager usage:

```nix
{
  imports = [
    inputs.agent-skills-reference.homeManagerModules.default
  ];

  programs.agent-skills = {
    enable = true;
    skillIds = [ "*" ];
    agentIds = [ "*" ];
  };
}
```

In a real setup, import one public repo and one private repo, then merge them in your machine config rather than treating this reference repo as production content.
