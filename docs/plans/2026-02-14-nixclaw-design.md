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

NixClaw is an always-on, MCP-native AI agent that runs as a NixOS systemd service. It combines a personal voice assistant (Telegram), NixOS system manager, and development workflow orchestrator into a single declaratively-configured platform. External services (email, calendar, messaging) are handled via pluggable MCP servers rather than custom integrations.

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Runtime | TypeScript (Node.js) | Matches existing MCP/Node ecosystem, event-driven model suits always-on agents |
| AI Backend | Claude API (primary) | Existing infrastructure, deep experience, best tool-use support |
| Architecture | Plugin-based monolith + MCP client | Local plugins for NixOS/dev tools, MCP servers for external services |
| State | SQLite | Zero-config, single-file, declarative state directory |
| NixOS Integration | Flake input + NixOS module | First-class citizen: `services.nixclaw.enable = true` |
| Channels | Telegram (`grammy`), Terminal, Web UI | Telegram (voice + text) for mobile, Terminal + Web UI for local control |
| External Tools | MCP servers (Rube, sunsama, etc.) | Pluggable, standard protocol, 600+ services via Rube alone |
| Voice Input | Telegram voice messages + Whisper/Claude multimodal | Async voice notes, natural mobile UX |
| Voice Output | ElevenLabs (cloud) or Piper (local) | TTS for voice responses on Telegram |
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
│   │   ├── mcp-client.ts    # MCP protocol client — connects to MCP servers
│   │   ├── state.ts         # SQLite persistence
│   │   ├── config.ts        # NixOS-generated config loader
│   │   └── plugin-host.ts   # Plugin lifecycle manager
│   ├── ai/
│   │   ├── claude.ts        # Claude API client with tool-use
│   │   └── context.ts       # Conversation memory management
│   ├── voice/
│   │   ├── stt.ts           # Speech-to-text (Whisper local or Claude multimodal)
│   │   └── tts.ts           # Text-to-speech (ElevenLabs or Piper)
│   ├── channels/
│   │   ├── telegram/        # grammy-based bot (text + voice messages)
│   │   ├── terminal/        # readline CLI
│   │   └── webui/           # fastify dashboard
│   ├── tools/               # LOCAL-ONLY tools (NixOS-specific, no MCP server exists)
│   │   ├── nixos/           # System management tools
│   │   └── dev/             # Dev workflow tools (git, tmux, tests)
│   └── nix/
│       └── module.nix       # NixOS module definition
```

### Tool Strategy: Local Plugins + MCP Servers

```
NixClaw Agent
├── Local Plugins (custom, NixOS-specific)
│   ├── tools/nixos/ → nix flake check, systemctl, generation diffs
│   └── tools/dev/   → git status, tmux sessions, test runner
│
└── MCP Client (standard protocol, pluggable)
    ├── Rube MCP       → Gmail, WhatsApp, Slack, Notion (600+ apps)
    ├── mcp-sunsama    → Calendar, tasks
    ├── mcp-nixos      → NixOS package/option search
    ├── server-memory  → Persistent memory
    ├── playwright     → Browser automation
    └── (any future MCP server — auto-discovered)
```

Local plugins handle things that require direct system access (systemctl, nix commands, git).
MCP servers handle everything else via the standard Model Context Protocol.

### Agent Loop

```
Channel (text or voice) → Event Bus → Agent Core
                                         │
                            ┌────────────┼────────────┐
                            ▼            ▼            ▼
                       Local Tools   MCP Tools   Claude API
                            │            │            │
                            └────────────┼────────────┘
                                         ▼
                                    Response
                                         │
                              ┌──────────┼──────────┐
                              ▼          ▼          ▼
                           Text      Voice (TTS)  Both
                              │          │          │
                              └──────────┼──────────┘
                                         ▼
                                  Event Bus → Channel
```

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
  config: Record<string, unknown>;
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
  audio?: Buffer;            // Voice message audio (Telegram voice notes)
  attachments?: Attachment[];
  replyTo?: string;
  timestamp: Date;
}
```

## Channel Plugins

| Channel | Library | Config Key | Notes |
|---|---|---|---|
| Telegram | `grammy` | `channels.telegram.botTokenFile` | Text + voice messages, inline keyboards, images |
| Terminal | built-in (readline) | always available | Interactive CLI, pipe-friendly |
| Web UI | `fastify` | `channels.webui.port` | Dashboard: conversations, system status, task queue |

## Voice Interaction

Primary workflow: user sends voice messages on Telegram while mobile.

### Speech-to-Text (Input)

| Provider | Type | Config |
|---|---|---|
| Claude multimodal (default) | Cloud | Send audio directly to Claude API — simplest, no extra deps |
| Whisper | Local | Uses existing `whisper-dictation` flake input — free, private |

### Text-to-Speech (Output)

| Provider | Type | Config |
|---|---|---|
| ElevenLabs (default) | Cloud API | Best voice quality, ~$5/mo |
| Piper | Local | `pkgs.piper-tts` in nixpkgs — free, decent quality |
| None | — | Text-only responses (no voice reply) |

### Telegram Voice Flow

