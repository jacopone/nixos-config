---
status: draft
created: 2026-02-14
updated: 2026-02-14
type: planning
lifecycle: persistent
---

# NixClaw Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build NixClaw, an MCP-native AI agent with voice support that runs as a NixOS service with Telegram (text + voice), Terminal, and Web UI channels.

**Architecture:** Event-driven plugin monolith with MCP client. Local plugins for NixOS/dev tools, MCP servers for external services (email, calendar, messaging via Rube/sunsama/etc). Voice interaction via Telegram voice messages (STT: Claude multimodal, TTS: ElevenLabs/Piper). State in SQLite. Declaratively configured via NixOS module (`services.nixclaw`).

**Tech Stack:** TypeScript, Node.js, vitest, grammy (Telegram), @anthropic-ai/sdk (Claude), @modelcontextprotocol/sdk (MCP client), fastify (Web UI), better-sqlite3 (state), tsup (build), Nix flakes + buildNpmPackage.

**Design Doc:** `docs/plans/2026-02-14-nixclaw-design.md` (in nixos-config repo)

---

## Phase 1: Project Bootstrap

### Task 1: Initialize repository and TypeScript project

**Files:**
- Create: `package.json`
- Create: `tsconfig.json`
- Create: `.gitignore`
- Create: `src/index.ts`

**Step 1: Create the repository**

```bash
mkdir -p ~/projects/nixclaw && cd ~/projects/nixclaw
git init
```

**Step 2: Create package.json**

```json
{
  "name": "nixclaw",
  "version": "0.1.0",
  "description": "Personal AI agent platform deeply integrated with NixOS",
  "type": "module",
  "main": "dist/index.js",
  "bin": {
    "nixclaw": "dist/index.js"
  },
  "scripts": {
    "build": "tsup",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "tsc --noEmit"
  },
  "engines": {
    "node": ">=20"
  },
  "license": "MIT"
}
```

**Step 3: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "types": ["node"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

**Step 4: Create tsup.config.ts**

```typescript
import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts"],
  format: ["esm"],
  target: "node20",
  outDir: "dist",
  clean: true,
  sourcemap: true,
  banner: { js: "#!/usr/bin/env node" },
});
```

**Step 5: Create .gitignore**

```
node_modules/
dist/
result
.direnv/
*.db
*.db-journal
```

**Step 6: Install dependencies**

```bash
npm install @anthropic-ai/sdk better-sqlite3 grammy fastify zod
npm install -D typescript tsup tsx vitest @types/node @types/better-sqlite3
```

**Step 7: Create minimal src/index.ts**

```typescript
console.log("nixclaw v0.1.0");
```

**Step 8: Verify build works**

```bash
npm run build
node dist/index.js
# Expected: "nixclaw v0.1.0"
```

**Step 9: Commit**

```bash
git add -A
git commit -m "feat: initialize nixclaw TypeScript project"
```

---

### Task 2: Create Nix flake with buildNpmPackage

**Files:**
- Create: `flake.nix`
- Create: `nix/module.nix` (stub)

**Step 1: Create flake.nix**

```nix
{
  description = "NixClaw - Personal AI agent platform for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildNpmPackage {
        pname = "nixclaw";
        version = "0.1.0";
        src = ./.;
        npmDepsHash = ""; # Will be filled after first build attempt
        nodejs = pkgs.nodejs_22;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin $out/lib/nixclaw
          cp -r dist/* $out/lib/nixclaw/
          cp -r node_modules $out/lib/nixclaw/
          cat > $out/bin/nixclaw <<EOF
          #!/bin/sh
          exec ${pkgs.nodejs_22}/bin/node $out/lib/nixclaw/index.js "\$@"
          EOF
          chmod +x $out/bin/nixclaw
          runHook postInstall
        '';
      };

      nixosModules.default = import ./nix/module.nix { inherit self; };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_22
          nodePackages.typescript
          nodePackages.typescript-language-server
        ];
      };
    };
}
```

**Step 2: Create stub nix/module.nix**

```nix
{ self }:
{ config, lib, pkgs, ... }:
let
  cfg = config.services.nixclaw;
in
{
  options.services.nixclaw = {
    enable = lib.mkEnableOption "NixClaw AI agent";
  };

  config = lib.mkIf cfg.enable {
    # Filled in Phase 8
  };
}
```

**Step 3: Verify flake structure**

```bash
nix flake check
# Note: buildNpmPackage will fail until npmDepsHash is set.
# That's OK — we verify the flake parses.
nix develop --command echo "dev shell works"
```

**Step 4: Commit**

```bash
git add flake.nix nix/module.nix
git commit -m "feat: add Nix flake with buildNpmPackage and NixOS module stub"
```

---

## Phase 2: Core Infrastructure

### Task 3: Implement EventBus

**Files:**
- Create: `src/core/event-bus.ts`
- Test: `src/core/event-bus.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/core/event-bus.test.ts
import { describe, it, expect, vi } from "vitest";
import { EventBus } from "./event-bus.js";

describe("EventBus", () => {
  it("delivers events to subscribers", () => {
    const bus = new EventBus();
    const handler = vi.fn();
    bus.on("test", handler);
    bus.emit("test", { data: "hello" });
    expect(handler).toHaveBeenCalledWith({ data: "hello" });
  });

  it("supports multiple subscribers", () => {
    const bus = new EventBus();
    const h1 = vi.fn();
    const h2 = vi.fn();
    bus.on("test", h1);
    bus.on("test", h2);
    bus.emit("test", "payload");
    expect(h1).toHaveBeenCalledWith("payload");
    expect(h2).toHaveBeenCalledWith("payload");
  });

  it("unsubscribes correctly", () => {
    const bus = new EventBus();
    const handler = vi.fn();
    const off = bus.on("test", handler);
    off();
    bus.emit("test", "payload");
    expect(handler).not.toHaveBeenCalled();
  });

  it("does not cross-deliver between event names", () => {
    const bus = new EventBus();
    const handler = vi.fn();
    bus.on("a", handler);
    bus.emit("b", "payload");
    expect(handler).not.toHaveBeenCalled();
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/core/event-bus.test.ts
# Expected: FAIL — module not found
```

**Step 3: Implement EventBus**

```typescript
// src/core/event-bus.ts
type Handler = (payload: unknown) => void;

export class EventBus {
  private listeners = new Map<string, Set<Handler>>();

  on(event: string, handler: Handler): () => void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(handler);
    return () => {
      this.listeners.get(event)?.delete(handler);
    };
  }

  emit(event: string, payload: unknown): void {
    for (const handler of this.listeners.get(event) ?? []) {
      handler(payload);
    }
  }
}
```

**Step 4: Run tests to verify they pass**

```bash
npx vitest run src/core/event-bus.test.ts
# Expected: 4 passed
```

**Step 5: Commit**

```bash
git add src/core/event-bus.ts src/core/event-bus.test.ts
git commit -m "feat: add EventBus for internal pub/sub"
```

---

### Task 4: Implement StateStore (SQLite)

**Files:**
- Create: `src/core/state.ts`
- Test: `src/core/state.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/core/state.test.ts
import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { StateStore } from "./state.js";
import { unlinkSync } from "node:fs";

const TEST_DB = "/tmp/nixclaw-test.db";

describe("StateStore", () => {
  let store: StateStore;

  beforeEach(() => {
    store = new StateStore(TEST_DB);
  });

  afterEach(() => {
    store.close();
    try { unlinkSync(TEST_DB); } catch {}
  });

  it("stores and retrieves values", () => {
    store.set("ns", "key1", "value1");
    expect(store.get("ns", "key1")).toBe("value1");
  });

  it("returns undefined for missing keys", () => {
    expect(store.get("ns", "missing")).toBeUndefined();
  });

  it("overwrites existing keys", () => {
    store.set("ns", "key1", "old");
    store.set("ns", "key1", "new");
    expect(store.get("ns", "key1")).toBe("new");
  });

  it("isolates namespaces", () => {
    store.set("a", "key", "val-a");
    store.set("b", "key", "val-b");
    expect(store.get("a", "key")).toBe("val-a");
    expect(store.get("b", "key")).toBe("val-b");
  });

  it("deletes keys", () => {
    store.set("ns", "key1", "value1");
    store.delete("ns", "key1");
    expect(store.get("ns", "key1")).toBeUndefined();
  });

  it("stores and retrieves JSON objects", () => {
    const obj = { name: "test", count: 42 };
    store.setJSON("ns", "obj", obj);
    expect(store.getJSON("ns", "obj")).toEqual(obj);
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/core/state.test.ts
# Expected: FAIL — module not found
```

**Step 3: Implement StateStore**

```typescript
// src/core/state.ts
import Database from "better-sqlite3";

export class StateStore {
  private db: Database.Database;

  constructor(dbPath: string) {
    this.db = new Database(dbPath);
    this.db.pragma("journal_mode = WAL");
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS kv (
        namespace TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        PRIMARY KEY (namespace, key)
      )
    `);
  }

  get(namespace: string, key: string): string | undefined {
    const row = this.db
      .prepare("SELECT value FROM kv WHERE namespace = ? AND key = ?")
      .get(namespace, key) as { value: string } | undefined;
    return row?.value;
  }

  set(namespace: string, key: string, value: string): void {
    this.db
      .prepare(
        `INSERT INTO kv (namespace, key, value, updated_at)
         VALUES (?, ?, ?, datetime('now'))
         ON CONFLICT (namespace, key)
         DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at`
      )
      .run(namespace, key, value);
  }

  delete(namespace: string, key: string): void {
    this.db
      .prepare("DELETE FROM kv WHERE namespace = ? AND key = ?")
      .run(namespace, key);
  }

  getJSON<T>(namespace: string, key: string): T | undefined {
    const raw = this.get(namespace, key);
    return raw ? JSON.parse(raw) : undefined;
  }

  setJSON(namespace: string, key: string, value: unknown): void {
    this.set(namespace, key, JSON.stringify(value));
  }

  close(): void {
    this.db.close();
  }
}
```

**Step 4: Run tests to verify they pass**

```bash
npx vitest run src/core/state.test.ts
# Expected: 6 passed
```

**Step 5: Commit**

```bash
git add src/core/state.ts src/core/state.test.ts
git commit -m "feat: add StateStore backed by SQLite"
```

---

### Task 5: Implement Config loader

**Files:**
- Create: `src/core/config.ts`
- Test: `src/core/config.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/core/config.test.ts
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { loadConfig, NixClawConfig } from "./config.js";

