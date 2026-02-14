---
status: draft
created: 2026-02-14
updated: 2026-02-14
type: planning
lifecycle: persistent
---

# NixClaw Design Document

> Personal AI agent platform deeply integrated with NixOS

## Summary

NixClaw is an always-on, plugin-based AI agent that runs as a native NixOS service. It combines a personal assistant (Telegram), NixOS system manager, and development workflow orchestrator into a single declaratively-configured platform.

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Runtime | TypeScript (Node.js) | Matches existing MCP/Node ecosystem, event-driven model suits always-on agents |
| AI Backend | Claude API (primary) | Existing infrastructure, deep experience, best tool-use support |
| Architecture | Plugin-based monolith | Nix-like composability without microservice overhead |
| State | SQLite | Zero-config, single-file, declarative state directory |
| NixOS Integration | Flake input + NixOS module | First-class citizen: `services.nixclaw.enable = true` |
| Messaging | Telegram (`grammy`), Terminal, Web UI | Telegram for mobile, Terminal + Web UI for local control |
| Security | systemd hardening + propose-only system changes | Agent reads and proposes; user approves and rebuilds |

## Architecture

### Core Components

```
nixclaw/
├── package.json
├── tsconfig.json
├── flake.nix                # Build + NixOS module
├── src/
│   ├── core/
│   │   ├── agent.ts         # Event-driven agent loop
│   │   ├── event-bus.ts     # Internal pub/sub
│   │   ├── state.ts         # SQLite persistence
│   │   ├── config.ts        # NixOS-generated config loader
│   │   └── plugin-host.ts   # Plugin lifecycle manager
│   ├── ai/
│   │   ├── claude.ts        # Claude API client with tool-use
│   │   ├── context.ts       # Conversation memory management
│   │   └── tools.ts         # Tool registry
│   ├── channels/
│   │   ├── telegram/        # grammy-based Telegram bot
│   │   ├── terminal/        # readline CLI
│   │   └── webui/           # fastify + htmx/solid dashboard
│   ├── tools/
│   │   ├── nixos/           # System management tools
│   │   ├── dev/             # Dev workflow tools
│   │   ├── files/           # File management
│   │   └── scheduler/       # Cron-like task scheduling
│   └── nix/
│       └── module.nix       # NixOS module definition
```

### Agent Loop

```
Channel → Event Bus → Agent Core → Claude API (with tools) → Tool Execution → Response → Channel
```

Messages from any channel are normalized to a unified format, processed by the agent core with Claude's tool-use capability, and responses routed back to the originating channel.

### Plugin Interface

```typescript
interface NixClawPlugin {
  name: string;
  version: string;
  init(ctx: PluginContext): Promise<void>;
  shutdown(): Promise<void>;
}

interface PluginContext {
  eventBus: EventBus;
  registerTool: (tool: Tool) => void;
  state: StateStore;
  config: PluginConfig;
  logger: Logger;
}
```

### Unified Message Model

```typescript
interface NixClawMessage {
  id: string;
  channel: string;           // "telegram" | "terminal" | "webui"
  sender: string;
  text: string;
  attachments?: Attachment[];
  replyTo?: string;
  timestamp: Date;
}
```

## Channel Plugins

| Channel | Library | Config Key | Notes |
|---|---|---|---|
| Telegram | `grammy` | `channels.telegram.botTokenFile` | Full bot API: text, images, inline keyboards, voice |
| Terminal | built-in (readline) | always available | Interactive CLI, pipe-friendly |
| Web UI | `fastify` + `htmx`/`solid` | `channels.webui.port` | Dashboard: conversations, system status, task queue, live logs |

## Tool Plugins

### NixOS Tools

- `nixclaw_flake_check` — validate flake configuration
- `nixclaw_flake_read` — read and understand flake structure
- `nixclaw_package_search` — search nixpkgs
- `nixclaw_option_search` — search NixOS options
- `nixclaw_system_status` — current generation, uptime, services
- `nixclaw_service_status` — systemd service health
- `nixclaw_config_edit` — propose config changes (user approves)
- `nixclaw_rebuild_request` — queue rebuild notification
- `nixclaw_generation_diff` — compare system generations

### Dev Tools

- `nixclaw_git_status` — repo status across projects
- `nixclaw_run_tests` — run tests in devenv
- `nixclaw_code_review` — review staged changes
- `nixclaw_task_schedule` — schedule tasks
- `nixclaw_morning_brief` — daily summary

### Scheduler

Replaces cron-based scripts with declarative NixOS-configured tasks:

```nix
services.nixclaw.scheduler.tasks = {
  morning-brief = {
    schedule = "0 7 * * *";
    action = "Generate morning briefing";
    channel = "telegram";
  };
};
```

## NixOS Module

### Configuration Interface

```nix
services.nixclaw = {
  enable = true;
  ai.provider = "claude";
  ai.model = "claude-sonnet-4-5-20250929";
  ai.apiKeyFile = config.age.secrets.anthropic-key.path;
  channels.telegram.enable = true;
  channels.telegram.botTokenFile = config.age.secrets.telegram-bot.path;
  channels.webui.enable = true;
  channels.webui.port = 3333;
  tools.nixos.enable = true;
  tools.nixos.flakePath = "/home/guyfawkes/nixos-config";
  tools.dev.enable = true;
  stateDir = "/var/lib/nixclaw";
};
```

### Systemd Service

- `DynamicUser = true` for automatic user creation
- `ProtectSystem = "strict"` — read-only filesystem
- `ProtectHome = "read-only"` — can read config, not write arbitrary files
- `ReadWritePaths` — only stateDir and flakePath
- `NoNewPrivileges = true`
- `PrivateTmp = true`

### Flake Integration

Consumed as a flake input in nixos-config:

```nix
inputs.nixclaw.url = "github:username/nixclaw";
```

## Security Model

| Boundary | Mechanism |
|---|---|
| Secrets | agenix/sops-nix — never plaintext in store |
| Process | systemd hardening (DynamicUser, ProtectSystem, NoNewPrivileges) |
| Filesystem | Read-only home, write only to stateDir and flakePath |
| System changes | Propose-only: NixClaw suggests, user rebuilds |
| Network | Outbound only (APIs). Web UI on localhost/LAN |

## Open Source Tools Used

| Component | Tool | License |
|---|---|---|
| AI Client | `@anthropic-ai/sdk` | MIT |
| Telegram | `grammy` | MIT |
| Web Framework | `fastify` | MIT |
| Database | `better-sqlite3` | MIT |
| Build | `esbuild` / `tsup` | MIT |
| NixOS | `buildNpmPackage` | Nix ecosystem |

## Migration Path

Existing scripts that NixClaw replaces over time:

| Current Script | NixClaw Equivalent |
|---|---|
| `claude-autonomous.sh` | Agent core + tool execution |
| `claude-night-batch.sh` | Scheduler plugin |
| `claude-morning-review.sh` | Morning brief scheduled task |
| Manual Claude Code sessions | Telegram commands |

## Repository

Separate repo: `github:username/nixclaw`
Consumed as flake input by nixos-config.