```
User records voice → Telegram sends .ogg → NixClaw downloads audio
→ STT transcription → Claude processes → response text
→ TTS synthesis → NixClaw sends voice message back on Telegram
```

## Local Tool Plugins

Only for tools that require direct system access:

### NixOS Tools

- `nixclaw_flake_check` — validate flake configuration
- `nixclaw_system_status` — current generation, uptime, services
- `nixclaw_service_status` — systemd service health
- `nixclaw_config_edit` — propose config changes (user approves)
- `nixclaw_rebuild_request` — queue rebuild notification
- `nixclaw_generation_diff` — compare system generations

### Dev Tools

- `nixclaw_git_status` — repo status across projects
- `nixclaw_run_tests` — run tests in devenv
- `nixclaw_claude_sessions` — list running Claude autonomous sessions

### Scheduler

```nix
services.nixclaw.scheduler.tasks = {
  morning-brief = {
    schedule = "0 7 * * *";
    action = "Generate morning briefing with system status, calendar, and email summary";
    channel = "telegram";
  };
};
```

## MCP Servers (External Tools)

Everything else comes from pluggable MCP servers:

| Server | What it provides |
|---|---|
| Rube | Gmail, WhatsApp, Slack, Notion, GitHub, Google Drive (600+ apps) |
| mcp-sunsama | Calendar events, task management |
| mcp-nixos | NixOS package/option search |
| server-memory | Persistent memory across conversations |
| playwright | Browser automation |

MCP servers are configured declaratively in the NixOS module and auto-discovered at startup.

## NixOS Module

### Configuration Interface

```nix
services.nixclaw = {
  enable = true;

  # AI
  ai.provider = "claude";
  ai.model = "claude-sonnet-4-5-20250929";
  ai.apiKeyFile = config.age.secrets.anthropic-key.path;

  # Channels
  channels.telegram = {
    enable = true;
    botTokenFile = config.age.secrets.telegram-bot.path;
    allowedUsers = [ "123456789" ];  # Telegram user IDs
  };
  channels.webui = {
    enable = true;
    port = 3333;
  };

  # Voice
  voice.stt.provider = "claude";  # or "whisper"
  voice.tts.provider = "elevenlabs";  # or "piper" or "none"
  voice.tts.elevenlabs.apiKeyFile = config.age.secrets.elevenlabs-key.path;
  voice.tts.elevenlabs.voiceId = "voice-id-here";

  # Local tools
  tools.nixos.enable = true;
  tools.nixos.flakePath = "/home/guyfawkes/nixos-config";
  tools.dev.enable = true;

  # MCP servers (pluggable external tools)
  mcp.servers = {
    rube = {
      command = "npx";
      args = [ "-y" "rube-mcp@latest" ];
      env.COMPOSIO_API_KEY_FILE = config.age.secrets.rube-key.path;
    };
    sunsama = {
      command = "npx";
      args = [ "-y" "mcp-sunsama" ];
      env.SUNSAMA_API_KEY_FILE = config.age.secrets.sunsama-key.path;
    };
    memory = {
      command = "npx";
      args = [ "-y" "@modelcontextprotocol/server-memory" ];
    };
    nixos = {
      command = "mcp-nixos";
    };
  };

  # Scheduler
  scheduler.tasks = {
    morning-brief = {
      schedule = "0 7 * * *";
      action = "Morning briefing: system status, calendar, urgent emails";
      channel = "telegram";
    };
  };

  # State
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
- `Restart = "on-failure"` with `RestartSec = 10`

### Flake Integration

Consumed as a flake input in nixos-config:

```nix
inputs.nixclaw.url = "github:jacopone/nixclaw";
```

## Security Model

| Boundary | Mechanism |
|---|---|
| Secrets | agenix/sops-nix — never plaintext in store |
| Process | systemd hardening (DynamicUser, ProtectSystem, NoNewPrivileges) |
| Filesystem | Read-only home, write only to stateDir and flakePath |
| System changes | Propose-only: NixClaw suggests, user rebuilds |
| Telegram | allowedUsers whitelist — only configured user IDs can interact |
| MCP servers | Each server runs as a child process with its own credentials |
| Network | Outbound only (APIs). Web UI on localhost/LAN |

## Open Source Tools Used

| Component | Tool | License |
|---|---|---|
| AI Client | `@anthropic-ai/sdk` | MIT |
| Telegram | `grammy` | MIT |
| Web Framework | `fastify` | MIT |
| Database | `better-sqlite3` | MIT |
| MCP Client | `@modelcontextprotocol/sdk` | MIT |
| TTS (local) | `piper-tts` | MIT |
| Build | `tsup` | MIT |
| NixOS | `buildNpmPackage` | Nix ecosystem |

## Migration Path

| Current | NixClaw Equivalent |
|---|---|
| `claude-autonomous.sh` | Agent core + tool execution |
| `claude-night-batch.sh` | Scheduler plugin |
| `claude-morning-review.sh` | Morning brief scheduled task |
| Manual Claude Code sessions | Telegram voice/text commands |
| `.mcp.json` (per-project) | `services.nixclaw.mcp.servers` (system-wide) |

## Repository

Separate repo: `github:jacopone/nixclaw`
Consumed as flake input by nixos-config.