describe("loadConfig", () => {
  const originalEnv = process.env;

  afterEach(() => {
    process.env = originalEnv;
  });

  it("loads config from NIXCLAW_CONFIG env var", () => {
    const cfg: NixClawConfig = {
      ai: { provider: "claude", model: "claude-sonnet-4-5-20250929", apiKeyFile: "/run/secrets/key" },
      channels: { telegram: { enable: false }, webui: { enable: false, port: 3333 } },
      voice: { stt: { provider: "claude" }, tts: { provider: "none" } },
      tools: { nixos: { enable: false }, dev: { enable: false } },
      mcp: { servers: {} },
      stateDir: "/var/lib/nixclaw",
    };
    process.env = { ...originalEnv, NIXCLAW_CONFIG: JSON.stringify(cfg) };
    const result = loadConfig();
    expect(result.ai.provider).toBe("claude");
    expect(result.stateDir).toBe("/var/lib/nixclaw");
  });

  it("falls back to defaults when no env var is set", () => {
    process.env = { ...originalEnv };
    delete process.env.NIXCLAW_CONFIG;
    const result = loadConfig();
    expect(result.ai.provider).toBe("claude");
    expect(result.stateDir).toContain("nixclaw");
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/core/config.test.ts
# Expected: FAIL
```

**Step 3: Implement Config**

```typescript
// src/core/config.ts
import { join } from "node:path";
import { homedir } from "node:os";

export interface NixClawConfig {
  ai: {
    provider: "claude";
    model: string;
    apiKeyFile: string;
  };
  channels: {
    telegram: { enable: boolean; botTokenFile?: string; allowedUsers?: string[] };
    webui: { enable: boolean; port: number; host?: string };
  };
  voice: {
    stt: { provider: "claude" | "whisper" };
    tts: { provider: "elevenlabs" | "piper" | "none"; elevenlabs?: { apiKeyFile: string; voiceId: string } };
  };
  tools: {
    nixos: { enable: boolean; flakePath?: string; allowConfigEdits?: boolean };
    dev: { enable: boolean };
  };
  mcp: {
    servers: Record<string, { command: string; args?: string[]; env?: Record<string, string> }>;
  };
  stateDir: string;
}

const DEFAULT_CONFIG: NixClawConfig = {
  ai: {
    provider: "claude",
    model: "claude-sonnet-4-5-20250929",
    apiKeyFile: "",
  },
  channels: {
    telegram: { enable: false },
    webui: { enable: false, port: 3333 },
  },
  voice: {
    stt: { provider: "claude" },
    tts: { provider: "none" },
  },
  tools: {
    nixos: { enable: false },
    dev: { enable: false },
  },
  mcp: {
    servers: {},
  },
  stateDir: join(homedir(), ".local/share/nixclaw"),
};

export function loadConfig(): NixClawConfig {
  const envConfig = process.env.NIXCLAW_CONFIG;
  if (envConfig) {
    return { ...DEFAULT_CONFIG, ...JSON.parse(envConfig) };
  }
  return DEFAULT_CONFIG;
}
```

**Step 4: Run tests to verify they pass**

```bash
npx vitest run src/core/config.test.ts
# Expected: 2 passed
```

**Step 5: Commit**

```bash
git add src/core/config.ts src/core/config.test.ts
git commit -m "feat: add config loader with NixOS env var support"
```

---

### Task 6: Implement PluginHost

**Files:**
- Create: `src/core/plugin-host.ts`
- Create: `src/core/types.ts`
- Test: `src/core/plugin-host.test.ts`

**Step 1: Define shared types**

```typescript
// src/core/types.ts
import { z } from "zod";
import type { EventBus } from "./event-bus.js";
import type { StateStore } from "./state.js";

export interface NixClawMessage {
  id: string;
  channel: string;
  sender: string;
  text: string;
  attachments?: Array<{ type: string; url: string }>;
  replyTo?: string;
  timestamp: Date;
}

export interface Tool {
  name: string;
  description: string;
  inputSchema: z.ZodType;
  run: (input: unknown) => Promise<string>;
}

export interface PluginContext {
  eventBus: EventBus;
  registerTool: (tool: Tool) => void;
  state: StateStore;
  config: Record<string, unknown>;
  logger: Logger;
}

export interface NixClawPlugin {
  name: string;
  version: string;
  init(ctx: PluginContext): Promise<void>;
  shutdown(): Promise<void>;
}

export interface Logger {
  info(msg: string, ...args: unknown[]): void;
  warn(msg: string, ...args: unknown[]): void;
  error(msg: string, ...args: unknown[]): void;
  debug(msg: string, ...args: unknown[]): void;
}
```

**Step 2: Write the failing tests**

```typescript
// src/core/plugin-host.test.ts
import { describe, it, expect, vi } from "vitest";
import { PluginHost } from "./plugin-host.js";
import { EventBus } from "./event-bus.js";
import { StateStore } from "./state.js";
import type { NixClawPlugin, PluginContext, Tool } from "./types.js";
import { unlinkSync } from "node:fs";

const TEST_DB = "/tmp/nixclaw-pluginhost-test.db";

function makeTestPlugin(name: string, initFn?: (ctx: PluginContext) => Promise<void>): NixClawPlugin {
  return {
    name,
    version: "0.0.1",
    init: initFn ?? (async () => {}),
    shutdown: async () => {},
  };
}

describe("PluginHost", () => {
  it("initializes plugins and provides context", async () => {
    const bus = new EventBus();
    const state = new StateStore(TEST_DB);
    const host = new PluginHost(bus, state);
    const initSpy = vi.fn(async () => {});
    const plugin = makeTestPlugin("test-plugin", initSpy);

    await host.register(plugin, {});
    await host.initAll();

    expect(initSpy).toHaveBeenCalledOnce();
    state.close();
    try { unlinkSync(TEST_DB); } catch {}
  });

  it("collects registered tools from plugins", async () => {
    const bus = new EventBus();
    const state = new StateStore(TEST_DB);
    const host = new PluginHost(bus, state);

    const plugin = makeTestPlugin("tool-plugin", async (ctx) => {
      ctx.registerTool({
        name: "my_tool",
        description: "A test tool",
        inputSchema: {} as any,
        run: async () => "result",
      });
    });

    await host.register(plugin, {});
    await host.initAll();

    expect(host.getTools()).toHaveLength(1);
    expect(host.getTools()[0].name).toBe("my_tool");
    state.close();
    try { unlinkSync(TEST_DB); } catch {}
  });

  it("calls shutdown on all plugins", async () => {
    const bus = new EventBus();
    const state = new StateStore(TEST_DB);
    const host = new PluginHost(bus, state);
    const shutdownSpy = vi.fn(async () => {});
    const plugin: NixClawPlugin = {
      name: "shutdown-test",
      version: "0.0.1",
      init: async () => {},
      shutdown: shutdownSpy,
    };

    await host.register(plugin, {});
    await host.initAll();
    await host.shutdownAll();

    expect(shutdownSpy).toHaveBeenCalledOnce();
    state.close();
    try { unlinkSync(TEST_DB); } catch {}
  });
});
```

**Step 3: Run tests to verify they fail**

```bash
npx vitest run src/core/plugin-host.test.ts
# Expected: FAIL
```

**Step 4: Implement PluginHost**

```typescript
// src/core/plugin-host.ts
import type { EventBus } from "./event-bus.js";
import type { StateStore } from "./state.js";
import type { NixClawPlugin, PluginContext, Tool, Logger } from "./types.js";

function createLogger(pluginName: string): Logger {
  const prefix = `[${pluginName}]`;
  return {
    info: (msg, ...args) => console.log(prefix, msg, ...args),
    warn: (msg, ...args) => console.warn(prefix, msg, ...args),
    error: (msg, ...args) => console.error(prefix, msg, ...args),
    debug: (msg, ...args) => console.debug(prefix, msg, ...args),
  };
}

interface RegisteredPlugin {
  plugin: NixClawPlugin;
  config: Record<string, unknown>;
}

export class PluginHost {
  private plugins: RegisteredPlugin[] = [];
  private tools: Tool[] = [];

  constructor(
    private eventBus: EventBus,
    private state: StateStore,
  ) {}

  async register(plugin: NixClawPlugin, config: Record<string, unknown>): Promise<void> {
    this.plugins.push({ plugin, config });
  }

  async initAll(): Promise<void> {
    for (const { plugin, config } of this.plugins) {
      const ctx: PluginContext = {
        eventBus: this.eventBus,
        registerTool: (tool: Tool) => this.tools.push(tool),
        state: this.state,
        config,
        logger: createLogger(plugin.name),
      };
      await plugin.init(ctx);
    }
  }

  async shutdownAll(): Promise<void> {
    for (const { plugin } of this.plugins.reverse()) {
      await plugin.shutdown();
    }
  }

  getTools(): Tool[] {
    return this.tools;
  }
}
```

**Step 5: Run tests to verify they pass**

```bash
npx vitest run src/core/plugin-host.test.ts
# Expected: 3 passed
```

**Step 6: Commit**

```bash
git add src/core/types.ts src/core/plugin-host.ts src/core/plugin-host.test.ts
git commit -m "feat: add PluginHost with tool registry and lifecycle management"
```

---

## Phase 3: AI Layer

### Task 7: Implement Claude client with tool-use

**Files:**
- Create: `src/ai/claude.ts`
- Test: `src/ai/claude.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/ai/claude.test.ts
import { describe, it, expect, vi } from "vitest";
import { ClaudeClient, formatToolsForAPI } from "./claude.js";
import type { Tool } from "../core/types.js";
import { z } from "zod";

describe("formatToolsForAPI", () => {
  it("converts internal tools to Anthropic API format", () => {
    const tools: Tool[] = [
      {
        name: "get_status",
        description: "Get system status",
        inputSchema: z.object({ verbose: z.boolean().optional() }),
        run: async () => "ok",
      },
    ];
    const formatted = formatToolsForAPI(tools);
    expect(formatted).toHaveLength(1);
    expect(formatted[0].name).toBe("get_status");
    expect(formatted[0].description).toBe("Get system status");
    expect(formatted[0].input_schema).toBeDefined();
    expect(formatted[0].input_schema.type).toBe("object");
  });
});

describe("ClaudeClient", () => {
  it("constructs with API key and model", () => {
    const client = new ClaudeClient("test-key", "claude-sonnet-4-5-20250929");
    expect(client).toBeDefined();
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/ai/claude.test.ts
# Expected: FAIL
```

**Step 3: Install zod-to-json-schema**

```bash
npm install zod-to-json-schema
```

**Step 4: Implement Claude client**

```typescript
// src/ai/claude.ts
import Anthropic from "@anthropic-ai/sdk";
import type { Tool } from "../core/types.js";
import { zodToJsonSchema } from "zod-to-json-schema";

export function formatToolsForAPI(tools: Tool[]): Anthropic.Tool[] {
  return tools.map((t) => ({
    name: t.name,
    description: t.description,
    input_schema: zodToJsonSchema(t.inputSchema) as Anthropic.Tool.InputSchema,
  }));
}

export interface AgentResponse {
  text: string;
  toolResults: Array<{ tool: string; input: unknown; output: string }>;
}

export class ClaudeClient {
  private client: Anthropic;
  private model: string;

  constructor(apiKey: string, model: string) {
    this.client = new Anthropic({ apiKey });
    this.model = model;
  }

  async chat(
    messages: Anthropic.MessageParam[],
    tools: Tool[],
    systemPrompt: string,
  ): Promise<AgentResponse> {
    const apiTools = formatToolsForAPI(tools);
    const toolResults: AgentResponse["toolResults"] = [];
    let currentMessages = [...messages];

    // Agent loop: keep going until Claude stops calling tools
    while (true) {
      const response = await this.client.messages.create({
        model: this.model,
        max_tokens: 4096,
        system: systemPrompt,
        messages: currentMessages,
        tools: apiTools.length > 0 ? apiTools : undefined,
      });

      if (response.stop_reason !== "tool_use") {
        // Extract text from response
        const text = response.content
          .filter((b): b is Anthropic.TextBlock => b.type === "text")
          .map((b) => b.text)
          .join("");
        return { text, toolResults };
      }

      // Process tool calls
      const toolUseBlocks = response.content.filter(
        (b): b is Anthropic.ToolUseBlock => b.type === "tool_use",
      );

      const toolResultContents: Anthropic.ToolResultBlockParam[] = [];

      for (const toolUse of toolUseBlocks) {
        const tool = tools.find((t) => t.name === toolUse.name);
        let output: string;
        if (tool) {
          try {
            output = await tool.run(toolUse.input);
          } catch (err) {
            output = `Error: ${err instanceof Error ? err.message : String(err)}`;
          }
        } else {
          output = `Error: Unknown tool "${toolUse.name}"`;
        }

        toolResults.push({ tool: toolUse.name, input: toolUse.input, output });
        toolResultContents.push({
          type: "tool_result",
          tool_use_id: toolUse.id,
          content: output,
        });
      }

      // Append assistant response and tool results, continue loop
      currentMessages = [
        ...currentMessages,
        { role: "assistant", content: response.content },
        { role: "user", content: toolResultContents },
      ];
    }
  }
}
```

**Step 5: Run tests to verify they pass**

```bash
npx vitest run src/ai/claude.test.ts
# Expected: 2 passed
```

**Step 6: Commit**

```bash
git add src/ai/claude.ts src/ai/claude.test.ts
git commit -m "feat: add Claude client with tool-use agent loop"
```

---

### Task 8: Implement conversation context manager

**Files:**
- Create: `src/ai/context.ts`
- Test: `src/ai/context.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/ai/context.test.ts
import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { ConversationManager } from "./context.js";
import { StateStore } from "../core/state.js";
import { unlinkSync } from "node:fs";

const TEST_DB = "/tmp/nixclaw-context-test.db";

describe("ConversationManager", () => {
  let state: StateStore;
  let mgr: ConversationManager;

  beforeEach(() => {
    state = new StateStore(TEST_DB);
    mgr = new ConversationManager(state);
  });

  afterEach(() => {
    state.close();
    try { unlinkSync(TEST_DB); } catch {}
  });

  it("starts with empty history for new conversation", () => {
    expect(mgr.getMessages("conv-1")).toEqual([]);
  });

  it("appends user and assistant messages", () => {
    mgr.addUserMessage("conv-1", "hello");
    mgr.addAssistantMessage("conv-1", "hi there");
    const messages = mgr.getMessages("conv-1");
    expect(messages).toHaveLength(2);
    expect(messages[0]).toEqual({ role: "user", content: "hello" });
    expect(messages[1]).toEqual({ role: "assistant", content: "hi there" });
  });

  it("isolates conversations", () => {
    mgr.addUserMessage("conv-1", "from conv 1");
    mgr.addUserMessage("conv-2", "from conv 2");
    expect(mgr.getMessages("conv-1")).toHaveLength(1);
    expect(mgr.getMessages("conv-2")).toHaveLength(1);
  });

  it("persists across instances", () => {
    mgr.addUserMessage("conv-1", "persisted");
    const mgr2 = new ConversationManager(state);
    expect(mgr2.getMessages("conv-1")).toHaveLength(1);
    expect(mgr2.getMessages("conv-1")[0].content).toBe("persisted");
  });

  it("truncates to max messages", () => {
    for (let i = 0; i < 60; i++) {
      mgr.addUserMessage("conv-1", `msg-${i}`);
    }
    // Default max is 50 messages
    const msgs = mgr.getMessages("conv-1");
    expect(msgs.length).toBeLessThanOrEqual(50);
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/ai/context.test.ts
# Expected: FAIL
```

**Step 3: Implement ConversationManager**

```typescript
// src/ai/context.ts
import type Anthropic from "@anthropic-ai/sdk";
import type { StateStore } from "../core/state.js";

const NAMESPACE = "conversations";
const MAX_MESSAGES = 50;

export class ConversationManager {
  constructor(private state: StateStore) {}

  getMessages(conversationId: string): Anthropic.MessageParam[] {
    const raw = this.state.getJSON<Anthropic.MessageParam[]>(NAMESPACE, conversationId);
    return raw ?? [];
  }

  addUserMessage(conversationId: string, text: string): void {
    this.append(conversationId, { role: "user", content: text });
  }

  addAssistantMessage(conversationId: string, text: string): void {
    this.append(conversationId, { role: "assistant", content: text });
  }

  private append(conversationId: string, message: Anthropic.MessageParam): void {
    const messages = this.getMessages(conversationId);
    messages.push(message);
    // Keep only the last MAX_MESSAGES
    const trimmed = messages.slice(-MAX_MESSAGES);
    this.state.setJSON(NAMESPACE, conversationId, trimmed);
  }
}
```

**Step 4: Run tests to verify they pass**

```bash
npx vitest run src/ai/context.test.ts
# Expected: 5 passed
```

**Step 5: Commit**

```bash
git add src/ai/context.ts src/ai/context.test.ts
git commit -m "feat: add ConversationManager with SQLite persistence"
```

---

## Phase 4: Agent Core + Terminal Channel (MVP)

### Task 9: Implement the Agent core

**Files:**
- Create: `src/core/agent.ts`
- Test: `src/core/agent.test.ts`

This is the central orchestrator: receives messages from the event bus, sends them to Claude with tools, emits responses back.

**Step 1: Write the failing tests**

```typescript
// src/core/agent.test.ts
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { Agent } from "./agent.js";
import { EventBus } from "./event-bus.js";
import { StateStore } from "./state.js";
import { PluginHost } from "./plugin-host.js";
import type { NixClawConfig } from "./config.js";
import { unlinkSync, writeFileSync } from "node:fs";

const TEST_DB = "/tmp/nixclaw-agent-test.db";
const FAKE_KEY_FILE = "/tmp/nixclaw-test-apikey";

describe("Agent", () => {
  let bus: EventBus;
  let state: StateStore;
  let host: PluginHost;
  let config: NixClawConfig;

  beforeEach(() => {
    bus = new EventBus();
    state = new StateStore(TEST_DB);
    host = new PluginHost(bus, state);
    writeFileSync(FAKE_KEY_FILE, "test-api-key");
    config = {
      ai: { provider: "claude", model: "claude-sonnet-4-5-20250929", apiKeyFile: FAKE_KEY_FILE },
      channels: { telegram: { enable: false }, webui: { enable: false, port: 3333 } },
      voice: { stt: { provider: "claude" }, tts: { provider: "none" } },
      tools: { nixos: { enable: false }, dev: { enable: false } },
      mcp: { servers: {} },
      stateDir: "/tmp/nixclaw-agent-test-state",
    };
  });

  afterEach(() => {
    state.close();
    try { unlinkSync(TEST_DB); } catch {}
    try { unlinkSync(FAKE_KEY_FILE); } catch {}
  });

  it("creates an agent instance", () => {
    const agent = new Agent(config, bus, state, host);
    expect(agent).toBeDefined();
  });

  it("emits response events when processing messages", async () => {
    const agent = new Agent(config, bus, state, host);
    const responseSpy = vi.fn();
    bus.on("message:response", responseSpy);

    // Mock the Claude client to avoid real API calls
    (agent as any).claude = {
      chat: vi.fn().mockResolvedValue({ text: "Hello from Claude!", toolResults: [] }),
    };

    bus.emit("message:incoming", {
      id: "test-1",
      channel: "terminal",
      sender: "user",
      text: "hello",
      timestamp: new Date(),
    });

    // Allow async processing
    await new Promise((r) => setTimeout(r, 50));

    expect(responseSpy).toHaveBeenCalledOnce();
    expect(responseSpy.mock.calls[0][0]).toMatchObject({
      channel: "terminal",
      text: "Hello from Claude!",
    });
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/core/agent.test.ts
# Expected: FAIL
```

**Step 3: Implement Agent**

```typescript
// src/core/agent.ts
import { readFileSync } from "node:fs";
import { ClaudeClient, type AgentResponse } from "../ai/claude.js";
import { ConversationManager } from "../ai/context.js";
import type { EventBus } from "./event-bus.js";
import type { StateStore } from "./state.js";
import type { PluginHost } from "./plugin-host.js";
import type { NixClawConfig } from "./config.js";
import type { NixClawMessage } from "./types.js";

const SYSTEM_PROMPT = `You are NixClaw, a personal AI agent running on a NixOS system.
You help your user manage their NixOS system, development workflows, and daily tasks.
Be concise and direct. When using tools, explain what you're doing briefly.
If a task requires system changes (like nixos-rebuild), propose the change and ask the user to execute it.`;

export class Agent {
  private claude: ClaudeClient;
  private conversations: ConversationManager;

  constructor(
    private config: NixClawConfig,
    private eventBus: EventBus,
    private state: StateStore,
    private pluginHost: PluginHost,
  ) {
    const apiKey = readFileSync(config.ai.apiKeyFile, "utf-8").trim();
    this.claude = new ClaudeClient(apiKey, config.ai.model);
    this.conversations = new ConversationManager(state);

    this.eventBus.on("message:incoming", (payload) => {
      this.handleMessage(payload as NixClawMessage).catch((err) => {
        console.error("[agent] Error handling message:", err);
      });
    });
  }

  private async handleMessage(msg: NixClawMessage): Promise<void> {
    const conversationId = `${msg.channel}:${msg.sender}`;

    this.conversations.addUserMessage(conversationId, msg.text);
    const messages = this.conversations.getMessages(conversationId);
    const tools = this.pluginHost.getTools();

    const response = await this.claude.chat(messages, tools, SYSTEM_PROMPT);

    this.conversations.addAssistantMessage(conversationId, response.text);

    this.eventBus.emit("message:response", {
      id: msg.id,
      channel: msg.channel,
      sender: msg.sender,
      text: response.text,
      toolResults: response.toolResults,
      replyTo: msg.id,
    });
  }
}
```

**Step 4: Run tests to verify they pass**

```bash
npx vitest run src/core/agent.test.ts
# Expected: 2 passed
```

**Step 5: Commit**

```bash
git add src/core/agent.ts src/core/agent.test.ts
git commit -m "feat: add Agent core with message handling and Claude integration"
```

---

### Task 10: Implement Terminal channel plugin

**Files:**
- Create: `src/channels/terminal/index.ts`
- Test: `src/channels/terminal/index.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/channels/terminal/index.test.ts
import { describe, it, expect, vi } from "vitest";
import { TerminalChannel } from "./index.js";
import type { PluginContext } from "../../core/types.js";
import { EventBus } from "../../core/event-bus.js";

describe("TerminalChannel", () => {
  it("implements NixClawPlugin interface", () => {
    const channel = new TerminalChannel();
    expect(channel.name).toBe("terminal");
    expect(channel.version).toBeDefined();
    expect(channel.init).toBeInstanceOf(Function);
    expect(channel.shutdown).toBeInstanceOf(Function);
  });

  it("emits message:incoming when receiving input", () => {
    const channel = new TerminalChannel();
    const bus = new EventBus();
    const incomingSpy = vi.fn();
    bus.on("message:incoming", incomingSpy);

    // Simulate the channel processing a line of input
    channel.processLine("hello world", bus);

    expect(incomingSpy).toHaveBeenCalledOnce();
    const msg = incomingSpy.mock.calls[0][0];
    expect(msg.channel).toBe("terminal");
    expect(msg.text).toBe("hello world");
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/channels/terminal/index.test.ts
# Expected: FAIL
```

**Step 3: Implement TerminalChannel**

```typescript
// src/channels/terminal/index.ts
import { createInterface, type Interface } from "node:readline";
import { randomUUID } from "node:crypto";
import type { NixClawPlugin, PluginContext, NixClawMessage } from "../../core/types.js";
import type { EventBus } from "../../core/event-bus.js";

export class TerminalChannel implements NixClawPlugin {
  name = "terminal";
  version = "0.1.0";
  private rl?: Interface;
  private cleanup?: () => void;

  async init(ctx: PluginContext): Promise<void> {
    const { eventBus, logger } = ctx;

    // Listen for responses to print
    this.cleanup = eventBus.on("message:response", (payload: unknown) => {
      const response = payload as { channel: string; text: string };
      if (response.channel === "terminal") {
        console.log(`\n${response.text}\n`);
        process.stdout.write("nixclaw> ");
      }
    });

    // Set up readline for input
    this.rl = createInterface({
      input: process.stdin,
      output: process.stdout,
      prompt: "nixclaw> ",
    });

    this.rl.on("line", (line) => {
      const trimmed = line.trim();
      if (trimmed === "") return;
      if (trimmed === "exit" || trimmed === "quit") {
        this.rl?.close();
        process.exit(0);
      }
      this.processLine(trimmed, eventBus);
    });

    this.rl.prompt();
    logger.info("Terminal channel ready");
  }

  processLine(text: string, eventBus: EventBus): void {
    const msg: NixClawMessage = {
      id: randomUUID(),
      channel: "terminal",
      sender: "local",
      text,
      timestamp: new Date(),
    };
    eventBus.emit("message:incoming", msg);
  }

  async shutdown(): Promise<void> {
    this.cleanup?.();
    this.rl?.close();
  }
}
```

**Step 4: Run tests to verify they pass**

```bash
npx vitest run src/channels/terminal/index.test.ts
# Expected: 2 passed
```

**Step 5: Commit**

```bash
git add src/channels/terminal/index.ts src/channels/terminal/index.test.ts
git commit -m "feat: add Terminal channel plugin with readline"
```

---

### Task 11: Wire up main entry point (working MVP)

**Files:**
- Modify: `src/index.ts`

**Step 1: Implement the main bootstrap**

```typescript
// src/index.ts
import { loadConfig } from "./core/config.js";
import { EventBus } from "./core/event-bus.js";
import { StateStore } from "./core/state.js";
import { PluginHost } from "./core/plugin-host.js";
import { Agent } from "./core/agent.js";
import { TerminalChannel } from "./channels/terminal/index.js";
import { mkdirSync } from "node:fs";

async function main() {
  console.log("NixClaw v0.1.0 — starting...\n");

  const config = loadConfig();

  // Ensure state directory exists
  mkdirSync(config.stateDir, { recursive: true });

  const eventBus = new EventBus();
  const state = new StateStore(`${config.stateDir}/nixclaw.db`);
  const pluginHost = new PluginHost(eventBus, state);

  // Register channel plugins
  await pluginHost.register(new TerminalChannel(), {});

  // Initialize all plugins (registers tools, starts channels)
  await pluginHost.initAll();

  // Start the agent (connects event bus to Claude)
  const agent = new Agent(config, eventBus, state, pluginHost);

  // Graceful shutdown
  const shutdown = async () => {
    console.log("\nShutting down...");
    await pluginHost.shutdownAll();
    state.close();
    process.exit(0);
  };

  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
```

**Step 2: Build and verify**

```bash
npm run build
# Test with: NIXCLAW_CONFIG='{"ai":{"provider":"claude","model":"claude-sonnet-4-5-20250929","apiKeyFile":"/path/to/your/key"},...}' node dist/index.js
# Or just verify it starts: node dist/index.js (will fail on missing API key, which is expected)
```

**Step 3: Run all tests**

```bash
npx vitest run
# Expected: All tests pass
```

**Step 4: Commit**

```bash
git add src/index.ts
git commit -m "feat: wire up main entry point — terminal MVP working"
```

---

## Phase 5: Telegram Channel

### Task 12: Implement Telegram channel plugin

**Files:**
- Create: `src/channels/telegram/index.ts`
- Test: `src/channels/telegram/index.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/channels/telegram/index.test.ts
import { describe, it, expect, vi } from "vitest";
import { TelegramChannel } from "./index.js";
import { EventBus } from "../../core/event-bus.js";

describe("TelegramChannel", () => {
  it("implements NixClawPlugin interface", () => {
    const channel = new TelegramChannel();
    expect(channel.name).toBe("telegram");
    expect(channel.version).toBeDefined();
  });

  it("rejects messages from non-allowed users", () => {
    const channel = new TelegramChannel();
    const bus = new EventBus();
    const spy = vi.fn();
    bus.on("message:incoming", spy);

    const allowed = channel.isAllowedUser("12345", ["67890"]);
    expect(allowed).toBe(false);
  });

  it("accepts messages from allowed users", () => {
    const channel = new TelegramChannel();
    const allowed = channel.isAllowedUser("12345", ["12345", "67890"]);
    expect(allowed).toBe(true);
  });

  it("accepts all users when allowedUsers is empty", () => {
    const channel = new TelegramChannel();
    const allowed = channel.isAllowedUser("12345", []);
    expect(allowed).toBe(true);
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/channels/telegram/index.test.ts
# Expected: FAIL
```

**Step 3: Implement TelegramChannel**

```typescript
// src/channels/telegram/index.ts
import { Bot } from "grammy";
import { readFileSync } from "node:fs";
import { randomUUID } from "node:crypto";
import type { NixClawPlugin, PluginContext, NixClawMessage } from "../../core/types.js";

interface TelegramConfig {
  botTokenFile: string;
  allowedUsers?: string[];
}

export class TelegramChannel implements NixClawPlugin {
  name = "telegram";
  version = "0.1.0";
  private bot?: Bot;
  private cleanup?: () => void;

  isAllowedUser(userId: string, allowedUsers: string[]): boolean {
    if (allowedUsers.length === 0) return true;
    return allowedUsers.includes(userId);
  }

  async init(ctx: PluginContext): Promise<void> {
    const config = ctx.config as unknown as TelegramConfig;
    if (!config.botTokenFile) {
      ctx.logger.warn("No botTokenFile configured, skipping Telegram");
      return;
    }

    const token = readFileSync(config.botTokenFile, "utf-8").trim();
    const allowedUsers = config.allowedUsers ?? [];

    this.bot = new Bot(token);

    // Handle incoming messages
    this.bot.on("message:text", async (gramCtx) => {
      const userId = String(gramCtx.from.id);

      if (!this.isAllowedUser(userId, allowedUsers)) {
        await gramCtx.reply("Access denied.");
        return;
      }

      const msg: NixClawMessage = {
        id: randomUUID(),
        channel: "telegram",
        sender: userId,
        text: gramCtx.message.text,
        timestamp: new Date(gramCtx.message.date * 1000),
      };

      ctx.eventBus.emit("message:incoming", msg);
    });

    // Handle responses
    this.cleanup = ctx.eventBus.on("message:response", async (payload: unknown) => {
      const response = payload as {
        channel: string;
        sender: string;
        text: string;
      };
      if (response.channel !== "telegram") return;

      try {
        await this.bot!.api.sendMessage(Number(response.sender), response.text, {
          parse_mode: "Markdown",
        });
      } catch (err) {
        // Fallback: send without markdown if parsing fails
        try {
          await this.bot!.api.sendMessage(Number(response.sender), response.text);
        } catch (fallbackErr) {
          ctx.logger.error("Failed to send Telegram message:", fallbackErr);
        }
      }
    });

    // Start polling
    this.bot.start({
      onStart: () => ctx.logger.info("Telegram bot started"),
    });
  }

  async shutdown(): Promise<void> {
    this.cleanup?.();
    this.bot?.stop();
  }
}
```

**Step 4: Run tests to verify they pass**

```bash
npx vitest run src/channels/telegram/index.test.ts
# Expected: 4 passed
```

**Step 5: Register Telegram in main entry point**

Modify `src/index.ts` to conditionally register TelegramChannel:

```typescript
// Add after TerminalChannel registration:
import { TelegramChannel } from "./channels/telegram/index.js";

// Inside main(), after registering terminal:
if (config.channels.telegram.enable) {
  await pluginHost.register(new TelegramChannel(), config.channels.telegram);
}
```

**Step 6: Run all tests**

```bash
npx vitest run
# Expected: All pass
```

**Step 7: Commit**

```bash
git add src/channels/telegram/ src/index.ts
git commit -m "feat: add Telegram channel plugin with grammy"
```

---

## Phase 6: NixOS Tools Plugin

### Task 13: Implement NixOS tools plugin

**Files:**
- Create: `src/tools/nixos/index.ts`
- Create: `src/tools/nixos/commands.ts`
- Test: `src/tools/nixos/index.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/tools/nixos/index.test.ts
import { describe, it, expect, vi } from "vitest";
import { NixOSToolsPlugin } from "./index.js";
import { EventBus } from "../../core/event-bus.js";
import { StateStore } from "../../core/state.js";
import type { PluginContext, Tool } from "../../core/types.js";
import { unlinkSync } from "node:fs";

const TEST_DB = "/tmp/nixclaw-nixos-tools-test.db";

describe("NixOSToolsPlugin", () => {
  it("implements NixClawPlugin interface", () => {
    const plugin = new NixOSToolsPlugin();
    expect(plugin.name).toBe("nixos-tools");
  });

  it("registers tools on init", async () => {
    const plugin = new NixOSToolsPlugin();
    const bus = new EventBus();
    const state = new StateStore(TEST_DB);
    const tools: Tool[] = [];

    const ctx: PluginContext = {
      eventBus: bus,
      registerTool: (t) => tools.push(t),
      state,
      config: { flakePath: "/tmp/fake-flake" },
      logger: { info: vi.fn(), warn: vi.fn(), error: vi.fn(), debug: vi.fn() },
    };

    await plugin.init(ctx);

    expect(tools.length).toBeGreaterThanOrEqual(3);
    const names = tools.map((t) => t.name);
    expect(names).toContain("nixclaw_system_status");
    expect(names).toContain("nixclaw_flake_check");
    expect(names).toContain("nixclaw_service_status");

    state.close();
    try { unlinkSync(TEST_DB); } catch {}
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/tools/nixos/index.test.ts
# Expected: FAIL
```

**Step 3: Implement NixOS command helpers**

```typescript
// src/tools/nixos/commands.ts
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const exec = promisify(execFile);

export async function runCommand(cmd: string, args: string[]): Promise<string> {
  try {
    const { stdout, stderr } = await exec(cmd, args, { timeout: 30000 });
    return stdout + (stderr ? `\nSTDERR: ${stderr}` : "");
  } catch (err: unknown) {
    const e = err as { stdout?: string; stderr?: string; message: string };
    return `Error: ${e.message}\n${e.stdout ?? ""}\n${e.stderr ?? ""}`.trim();
  }
}

export async function getSystemStatus(): Promise<string> {
  const [generation, uptime, hostname] = await Promise.all([
    runCommand("nixos-rebuild", ["list-generations"]).catch(() => "unavailable"),
    runCommand("uptime", ["-p"]),
    runCommand("hostname", []),
  ]);
  return `Hostname: ${hostname.trim()}\nUptime: ${uptime.trim()}\nGenerations:\n${generation}`;
}

export async function flakeCheck(flakePath: string): Promise<string> {
  return runCommand("nix", ["flake", "check", flakePath, "--no-build"]);
}

export async function serviceStatus(serviceName: string): Promise<string> {
  return runCommand("systemctl", ["status", serviceName, "--no-pager"]);
}

export async function listServices(): Promise<string> {
  return runCommand("systemctl", ["list-units", "--type=service", "--state=running", "--no-pager", "--no-legend"]);
}
```

**Step 4: Implement the plugin**

```typescript
// src/tools/nixos/index.ts
import { z } from "zod";
import type { NixClawPlugin, PluginContext } from "../../core/types.js";
import { getSystemStatus, flakeCheck, serviceStatus, listServices } from "./commands.js";

interface NixOSToolsConfig {
  flakePath?: string;
}

export class NixOSToolsPlugin implements NixClawPlugin {
  name = "nixos-tools";
  version = "0.1.0";

  async init(ctx: PluginContext): Promise<void> {
    const config = ctx.config as unknown as NixOSToolsConfig;
    const flakePath = config.flakePath ?? ".";

    ctx.registerTool({
      name: "nixclaw_system_status",
      description: "Get NixOS system status: hostname, uptime, current generation",
      inputSchema: z.object({}),
      run: async () => getSystemStatus(),
    });

    ctx.registerTool({
      name: "nixclaw_flake_check",
      description: "Run 'nix flake check' on the NixOS configuration to validate it",
      inputSchema: z.object({}),
      run: async () => flakeCheck(flakePath),
    });

    ctx.registerTool({
      name: "nixclaw_service_status",
      description: "Get the status of a systemd service",
      inputSchema: z.object({
        service: z.string().describe("Name of the systemd service, e.g. 'nginx' or 'nixclaw'"),
      }),
      run: async (input) => {
        const { service } = input as { service: string };
        return serviceStatus(service);
      },
    });

    ctx.registerTool({
      name: "nixclaw_list_services",
      description: "List all running systemd services",
      inputSchema: z.object({}),
      run: async () => listServices(),
    });

    ctx.logger.info(`NixOS tools registered (flakePath: ${flakePath})`);
  }

  async shutdown(): Promise<void> {}
}
```

**Step 5: Run tests to verify they pass**

```bash
npx vitest run src/tools/nixos/index.test.ts
# Expected: 2 passed
```

**Step 6: Register in main entry point**

Add to `src/index.ts`:

```typescript
import { NixOSToolsPlugin } from "./tools/nixos/index.js";

// Inside main(), after channel registrations:
if (config.tools.nixos.enable) {
  await pluginHost.register(new NixOSToolsPlugin(), config.tools.nixos);
}
```

**Step 7: Run all tests**

```bash
npx vitest run
# Expected: All pass
```

**Step 8: Commit**

```bash
git add src/tools/nixos/ src/index.ts
git commit -m "feat: add NixOS tools plugin with system status and flake check"
```

---

## Phase 7: Web UI

### Task 14: Implement Web UI channel plugin

**Files:**
- Create: `src/channels/webui/index.ts`
- Create: `src/channels/webui/routes.ts`
- Test: `src/channels/webui/index.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/channels/webui/index.test.ts
import { describe, it, expect, vi } from "vitest";
import { WebUIChannel } from "./index.js";

describe("WebUIChannel", () => {
  it("implements NixClawPlugin interface", () => {
    const channel = new WebUIChannel();
    expect(channel.name).toBe("webui");
    expect(channel.version).toBeDefined();
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/channels/webui/index.test.ts
# Expected: FAIL
```

**Step 3: Implement WebUI routes**

```typescript
// src/channels/webui/routes.ts
import type { FastifyInstance } from "fastify";
import type { EventBus } from "../../core/event-bus.js";
import type { StateStore } from "../../core/state.js";
import { randomUUID } from "node:crypto";
import type { NixClawMessage } from "../../core/types.js";

export function registerRoutes(
  app: FastifyInstance,
  eventBus: EventBus,
  state: StateStore,
): void {
  // Health check
  app.get("/api/health", async () => ({ status: "ok", timestamp: new Date().toISOString() }));

  // Send a message
  app.post<{ Body: { text: string } }>("/api/chat", async (req) => {
    const msg: NixClawMessage = {
      id: randomUUID(),
      channel: "webui",
      sender: "webui-user",
      text: req.body.text,
      timestamp: new Date(),
    };
    eventBus.emit("message:incoming", msg);
    return { id: msg.id, status: "processing" };
  });

  // SSE stream for responses
  app.get("/api/stream", async (req, reply) => {
    reply.raw.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    });

    const off = eventBus.on("message:response", (payload: unknown) => {
      const response = payload as { channel: string; text: string };
      if (response.channel === "webui") {
        reply.raw.write(`data: ${JSON.stringify(response)}\n\n`);
      }
    });

    req.raw.on("close", () => off());
  });

  // Serve minimal HTML dashboard
  app.get("/", async (req, reply) => {
    reply.type("text/html").send(DASHBOARD_HTML);
  });
}

const DASHBOARD_HTML = `<!DOCTYPE html>
<html>
<head>
  <title>NixClaw</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: monospace; background: #1a1a2e; color: #e0e0e0; height: 100vh; display: flex; flex-direction: column; }
    #header { padding: 12px 16px; background: #16213e; border-bottom: 1px solid #0f3460; }
    #header h1 { font-size: 16px; color: #e94560; }
    #messages { flex: 1; overflow-y: auto; padding: 16px; }
    .msg { margin-bottom: 12px; padding: 8px 12px; border-radius: 4px; max-width: 80%; }
    .msg.user { background: #0f3460; margin-left: auto; }
    .msg.agent { background: #16213e; }
    #input-area { padding: 12px 16px; background: #16213e; border-top: 1px solid #0f3460; display: flex; gap: 8px; }
    #input { flex: 1; background: #1a1a2e; border: 1px solid #0f3460; color: #e0e0e0; padding: 8px; border-radius: 4px; font-family: monospace; }
    #send { background: #e94560; border: none; color: white; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
  </style>
</head>
<body>
  <div id="header"><h1>NixClaw</h1></div>
  <div id="messages"></div>
  <div id="input-area">
    <input id="input" placeholder="Type a message..." autofocus>
    <button id="send">Send</button>
  </div>
  <script>
    const msgs = document.getElementById('messages');
    const input = document.getElementById('input');
    const send = document.getElementById('send');

    function addMsg(text, cls) {
      const div = document.createElement('div');
      div.className = 'msg ' + cls;
      div.textContent = text;
      msgs.appendChild(div);
      msgs.scrollTop = msgs.scrollHeight;
    }

    const es = new EventSource('/api/stream');
    es.onmessage = (e) => {
      const data = JSON.parse(e.data);
      addMsg(data.text, 'agent');
    };

    async function sendMsg() {
      const text = input.value.trim();
      if (!text) return;
      addMsg(text, 'user');
      input.value = '';
      await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text }),
      });
    }

    send.onclick = sendMsg;
    input.onkeydown = (e) => { if (e.key === 'Enter') sendMsg(); };
  </script>
</body>
</html>`;
```

**Step 4: Implement WebUIChannel plugin**

```typescript
// src/channels/webui/index.ts
import Fastify, { type FastifyInstance } from "fastify";
import type { NixClawPlugin, PluginContext } from "../../core/types.js";
import { registerRoutes } from "./routes.js";

interface WebUIConfig {
  port: number;
  host?: string;
}

export class WebUIChannel implements NixClawPlugin {
  name = "webui";
  version = "0.1.0";
  private app?: FastifyInstance;

  async init(ctx: PluginContext): Promise<void> {
    const config = ctx.config as unknown as WebUIConfig;
    const port = config.port ?? 3333;
    const host = config.host ?? "127.0.0.1";

    this.app = Fastify();
    registerRoutes(this.app, ctx.eventBus, ctx.state);

    await this.app.listen({ port, host });
    ctx.logger.info(`Web UI listening on http://${host}:${port}`);
  }

  async shutdown(): Promise<void> {
    await this.app?.close();
  }
}
```

**Step 5: Run tests to verify they pass**

```bash
npx vitest run src/channels/webui/index.test.ts
# Expected: 1 passed
```

**Step 6: Register in main entry point**

Add to `src/index.ts`:

```typescript
import { WebUIChannel } from "./channels/webui/index.js";

// Inside main(), after Telegram registration:
if (config.channels.webui.enable) {
  await pluginHost.register(new WebUIChannel(), config.channels.webui);
}
```

**Step 7: Run all tests, commit**

```bash
npx vitest run
git add src/channels/webui/ src/index.ts
git commit -m "feat: add Web UI channel with SSE streaming and dashboard"
```

---

## Phase 8: NixOS Module

### Task 15: Implement the full NixOS module

**Files:**
- Modify: `nix/module.nix`

**Step 1: Write the complete module**

Replace the stub `nix/module.nix` with the full implementation:

```nix
{ self }:
{ config, lib, pkgs, ... }:
let
  cfg = config.services.nixclaw;
  configJSON = builtins.toJSON {
    ai = {
      provider = cfg.ai.provider;
      model = cfg.ai.model;
      apiKeyFile = cfg.ai.apiKeyFile;
    };
    channels = {
      telegram = {
        enable = cfg.channels.telegram.enable;
        botTokenFile = cfg.channels.telegram.botTokenFile;
        allowedUsers = cfg.channels.telegram.allowedUsers;
      };
      webui = {
        enable = cfg.channels.webui.enable;
        port = cfg.channels.webui.port;
        host = cfg.channels.webui.host;
      };
    };
    voice = {
      stt = { provider = cfg.voice.stt.provider; };
      tts = {
        provider = cfg.voice.tts.provider;
      } // lib.optionalAttrs (cfg.voice.tts.provider == "elevenlabs") {
        elevenlabs = {
          apiKeyFile = cfg.voice.tts.elevenlabs.apiKeyFile;
          voiceId = cfg.voice.tts.elevenlabs.voiceId;
        };
      };
    };
    tools = {
      nixos = {
        enable = cfg.tools.nixos.enable;
        flakePath = cfg.tools.nixos.flakePath;
        allowConfigEdits = cfg.tools.nixos.allowConfigEdits;
      };
      dev = {
        enable = cfg.tools.dev.enable;
      };
    };
    mcp = {
      servers = lib.mapAttrs (name: serverCfg: {
        command = serverCfg.command;
        args = serverCfg.args;
        env = serverCfg.env;
      }) cfg.mcp.servers;
    };
    stateDir = cfg.stateDir;
  };
in
{
  options.services.nixclaw = {
    enable = lib.mkEnableOption "NixClaw AI agent";

    ai = {
      provider = lib.mkOption {
        type = lib.types.enum [ "claude" ];
        default = "claude";
        description = "AI backend provider";
      };
      model = lib.mkOption {
        type = lib.types.str;
        default = "claude-sonnet-4-5-20250929";
        description = "AI model identifier";
      };
      apiKeyFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to file containing the API key";
      };
    };

    channels = {
      telegram = {
        enable = lib.mkEnableOption "Telegram channel";
        botTokenFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to file containing Telegram bot token";
        };
        allowedUsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Telegram user IDs allowed to interact (empty = all)";
        };
      };
      webui = {
        enable = lib.mkEnableOption "Web UI channel";
        port = lib.mkOption {
          type = lib.types.port;
          default = 3333;
          description = "Web UI listen port";
        };
        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Web UI listen address";
        };
      };
    };

    voice = {
      stt = {
        provider = lib.mkOption {
          type = lib.types.enum [ "claude" "whisper" ];
          default = "claude";
          description = "Speech-to-text provider";
        };
      };
      tts = {
        provider = lib.mkOption {
          type = lib.types.enum [ "elevenlabs" "piper" "none" ];
          default = "none";
          description = "Text-to-speech provider";
        };
        elevenlabs = {
          apiKeyFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to file containing ElevenLabs API key";
          };
          voiceId = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "ElevenLabs voice ID for TTS output";
          };
        };
      };
    };

    tools = {
      nixos = {
        enable = lib.mkEnableOption "NixOS management tools";
        flakePath = lib.mkOption {
          type = lib.types.path;
          default = "/etc/nixos";
          description = "Path to NixOS flake configuration";
        };
        allowConfigEdits = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Allow NixClaw to propose config file edits";
        };
      };
      dev = {
        enable = lib.mkEnableOption "Development workflow tools";
      };
    };

    mcp = {
      servers = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            command = lib.mkOption {
              type = lib.types.str;
              description = "Command to run the MCP server";
            };
            args = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Arguments for the MCP server command";
            };
            env = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = "Environment variables for the MCP server";
            };
          };
        });
        default = { };
        description = "MCP servers to connect to at startup";
      };
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixclaw";
      description = "Directory for persistent state (SQLite database)";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nixclaw = {
      description = "NixClaw AI Agent";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment.NIXCLAW_CONFIG = configJSON;

      serviceConfig = {
        ExecStart = "${self.packages.${pkgs.system}.default}/bin/nixclaw";
        DynamicUser = true;
        StateDirectory = "nixclaw";
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ cfg.stateDir ] ++ lib.optional cfg.tools.nixos.enable cfg.tools.nixos.flakePath;
        NoNewPrivileges = true;
        PrivateTmp = true;
        RestartSec = 10;
        Restart = "on-failure";
      };
    };

    networking.firewall.allowedTCPPorts =
      lib.optional cfg.channels.webui.enable cfg.channels.webui.port;
  };
}
```

**Step 2: Verify the flake parses**

```bash
nix flake check
# Should parse without errors (build may fail until npmDepsHash is set)
```

**Step 3: Commit**

```bash
git add nix/module.nix
git commit -m "feat: implement full NixOS module with systemd hardening"
```

---

## Phase 9: MCP Client

### Task 16: Implement MCP client for connecting to external MCP servers

**Files:**
- Create: `src/core/mcp-client.ts`
- Test: `src/core/mcp-client.test.ts`

The MCP client spawns configured MCP servers as child processes, communicates via stdio (JSON-RPC), discovers their tools at startup, and registers them in the PluginHost so Claude can call them.

**Step 1: Install MCP SDK**

```bash
npm install @modelcontextprotocol/sdk
```

**Step 2: Write the failing tests**

```typescript
// src/core/mcp-client.test.ts
import { describe, it, expect } from "vitest";
import { McpClientManager } from "./mcp-client.js";

describe("McpClientManager", () => {
  it("constructs with empty server config", () => {
    const mgr = new McpClientManager({});
    expect(mgr).toBeDefined();
  });

  it("returns empty tools when no servers configured", async () => {
    const mgr = new McpClientManager({});
    const tools = await mgr.getAllTools();
    expect(tools).toEqual([]);
  });
});
```

**Step 3: Run tests to verify they fail**

```bash
npx vitest run src/core/mcp-client.test.ts
# Expected: FAIL
```

**Step 4: Implement McpClientManager**

```typescript
// src/core/mcp-client.ts
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import type { Tool } from "./types.js";
import { z } from "zod";

interface McpServerConfig {
  command: string;
  args?: string[];
  env?: Record<string, string>;
}

interface ConnectedServer {
  name: string;
  client: Client;
  transport: StdioClientTransport;
}

export class McpClientManager {
  private servers: ConnectedServer[] = [];

  constructor(private serverConfigs: Record<string, McpServerConfig>) {}

  async connectAll(): Promise<void> {
    for (const [name, config] of Object.entries(this.serverConfigs)) {
      try {
        const transport = new StdioClientTransport({
          command: config.command,
          args: config.args ?? [],
          env: { ...process.env, ...config.env },
        });
        const client = new Client({ name: `nixclaw-${name}`, version: "0.1.0" });
        await client.connect(transport);
        this.servers.push({ name, client, transport });
        console.log(`[mcp] Connected to ${name}`);
      } catch (err) {
        console.error(`[mcp] Failed to connect to ${name}:`, err);
      }
    }
  }

  async getAllTools(): Promise<Tool[]> {
    const tools: Tool[] = [];
    for (const server of this.servers) {
      try {
        const response = await server.client.listTools();
        for (const mcpTool of response.tools) {
          tools.push({
            name: `${server.name}_${mcpTool.name}`,
            description: mcpTool.description ?? mcpTool.name,
            inputSchema: z.any(),
            run: async (input) => {
              const result = await server.client.callTool({
                name: mcpTool.name,
                arguments: input as Record<string, unknown>,
              });
              const textContent = result.content
                .filter((c): c is { type: "text"; text: string } => c.type === "text")
                .map((c) => c.text)
                .join("\n");
              return textContent || JSON.stringify(result.content);
            },
          });
        }
      } catch (err) {
        console.error(`[mcp] Failed to list tools from ${server.name}:`, err);
      }
    }
    return tools;
  }

  async disconnectAll(): Promise<void> {
    for (const server of this.servers) {
      try {
        await server.client.close();
      } catch {}
    }
    this.servers = [];
  }
}
```

**Step 5: Run tests to verify they pass**

```bash
npx vitest run src/core/mcp-client.test.ts
# Expected: 2 passed
```

**Step 6: Integrate into main entry point and Agent**

In `src/index.ts`, after creating PluginHost:

```typescript
import { McpClientManager } from "./core/mcp-client.js";

// Connect to MCP servers
const mcpManager = new McpClientManager(config.mcp?.servers ?? {});
await mcpManager.connectAll();
const mcpTools = await mcpManager.getAllTools();
// Register MCP tools in the plugin host
for (const tool of mcpTools) {
  pluginHost.registerExternalTool(tool);
}
```

**Step 7: Commit**

```bash
git add src/core/mcp-client.ts src/core/mcp-client.test.ts src/index.ts
git commit -m "feat: add MCP client for connecting to external tool servers"
```

---

## Phase 10: Voice Messages

### Task 17: Implement STT (Speech-to-Text)

**Files:**
- Create: `src/voice/stt.ts`
- Test: `src/voice/stt.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/voice/stt.test.ts
import { describe, it, expect } from "vitest";
import { createSTT } from "./stt.js";

describe("STT", () => {
  it("creates a claude STT provider", () => {
    const stt = createSTT({ provider: "claude" });
    expect(stt).toBeDefined();
    expect(stt.transcribe).toBeInstanceOf(Function);
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/voice/stt.test.ts
# Expected: FAIL
```

**Step 3: Implement STT**

```typescript
// src/voice/stt.ts
import Anthropic from "@anthropic-ai/sdk";

interface STTConfig {
  provider: "claude" | "whisper";
}

export interface STTProvider {
  transcribe(audioBuffer: Buffer, mimeType: string): Promise<string>;
}

class ClaudeSTT implements STTProvider {
  async transcribe(audioBuffer: Buffer, mimeType: string): Promise<string> {
    // Claude can process audio directly via multimodal input
    // The audio is sent as a base64 content block in the messages API
    const client = new Anthropic();
    const response = await client.messages.create({
      model: "claude-sonnet-4-5-20250929",
      max_tokens: 1024,
      messages: [{
        role: "user",
        content: [
          {
            type: "text",
            text: "Transcribe this audio message exactly. Return only the transcription, nothing else.",
          },
          {
            type: "document",
            source: {
              type: "base64",
              media_type: mimeType as any,
              data: audioBuffer.toString("base64"),
            },
          },
        ],
      }],
    });
    const text = response.content
      .filter((b): b is Anthropic.TextBlock => b.type === "text")
      .map((b) => b.text)
      .join("");
    return text;
  }
}

export function createSTT(config: STTConfig): STTProvider {
  switch (config.provider) {
    case "claude":
      return new ClaudeSTT();
    case "whisper":
      throw new Error("Whisper STT not yet implemented");
    default:
      return new ClaudeSTT();
  }
}
```

**Step 4: Run tests, commit**

```bash
npx vitest run src/voice/stt.test.ts
git add src/voice/stt.ts src/voice/stt.test.ts
git commit -m "feat: add STT with Claude multimodal transcription"
```

---

### Task 18: Implement TTS (Text-to-Speech)

**Files:**
- Create: `src/voice/tts.ts`
- Test: `src/voice/tts.test.ts`

**Step 1: Write the failing tests**

```typescript
// src/voice/tts.test.ts
import { describe, it, expect } from "vitest";
import { createTTS } from "./tts.js";

describe("TTS", () => {
  it("creates an elevenlabs TTS provider", () => {
    const tts = createTTS({ provider: "elevenlabs", apiKey: "test", voiceId: "test" });
    expect(tts).toBeDefined();
    expect(tts.synthesize).toBeInstanceOf(Function);
  });

  it("creates a none TTS provider that returns null", async () => {
    const tts = createTTS({ provider: "none" });
    const result = await tts.synthesize("hello");
    expect(result).toBeNull();
  });
});
```

**Step 2: Run tests to verify they fail**

```bash
npx vitest run src/voice/tts.test.ts
# Expected: FAIL
```

**Step 3: Implement TTS**

```typescript
// src/voice/tts.ts
interface TTSConfig {
  provider: "elevenlabs" | "piper" | "none";
  apiKey?: string;
  voiceId?: string;
}

export interface TTSProvider {
  synthesize(text: string): Promise<Buffer | null>;
}

class ElevenLabsTTS implements TTSProvider {
  constructor(private apiKey: string, private voiceId: string) {}

  async synthesize(text: string): Promise<Buffer | null> {
    const response = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${this.voiceId}`,
      {
        method: "POST",
        headers: {
          "xi-api-key": this.apiKey,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          text,
          model_id: "eleven_turbo_v2_5",
        }),
      },
    );
    if (!response.ok) throw new Error(`ElevenLabs API error: ${response.status}`);
    return Buffer.from(await response.arrayBuffer());
  }
}

class NoneTTS implements TTSProvider {
  async synthesize(): Promise<null> {
    return null;
  }
}

export function createTTS(config: TTSConfig): TTSProvider {
  switch (config.provider) {
    case "elevenlabs":
      return new ElevenLabsTTS(config.apiKey!, config.voiceId!);
    case "piper":
      throw new Error("Piper TTS not yet implemented");
    case "none":
    default:
      return new NoneTTS();
  }
}
```

**Step 4: Run tests, commit**

```bash
npx vitest run src/voice/tts.test.ts
git add src/voice/tts.ts src/voice/tts.test.ts
git commit -m "feat: add TTS with ElevenLabs and none providers"
```

---

### Task 19: Add voice message handling to Telegram channel

**Files:**
- Modify: `src/channels/telegram/index.ts`
- Test: `src/channels/telegram/voice.test.ts`

Add a `bot.on("message:voice")` handler that:
1. Downloads the .ogg voice file from Telegram
2. Passes it to STT for transcription
3. Emits the transcribed text as a normal `message:incoming`
4. When a response comes back, passes it through TTS
5. Sends the audio back as a Telegram voice message via `ctx.replyWithVoice()`

**Step 1: Write tests for voice handling logic**
**Step 2: Implement voice handler in TelegramChannel**
**Step 3: Run tests, commit**

```bash
git commit -m "feat: add voice message support to Telegram channel"
```

---

## Phase 11: Dev Tools & Scheduler

### Task 20: Implement Dev tools plugin

**Files:**
- Create: `src/tools/dev/index.ts`
- Test: `src/tools/dev/index.test.ts`

Follow the same pattern as Task 13 (NixOS tools). Register tools:
- `nixclaw_git_status` — runs `git status` and `git log --oneline -10` in configured project directories
- `nixclaw_run_tests` — runs `npm test` or `nix flake check` depending on project type
- `nixclaw_claude_sessions` — lists tmux sessions matching `claude-*` pattern

**Step 1: Write tests, Step 2: Verify fail, Step 3: Implement, Step 4: Verify pass, Step 5: Commit**

```bash
git commit -m "feat: add dev tools plugin with git and test runner"
```

---

### Task 21: Implement Scheduler plugin

**Files:**
- Create: `src/tools/scheduler/index.ts`
- Test: `src/tools/scheduler/index.test.ts`

The scheduler uses `node-cron` (install: `npm install cron`) to run tasks on a schedule. Each scheduled task emits a synthetic message to the agent via the event bus, as if a user sent it from the configured channel.

**Step 1: Install cron**

```bash
npm install cron
npm install -D @types/cron
```

**Step 2-5: Write tests, implement, verify, commit**

```bash
git commit -m "feat: add scheduler plugin with cron-based task execution"
```

---

## Phase 12: Integration & Polish

### Task 22: Integration test — end-to-end terminal flow

**Files:**
- Create: `src/integration.test.ts`

Write an integration test that:
1. Boots NixClaw with a mock Claude API
2. Sends a message via the event bus
3. Verifies the response flows back through the event bus
4. Verifies tool calls are executed

```bash
git commit -m "test: add end-to-end integration test"
```

---

### Task 23: Set npmDepsHash and verify Nix build

**Step 1: Generate the hash**

```bash
nix build .#default 2>&1 | grep "got:"
# Copy the hash from the error output
```

**Step 2: Update flake.nix with the correct hash**

**Step 3: Verify build**

```bash
nix build .#default
./result/bin/nixclaw --help
```

**Step 4: Commit**

```bash
git commit -m "chore: set npmDepsHash for reproducible Nix build"
```

---

### Task 24: Add NixClaw as flake input to nixos-config

**Files:**
- Modify: `~/nixos-config/flake.nix` (add nixclaw input)
- Modify: appropriate host config (add `services.nixclaw` configuration)

**Step 1: Add flake input**

```nix
# In nixos-config/flake.nix inputs:
nixclaw = {
  url = "github:jacopone/nixclaw";  # or path:../nixclaw for local dev
  inputs.nixpkgs.follows = "nixpkgs";
};
```

**Step 2: Add NixOS module to host config**

```nix
# In the mkTechHost modules:
nixclaw.nixosModules.default
```

**Step 3: Configure the service**

```nix
services.nixclaw = {
  enable = true;
  ai.apiKeyFile = "/run/secrets/anthropic-key";  # or agenix path
  channels.telegram.enable = true;
  channels.telegram.botTokenFile = "/run/secrets/telegram-bot-token";
  channels.webui.enable = true;
  channels.webui.port = 3333;
  tools.nixos.enable = true;
  tools.nixos.flakePath = "/home/guyfawkes/nixos-config";
  tools.dev.enable = true;
};
```

**Step 4: Validate**

```bash
cd ~/nixos-config && nix flake check
```

**Step 5: Commit in nixos-config**

```bash
git commit -m "feat: integrate NixClaw as flake input"
```

**Step 6: Tell user to run rebuild-nixos**

The user must run `./rebuild-nixos` to activate the service.

---

## Summary

| Phase | Tasks | What it delivers |
|---|---|---|
| 1: Bootstrap | 1-2 | TypeScript project + Nix flake |
| 2: Core | 3-6 | EventBus, StateStore, Config, PluginHost |
| 3: AI | 7-8 | Claude client with tool-use, conversation memory |
| 4: MVP | 9-11 | Agent core + Terminal channel (first working version) |
| 5: Telegram | 12 | Mobile interaction via Telegram (text) |
| 6: NixOS Tools | 13 | System status, flake check, service monitoring |
| 7: Web UI | 14 | Dashboard with SSE streaming |
| 8: NixOS Module | 15 | Declarative `services.nixclaw` with voice + MCP config |
| 9: MCP Client | 16 | Connect to external MCP servers (Rube, sunsama, etc.) |
| 10: Voice | 17-19 | STT (Claude multimodal), TTS (ElevenLabs), Telegram voice messages |
| 11: Dev + Scheduler | 20-21 | Git tools, test runner, scheduled tasks |
| 12: Integration | 22-24 | E2E tests, Nix build, flake integration |

**MVP checkpoint is after Task 11** — you'll have a working agent in the terminal that can chat with Claude. Everything after that is incremental enhancement.
