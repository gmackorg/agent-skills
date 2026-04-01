# OpenClaw Plugin Example

This reference repo exports a minimal `openclawPlugin` output in `flake.nix`.

It demonstrates the contract used by `nix-openclaw`:

- `name`
- `skills`
- `packages`
- `needs`

## Why This Example Is Small

The goal is to show how an `agent-skills` repo can be consumed by OpenClaw without making the whole repo OpenClaw-specific.

This example only exposes:

- the two example skills in `skills/`
- the helper tool package shape
- a minimal `needs` block

## Example Consumption

In a real OpenClaw config, a plugin can be referenced by source:

```nix
programs.openclaw.instances.default.plugins = [
  { source = "github:gmackorg/agent-skills"; }
];
```

Or from a local checkout:

```nix
programs.openclaw.instances.default.plugins = [
  { source = "path:/Users/you/code/agent-skills"; }
];
```

## Reference Rule

The OpenClaw adapter should be thin:

- OpenClaw chooses which skills to expose
- the repo stays the source of truth for content
- the skill format does not become OpenClaw-specific

That same principle should apply to Codex, Claude, `smol-agent`, and other runtimes.
