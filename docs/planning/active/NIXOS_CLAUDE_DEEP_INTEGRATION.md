---
status: draft
created: 2025-12-26
updated: 2025-12-26
type: planning
lifecycle: persistent
---

# NixOS ↔ Claude Deep Integration Vision

> **Status**: Vision document / Future exploration
> **Created**: 2025-12-26
> **Context**: Conversation about transforming NixOS into a "ClaudeOS" where flakes define AI behavior
> **Safety**: This is a REFERENCE DOCUMENT - no changes to working config

---

## The Core Vision

**The flake IS the Claude context.** No generation step, no separate CLAUDE.md. Claude understands Nix as its native instruction format.

### Why This Matters

| Nix Concept | Claude Analog |
|-------------|---------------|
| `flake.nix` | System prompt + tool manifest |
| Nix attrsets | Tool definitions (JSON Schema) |
| Nix derivations | MCP servers |
| Nix modules | Composable contexts |
| `flake.lock` | Pinned behavior version |
| `pkgs` | Available capabilities |

---

## Current Setup (DO NOT MODIFY)

Your working integration:
- `~/nixos-config` - Main NixOS flake
- `~/claude-nixos-automation` - CLAUDE.md generation tools
- `./rebuild-nixos` → parses nix → generates CLAUDE.md

**This works well. The vision below is ADDITIVE exploration, not replacement.**

---

## Architecture: Three Integration Layers

### Layer 1: Nix → MCP Server Generator

A Nix function that produces MCP server derivations from tool definitions.

**Concept:** Define tools as Nix attrsets, output a runnable MCP server.

```nix
# lib/mkMcpServer.nix - conceptual
{ pkgs }:
{ name, tools }:
pkgs.writeShellScriptBin "mcp-${name}" ''
  # Node.js MCP server that exposes tools
  # Each tool maps to a shell command wrapper
''
```

**Usage pattern:**
```nix
packages.mcp-nix-tools = mkMcpServer {
  name = "nix-tools";
  tools = [
    {
      name = "nix-search";
      description = "Search nixpkgs for a package";
      inputSchema = {
        type = "object";
        properties.query = { type = "string"; };
        required = ["query"];
      };
      command = "nix search nixpkgs";
    }
  ];
};
```

### Layer 2: NixOS Module for Claude Context

Use NixOS module system to compose Claude behavior declaratively:

```nix
# modules/claude/default.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.claude = {
    enable = mkEnableOption "Claude Code integration";

    persona = mkOption {
      type = types.str;
      default = "You are a helpful assistant";
    };

    tools = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          pkg = mkOption { type = types.package; };
          preferOver = mkOption { type = types.listOf types.str; default = []; };
          examples = mkOption { type = types.listOf types.str; default = []; };
          alwaysApprove = mkOption { type = types.bool; default = false; };
        };
      });
      default = {};
    };

    policies = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };

    mcpServers = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf config.claude.enable {
    # Generate ~/.claude/settings.json from Nix evaluation
    home.file.".claude/settings.json".text = builtins.toJSON {
      tools = mapAttrs (name: tool: {
        package = tool.pkg.name;
        preferOver = tool.preferOver;
      }) config.claude.tools;

      mcpServers = map (s: {
        command = "${s}/bin/${s.pname}";
        transport = "stdio";
      }) config.claude.mcpServers;
    };
  };
}
```

**Usage:**
```nix
{
  claude = {
    enable = true;
    persona = "You are a NixOS expert. Prefer declarative solutions.";

    tools = {
      search = {
        pkg = pkgs.ripgrep;
        preferOver = ["grep" "ack"];
        alwaysApprove = true;
      };
      find = {
        pkg = pkgs.fd;
        preferOver = ["find" "locate"];
      };
    };

    policies = {
      commits = "Never use --no-verify without asking";
      rebuild = "Suggest ./rebuild-nixos, never run directly";
    };
  };
}
```

### Layer 3: Flake as API Spec

The flake itself becomes the Claude API definition:

```nix
{
  outputs = { self, nixpkgs, ... }: {

    # Standard NixOS config
    nixosConfigurations.myhost = ...;

    # NEW: Claude context as first-class flake output
    claudeContext = {
      version = "2025-01";

      system = {
        type = "NixOS";
        version = "25.11";
        desktop = "GNOME";
        shell = "fish";
      };

      tools = import ./claude/tools.nix { inherit nixpkgs; };
      constraints = import ./claude/constraints.nix;

      skills = [
        ./claude/skills/nix-packaging.nix
        ./claude/skills/home-manager.nix
      ];

      autoApprove = [
        "Bash(nix *)"
        "Bash(git *)"
        "Read(*.nix)"
      ];
    };

    # MCP servers as derivations
    packages.x86_64-linux.mcp-nixos = mkMcpServer { ... };
  };
}
```

---

## Anthropic API Integration Points

From research on `platform.claude.com/docs`:

### Messages API
- **System prompt**: Can be string or array with cache_control
- **Tools**: Array of JSON Schema definitions
- **Prompt caching**: 5-minute or 1-hour TTL for static context
- **Extended thinking**: `thinking.budget_tokens` for complex reasoning

### MCP Protocol
- **JSON-RPC 2.0** over stdio or HTTP+SSE
- **tools/list**: Dynamic tool discovery
- **tools/call**: Run with arguments, return content blocks
- **resources/read**: Access data sources
- **prompts/get**: Reusable prompt templates

### Key Integration Points
1. Tool definitions from Nix attrsets → JSON Schema
2. MCP servers as Nix derivations
3. Prompt caching for static system context
4. flake.lock pins behavior version

---

## Phased Implementation

### Phase 1: Proof of Concept (Safe to Experiment)
- [ ] Nix function that generates CLAUDE.md from attrsets
- [ ] Simple MCP server derivation generator
- [ ] Home-manager module for Claude Code settings
- [ ] Test in isolated branch/flake

### Phase 2: Deep Integration
- [ ] Claude API wrapper reading flake outputs
- [ ] Dynamic tool registration from Nix evaluation
- [ ] Prompt caching for system context

### Phase 3: ClaudeOS Vision
- [ ] Native Nix understanding in Claude
- [ ] Flake-aware tool discovery
- [ ] NixOS as first-class platform

---

## What This Enables

1. **`nix flake lock` pins AI behavior** - Reproducible assistant across machines
2. **Flake inputs for shared contexts** - `inputs.company-standards.claudeContext`
3. **Type-checked AI config** - Nix validates Claude configuration
4. **Auditable AI** - `git blame` on why Claude does something
5. **Module composition** - Personal preferences overlay team defaults
6. **Derivation-as-capability** - If it builds, Claude can use it

---

## The Philosophical Insight

**Nix and Claude solve the same problem:**

- Nix: "How do I declaratively specify a reproducible system?"
- Claude: "How do I declaratively specify reproducible behavior?"

**The answer is the same language.** A flake that builds your OS should also configure your AI.

---

## Safe Experimentation Path

When you're ready to explore:

1. **Create isolated experiment branch:**
   ```bash
   git checkout -b claude-nix-integration
   ```

2. **Start with read-only exploration:**
   - Test if Claude can already read packages.nix semantically
   - Try minimal CLAUDE.md that points to Nix files

3. **Prototype in separate flake:**
   ```bash
   mkdir ~/claude-nix-experiment
   cd ~/claude-nix-experiment
   nix flake init
   ```

4. **Never touch working config until proven in isolation**

---

## Key Proof Already Demonstrated

In our conversation, I read your `packages.nix` and `flake.nix` directly and understood:
- Your modern CLI preferences (rg, fd, bat, eza, dust, procs)
- Your AI toolkit (Claude Code, Cursor, Antigravity, Gemini, Jules, Droid)
- Your system philosophy ("always latest" via npx wrappers)
- Your maintained projects in flake inputs

**This proves the concept works today.** Claude CAN read Nix semantically.

---

## References

- Anthropic Messages API: https://platform.claude.com/docs/en/api/messages
- MCP Specification: https://modelcontextprotocol.io/
- Your repos:
  - https://github.com/jacopone/nixos-config
  - https://github.com/jacopone/claude-nixos-automation

---

## To Resume This Work

When ready, start a new Claude session and say:
> "Read docs/planning/active/NIXOS_CLAUDE_DEEP_INTEGRATION.md and let's continue the NixOS-Claude integration vision"

---

*This vision document preserved for future exploration. Your current setup remains untouched.*
