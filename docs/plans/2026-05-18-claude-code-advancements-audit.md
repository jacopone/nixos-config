# Claude Code Advancements Audit — ClaudeOS NixOS Fleet

**Date:** 2026-05-18
**Author:** Claude (Opus 4.7, 1M context)
**Scope:** Admin-track / personal capability maximization. Business-track (`mkBusinessHost`) considered only when changes happen to benefit it.
**Status:** Audit + recommendations only — no code in this session.
**Sources:** Live `code.claude.com/docs/en/*` (May 2026), plus repo `file:line` citations throughout.

---

## 0. Executive Summary

ClaudeOS already runs ahead of most NixOS-with-Claude-Code setups. The native sandbox (bubblewrap + seccomp BPF, `pkgs/claude-seccomp.nix`), 17 declaratively-enabled plugins (`modules/home-manager/claude-code/company-config.json:121-140`), the `NIXOS_REBUILD_WRAPPER=1` handshake (`rebuild-nixos:33-35`), and the `claude-autonomous.sh` Ralph-loop worktree pattern are non-trivial achievements that should remain the baseline.

But the Feb–May 2026 release cadence shifted the ground significantly. Three findings demand action **before** anything else in this audit:

1. **`claude-nixos-automation` (flake input at `flake.nix:59-62`) is archived** as of March 4, 2026, "superseded by Claude Code's native features (skills, permissions.allow/ask/deny, claudeMd, skillOverrides, claudeMdExcludes, auto memory, `/memory`, `.claude/rules/`)." Quoting its archived README. **Action: remove the input or accept growing drift from a frozen upstream.**
2. **Sandbox settings schema was overhauled.** Your `sandbox.seccomp.{bpfPath,applyPath}` form (`modules/home-manager/claude-code/default.nix:51-54`) predates the current top-level `sandbox` schema (`enabled`, `failIfUnavailable`, `autoAllowBashIfSandboxed`, `filesystem.{allowWrite,denyWrite,…}`, `network.{allowedDomains,deniedDomains,…}`, `sandbox.bwrapPath`/`socatPath` added v2.1.133). **Action: verify against `code.claude.com/docs/en/sandboxing` and the live `--print-settings-schema` output before assuming your seccomp wiring is still honored.**
3. **`scripts/claude-autonomous.sh` is largely superseded by `claude agents`** (v2.1.139, May 11 2026 — the Agent View TUI with auto-isolating worktrees under `.claude/worktrees/`, plus `/goal` for completion-criterion-driven runs). **Action: pilot Agent View as a replacement; keep your script as fallback during migration.**

Beyond those three urgent items, the long-tail gap is on the **declarative-extension** axis. The repo enables others' plugins but ships almost no first-party Claude Code primitives:

- **Zero custom subagents** (`~/.claude/agents/` does not exist) — despite `company-policies.md:15` instructing "use subagents to offload research."
- **One custom slash command** (`commands/nixos.md` — and it's a context note, not an action).
- **Zero custom output styles, statuslines, hooks (admin), or skills** declared in the flake.
- **`.mcp.json` is empty** at the project root.
- **17 new hook events** (TaskCreated, FileChanged, PreCompact, SubagentStart/Stop, …) are unused.
- **`claudeMd` managed setting** (Linux: `/etc/claude-code/managed-settings.json`) — the *correct* deployment path for org-wide CLAUDE.md content — is unused; `company-policies.md` is wired via `home.file` symlink, which can be deleted by a user.
- **`.claude/rules/` with `paths:` frontmatter glob** — load-on-demand path-scoped rules — is unused; CLAUDE.md remains monolithic.
- **Stale archaeology** in `.claude/`: ~75KB of files from the deprecated "Phase 8 Adaptive Learning" system noted at `rebuild-nixos:1047`.

### Top 8 P0 recommendations (full detail in §5)

| # | Recommendation | Why now | Effort | Files |
|---|----------------|---------|--------|-------|
| P0-1 | **Remove `claude-automation` flake input** or document why kept | Archived upstream, growing drift | 1h | `flake.nix:59-62, 93`, `flake.lock` |
| P0-2 | **Verify sandbox settings schema** against current docs; migrate if `sandbox.seccomp.*` is obsolete | Setting may silently no-op | 2h | `modules/home-manager/claude-code/default.nix:51-54`, `company-config.json` |
| P0-3 | **Migrate `company-policies.md` to `claudeMd` managed setting** in `/etc/claude-code/managed-settings.json` | True org-wide enforcement; user-deletion-proof | 3h | new NixOS module, `default.nix:12` |
| P0-4 | **Pilot Agent View** (`claude agents` TUI, v2.1.139) as replacement for `claude-autonomous.sh` | Native supervisor + auto-worktrees + `/goal` obsoletes ~80% of the shell script | 4h pilot + writeup | `scripts/claude-autonomous.sh`, new helper |
| P0-5 | **Wire `.mcp.json` with MCP-NixOS**; plan custom build-telemetry MCP for P1 | Closes the docs↔reality gap | 30min for MCP-NixOS; 2d for custom | `.mcp.json` |
| P0-6 | **Ship 4 declarative subagents** (`flake-debugger`, `package-finder`, `generation-differ`, `supply-chain-auditor`) | Highest-leverage 2026 primitive; you ship zero | 1d | `modules/home-manager/claude-code/agents/*.md` |
| P0-7 | **Statusline** (host/class/gen/branch/last-build) | Glanceable fleet context, zero cost | 2h | `modules/home-manager/claude-code/statusline.sh` |
| P0-8 | **Clean up stale `.claude/` archaeology** (~75KB, see §2.7) | Misleads future AI agents reading the repo; violates "no temporal markers" policy | 10min | `git rm …` |

### What you already do well (keep these)

- Native sandbox with custom seccomp BPF — `pkgs/claude-seccomp.nix` (your own derivation from vendored source)
- Declarative plugin enablement merged into `settings.json` with permissions union — `default.nix:35-69`
- Atomic-rollback discipline reflected in `rebuild-nixos` phase structure
- Business-track guardrail hook with 20+ blocked patterns — `modules/business/home-manager/hooks/guardrail.sh`
- `--audit` and `--verify-bootstrap` flags for supply-chain reproducibility — invariants #2 and #5
- Wrapper handshake via `NIXOS_REBUILD_WRAPPER=1` env so hooks can permit sudo — `rebuild-nixos:33`
- `claude-autonomous.sh` Ralph-loop + research-mode patterns (worth keeping as fallback during Agent View migration)

---

## 1. 2026 Claude Code Feature Inventory

> **Note on tool names:** earlier session text referenced `TeamCreate`/`ScheduleWakeup` as if they were stable tools. After research: `ScheduleWakeup` exists (dynamic `/loop` pacing — confirmed in this very session). `TeamCreate` is **not** a documented tool — agent teams are created via natural-language requests to the lead agent. Where the audit recommends "teams," I mean the experimental agent-teams feature gated by `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (which the repo already sets at `default.nix:56`).

> **Docs URL migration:** Anthropic moved Claude Code docs from `docs.claude.com/en/docs/claude-code/*` to `code.claude.com/docs/en/*` (301 redirects in place; index at `code.claude.com/docs/llms.txt`). Update any hardcoded references.

### 1.1 Core primitives (stable)

| Feature | Shipped / status | What it is | Your repo? | Docs |
|---------|------------------|-----------|------------|------|
| **Slash commands** | stable, 2025 | Markdown actions in `commands/` | 1 file (`nixos.md`, descriptive only) | `/en/slash-commands` |
| **Sub-agents** | stable (extended 2026) | YAML-frontmatter agents in `.claude/agents/`; per-agent `mcpServers`, `preload skills`, `isolation: worktree` frontmatter | 0 custom | `/en/sub-agents` |
| **Skills** | stable, supersedes commands for non-action context | `SKILL.md` in `~/.claude/skills/<name>/` (auto-invoked or `/name`) | Consumed via plugins; cloned: `gstack` (for biz `aiProfile=claude`). 0 custom-published | `/en/skills` |
| **Plugins** | stable, heavy 2026 work | `.claude-plugin/plugin.json` bundling commands/agents/skills/hooks/MCP/LSP/monitors/bin | 17 enabled from official marketplace | `/en/plugins`, `/en/plugins-reference` |
| **Marketplaces** | stable | `/plugin marketplace add/update/remove` (private repos OK) | Consume `claude-plugins-official` + `anthropic-agent-skills`; publish none | `/en/plugin-marketplaces` |
| **Hooks** | stable (27+ events as of 2026) | Five handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`) at lifecycle events | Business: 1 hook (`guardrail.sh`, PreToolUse). Admin: only `.backup` files | `/en/hooks` |
| **MCP servers** | stable | stdio / SSE / HTTP. `.mcp.json` (project), `~/.claude.json`, settings. Per-server `alwaysLoad` (v2.1.121) opts out of tool-search deferral | `.mcp.json` empty `{}` | `/en/mcp` |
| **Statusline** | stable (+ v2.1.141: `terminalSequence` for desktop notifications) | Shell script gets JSON on stdin, prints multi-line | None | `/en/statusline` |
| **Output styles** | stable | Markdown w/ frontmatter (`keep-coding-instructions`, `force-for-plugin`); built-ins: Default, Proactive, Explanatory, Learning | Consume Explanatory + Learning plugins; publish 0 | `/en/output-styles` |
| **Permission modes** | stable | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | All available; `--dangerously-skip-permissions` used by `claude-autonomous.sh:638` | `/en/permission-modes` |
| **Plan mode** | stable; `--permission-mode plan` headless | Read-only until approval | Mentioned in policies; no declarative gate | `/en/permission-modes` |
| **Auto memory** | stable, v2.1.59 | Auto-notes at `~/.claude/projects/<repo>/memory/MEMORY.md`. Loads first 200 lines / 25KB. `autoMemoryEnabled`, `autoMemoryDirectory` | Active, rich for nixos-config | `/en/memory` |
| **Plan/file checkpointing** (`/rewind`, `/undo` alias v2.1.108) | stable | File-level rewind during session | Default behavior; nothing custom | `/en/checkpointing` |
| **Worktrees** | stable; v2.1.133 `worktree.baseRef`, v2.1.143 `worktree.bgIsolation` | `EnterWorktree`/`ExitWorktree` tools | Manual git worktrees in `claude-autonomous.sh`; native primitive unused | `/en/worktrees` |
| **`--bare` mode** | stable, 2026 | `claude --bare -p` skips hooks/skills/plugins/MCP/CLAUDE.md auto-discovery. Recommended for CI; slated to become `-p` default | Not used (could harden `claude-autonomous.sh`) | `/en/headless` |

### 1.2 Big-deal Feb–May 2026 additions (the freshness section)

| Feature | Version / date | What changed | Impact for ClaudeOS |
|---------|----------------|--------------|---------------------|
| **Agent View / `claude agents` TUI** | v2.1.139 (May 11 2026) | Dispatch many sessions, peek/attach/detach, supervisor keeps them alive without terminal. `/bg`, `←`, `claude --bg`. CLI: `claude attach/logs/stop/respawn/rm`. **Auto-isolates writes in `.claude/worktrees/`** | Largely supersedes `claude-autonomous.sh`. P0 to pilot |
| **`/goal` command** | v2.1.139 | Sets completion condition; Claude keeps working until met. Elapsed/turns/tokens overlay | Replaces the Ralph loop pattern at `claude-autonomous.sh:633-650` |
| **Native Claude Code binary** | v2.1.113 (Apr 17) | Per-platform binary instead of Node bundle | `claude-code-nix` flake input (`flake.nix:35-38`) may need to track the new packaging |
| **Claude Opus 4.7 + `/effort` slider** | v2.1.111 (Apr 16) | New effort levels: `low`, `medium`, `high`, `xhigh` (Opus 4.7 only), `max`. `${CLAUDE_EFFORT}` substitution in skills | You already set `CLAUDE_CODE_EFFORT_LEVEL=max` at `default.nix:28`. Consider `xhigh` for Opus 4.7 specifically |
| **`/ultraplan` and `/ultrareview`** | Apr 2026 | Cloud-side multi-agent flows | Worth exploring for ClaudeOS planning + PR review automation |
| **Routines (cloud)** | research preview, early 2026 | Saved configs with schedule, API `/fire` endpoint, GitHub event triggers | Candidate for nightly `nix flake update`, weekly `--audit` reruns |
| **`channels`** | research preview, v2.1.80 | MCP servers pushing events INTO running session: Telegram, Discord, iMessage, fakechat, webhooks. `--channels plugin:foo` per session. Settings: `channelsEnabled`, `allowedChannelPlugins` | Build an ops bridge: Telegram → `rebuild-nixos` status, fleet alerts |
| **`monitors/monitors.json`** | v2.1.105 | Plugin component: background process whose each stdout line becomes a notification | **Perfect for `rebuild-nixos`** — phases emit structured lines, monitor surfaces them |
| **`.lsp.json` in plugins** | 2026 | Pre-built LSP for TS/Py/Rust | A `claudeos-fleet` plugin could ship a Nix LSP definition |
| **`--plugin-url <url>`** | v2.1.129 | Load plugin from URL without marketplace | Lighter publishing path for `claudeos-fleet` |
| **`--plugin-dir <zip>`** | v2.1.128 | Load plugin from zip/dir | Local dev iteration |
| **Custom themes** | v2.1.118 | `~/.claude/themes/` | Cosmetic; could declare via Home Manager |
| **`/usage`** | v2.1.118 | Merges `/cost` + `/stats` | Just useful to know |
| **`/tui fullscreen`** | v2.1.110 | Reclaims terminal real estate | Just useful to know |
| **`disableRemoteControl`** | v2.1.128 | Block remote-control of local session from claude.ai / mobile | Worth setting `true` on business hosts? |
| **`policyHelper`** | v2.1.136 | Org-defined CLI for permission decisions | Replaces some hook logic |
| **`disableAgentView`, `disableSkillShellExecution`** | 2026 | Hard-disable surfaces | Useful for business-host lockdown |

### 1.3 New hook events (2026)

The 2026 hooks page lists 27+ events. Your repo uses one (`PreToolUse` for the business guardrail). Unused events with clear ClaudeOS use cases:

| Event | Version | ClaudeOS use case |
|-------|---------|-------------------|
| `SubagentStart` / `SubagentStop` | 2026 | Log subagent dispatches for observability; enforce per-subagent permission deltas |
| `TaskCreated` / `TaskCompleted` | 2026 | Sync TaskList to an MCP resource; cross-host task visibility |
| `TeammateIdle` | 2026 | Auto-dispatch follow-up work when a teammate goes idle |
| `InstructionsLoaded` | 2026 | Verify CLAUDE.md hash matches the canonical source; refuse to proceed on drift |
| `ConfigChange` | 2026 | Alert on `~/.claude/settings.json` mutation outside the Home Manager activation window |
| `CwdChanged` | 2026 | Refuse to operate outside `~/nixos-config` for the maintainer-track session |
| `FileChanged` | 2026 | Re-run `nix flake check` when `flake.nix` / `modules/**/*.nix` change |
| `WorktreeCreate` / `WorktreeRemove` | 2026 | Mirror the worktree-management invariants of `claude-autonomous.sh` |
| `PreCompact` / `PostCompact` | v2.1.105 / 2026 | Save a context snapshot before compaction; restore on PostCompact |
| `PostToolBatch` | 2026 | Batch verification (e.g., re-run a typecheck after a flurry of edits) |
| `PermissionRequest` / `PermissionDenied` | 2026 | Feed denial patterns back into permissions union (auto-promote frequently approved patterns — *carefully*, this was Phase 8's failure mode) |
| `Notification` | 2025 | Already used implicitly; can intercept to bridge to system notification daemon |
| `Elicitation` / `ElicitationResult` | 2026 | Track when AskUserQuestion fires; could route to mobile if user is away |
| `SessionEnd` | 2026 | Auto-commit auto-memory updates; final telemetry flush |

### 1.4 Settings keys with ClaudeOS relevance

Worth a deliberate decision per key (set, leave default, or explicitly document why default):

```
sandbox.enabled                       sandbox.bwrapPath
sandbox.failIfUnavailable             sandbox.socatPath
sandbox.autoAllowBashIfSandboxed      sandbox.filesystem.allowWrite
sandbox.network.allowedDomains        sandbox.filesystem.denyWrite
sandbox.network.deniedDomains         sandbox.filesystem.allowRead
sandbox.network.allowAllUnixSockets   sandbox.filesystem.denyRead
sandbox.network.allowLocalBinding
autoMemoryEnabled                     autoMemoryDirectory
autoMode.hard_deny                    channelsEnabled
strictKnownMarketplaces               allowedChannelPlugins
blockedMarketplaces                   disableRemoteControl
worktree.baseRef                      worktree.bgIsolation
parentSettingsBehavior                wslInheritsWindowsSettings
policyHelper                          claudeMd  (managed-settings only)
disableAgentView                      disableSkillShellExecution
skillOverrides                        skillListingBudgetFraction
                                      maxSkillDescriptionChars
```

The current `default.nix` sets only `permissions`, `sandbox.seccomp`, `enabledPlugins`, `alwaysThinkingEnabled`, `env`. Of the ~30 keys above, **none are explicitly configured**, meaning everything defaults — which is fine until a default changes.

### 1.5 Headless / agent-SDK note

`claude-autonomous.sh:637` does `cat … | claude … --dangerously-skip-permissions`. As of June 15, 2026 (per the headless docs page), **Agent SDK and `claude -p` on subscription plans will draw from a separate monthly Agent SDK credit**. Heavy use of `claude-autonomous.sh` may suddenly cost differently. Worth pricing-modeling before then.

---

## 2. Current-State Map

Every Claude Code touchpoint in the repo, with `file:line` citations.

### 2.1 Declarative wiring

| File:line | Surface | What it does |
|-----------|---------|--------------|
| `flake.nix:35-38` | Input | `claude-code-nix` (sadjow/claude-code-nix) — packaged CC binary. **Watch v2.1.113 native-binary transition** |
| `flake.nix:59-62, 93` | Input | `claude-automation` (jacopone/claude-nixos-automation) — **ARCHIVED Mar 4 2026**, see G16 |
| `flake.nix:337` | Wiring | `claude-code-nix.packages.x86_64-linux.default` installed system-wide |
| `modules/home-manager/claude-code/default.nix:7` | Derivation | imports `pkgs/claude-seccomp.nix` |
| `:12` | `home.file` | `~/.claude/CLAUDE.md` ← `company-policies.md` (immutable symlink). **G17: should be `claudeMd` managed setting** |
| `:15` | `home.file` | `~/.claude/commands/nixos.md` (only custom command) |
| `:18-22` | `home.file` | `~/.claude/seccomp/{apply-seccomp,unix-block.bpf}` |
| `:21-22` | `home.file` | NPM-global fallback paths for seccomp under `~/.npm/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64/` |
| `:25-29` | `sessionVariables` | `CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000`, `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`, `CLAUDE_CODE_EFFORT_LEVEL=max` |
| `:35-69` | `home.activation` | `claude-settings-merge` — jq-merges `company-config.json` into `~/.claude/settings.json` (union permissions, plugin defaults, seccomp paths, agent-teams flag). **G19: sandbox.seccomp.* schema may be obsolete** |

### 2.2 Plugins (declared)

`modules/home-manager/claude-code/company-config.json:121-140` — 17 plugins from `claude-plugins-official`:

```
context7, code-review, commit-commands, pr-review-toolkit, plugin-dev,
feature-dev, frontend-design, code-simplifier, typescript-lsp, pyright-lsp,
ralph-loop, superpowers, claude-md-management, explanatory-output-style,
claude-code-setup, hookify, learning-output-style
```

Plus `document-skills@anthropic-agent-skills:129`.

### 2.3 Permissions

`company-config.json:3-119` — 108 allowed Bash command patterns, plus blanket `Read(/**)`, `Write(/**)`, `Edit(/**)`, `Glob(**)`, `Grep`, `WebFetch`, `WebSearch`. Notable: `Bash(claude:*)` permits recursive Claude invocation, used by `claude-autonomous.sh`.

### 2.4 Hooks

| Track | File | Lifecycle | What |
|-------|------|-----------|------|
| Business | `modules/business/home-manager/hooks/guardrail.sh` | `PreToolUse` (Bash, Write, Edit) | 20 block patterns: force-push, `reset --hard`, `rm -rf` of root/home, `git rm -r`, `find -delete`, scripted recursion, `npm publish`, `gcloud deploy`, `sudo`, `nixos-rebuild`, `curl ... | sh`, `chmod 777`, edits to CI/Dockerfile/.env/flake.nix |
| Business | `modules/business/home-manager/default.nix:32-46` | Activation | Patches `settings.json.hooks.PreToolUse` to wire the guardrail |
| Admin | `~/.claude/hooks/*.backup` only | — | Two backups (`post-write-tests.sh.backup`, `tdd-guard-hook.sh.backup`) from the deprecated "Phase 8 Adaptive Learning" system |

### 2.5 Sandbox

| Element | Source |
|---------|--------|
| seccomp BPF derivation | `pkgs/claude-seccomp.nix` (build from `vendor/seccomp-src/`) |
| BPF wiring (legacy schema) | `modules/home-manager/claude-code/default.nix:18-22, 51-54` |
| Sandboxed worktree runner | `scripts/claude-autonomous.sh` (Ralph loop, research mode, strict mode) — **G18: Agent View supersedes** |

### 2.6 rebuild-nixos integration

| Line | Element |
|------|---------|
| `:33-35` | `export NIXOS_REBUILD_WRAPPER=1` so hooks can permit nested `nixos-rebuild` |
| `:919-935` | **Phase 4 "Claude Config Check"** — 17-line stub: verifies two files exist |
| `:938-1045` | **Phase 7 Changelog Draft Generation** — calls `scripts/generate-changelog-draft.sh` |
| `:1339-1370` | **Phase 13 Claude Temp File Cleanup** — sweeps `learner_counter_*` and `security_warnings_state_*` (orphans from deprecated learning system) |
| `:1372-1408` | **Phase 14 Claude Backup Cleanup** — interactive cleanup of `.backups/` |
| `:1047` | Comment: "Phase 8 (Adaptive Learning) removed — Claude configs are now hand-maintained" |

### 2.7 Project-local `.claude/` artifacts

`/home/YOUR_USERNAME/nixos-config/.claude/`:

| File | Size | Date | Verdict |
|------|------|------|---------|
| `CLAUDE_CODE_ANALYSIS.md` | 25KB | 2026-02-09 | **Stale** — likely a one-shot audit output never cleaned up |
| `tool-analytics.md` | 42KB | 2026-02-09 | **Stale** — auto-collected analytics from old system |
| `mcp-analytics.md` | 920B | 2026-02-09 | **Stale** |
| `permissions_auto_generated.md` | 3.8KB | 2026-01-11 | **Stale** — "Permission Auto-Learner", the removed Phase 8 |
| `ANALYSIS_SUMMARY.txt` | 3.9KB | 2026-02-06 | **Stale** |
| `CLAUDE.local.md` | 1.7KB | 2026-02-09 | **Stale data** — hostname says `framework-16` but git state shown is wrong |
| `mcp.json` | 23B | 2026-02-06 | **Empty** — `{"mcpServers": {}}` |
| `settings.local.json` | 11KB | 2026-05-12 | **Live** — local overrides |
| `.changelog-last-processed` | 41B | 2026-05-12 | **Live** — used by Phase 7 |
| `commands/` | dir | | Need to inspect contents for additional custom commands |
| `tdd-guard/` | dir | | Likely artifact of removed TDD guard hook |
| `.backups/` | dir | | Targeted by Phase 14 |

### 2.8 Gemini coexistence

`hosts/business-template/GEMINI.md` exists per the CLAUDE.md root file's "Tech Stack" section (Gemini CLI as the business default for `aiProfile = "google"`). Out of scope for this audit but flagged for future cross-pollination (e.g., shared base CLAUDE.md/GEMINI.md sources).

---

## 3. Gap Analysis

Each gap anchored to invariants in `CLAUDE.md:30-49`:
**(I1)** declarativity, **(I2)** reproducibility, **(I3)** atomic rollback, **(I4)** sandbox isolation, **(I5)** supply-chain auditability, **(I6)** one-line host onboarding, **(I7)** tech↔business separation.

### G1. No custom subagents `[P0]`

**Today:** `~/.claude/agents/` does not exist. The repo has zero `*.md` files defining subagents. The `Agent` tool's `subagent_type` parameter is restricted to the built-ins (`claude`, `code-reviewer`, `Explore`, `Plan`, etc.) plus those shipped by enabled plugins.

**Why for ClaudeOS (I1, I3, I6):** Four highest-frequency ops each have a natural subagent shape:

- **`flake-debugger`** — runs `nix flake check` with structured-error parsing, suggests fixes, can spawn `nix build` against specific outputs. Frontmatter: `isolation: worktree`, `mcpServers: [mcp-nixos]`.
- **`package-finder`** — fronts MCP-NixOS, returns "use `pkgs.foo`" with full attribute path + which module file (`core/packages.nix` vs `common/packages.nix` vs `business/packages.nix`) per the table in `CLAUDE.md:103-114`. `preload skills: [nixos]`.
- **`generation-differ`** — runs `nvd diff $OLD $NEW` against rollback candidates, summarizes closure changes by category (security, kernel, AI tools, business).
- **`supply-chain-auditor`** — runs `--audit` mode, diffs the exported manifest against the prior one, flags any unexpected FOD additions, anchors to Invariant #5.

Currently `company-policies.md:15` instructs Claude to "use subagents to offload research" but only the built-in `Explore` and `general-purpose` are available.

**Sketch:**
```
modules/home-manager/claude-code/
├── default.nix                  # add `home.file."./agents/*.md".source`
├── agents/
│   ├── flake-debugger.md       # YAML frontmatter: description, isolation: worktree, mcpServers
│   ├── package-finder.md
│   ├── generation-differ.md
│   └── supply-chain-auditor.md
```

**Effort:** ~4 hours per agent. Total ~1 day.
**Risk:** Low — additive.
**Dependencies:** None hard. G3 (MCP wiring) makes `package-finder` and `flake-debugger` more capable.

### G2. No first-party plugin `claudeos-fleet` `[P1]`

**Today:** Every customization is inline (commands as `home.file`, hooks as `pkgs.writeShellScript`, etc.). You consume 17 third-party plugins but ship none of your own.

**Why for ClaudeOS (I1, I6):** A plugin is the canonical 2026 distribution format. Bundling your commands+subagents+skills+hooks into a `claudeos-fleet` plugin means:
- One `enabledPlugins` entry instead of many `home.file` rules
- Versioned (semver via the plugin's own git tags)
- Easier to share across hosts and (if you go public) the community
- Naturally separates "company config" from "company plugin" — Pietro and other business users could enable a subset
- Matches your existing pattern of consuming `claude-automation` as a separate flake input — you're already comfortable with this shape
- Can include `.lsp.json` (Nix LSP), `monitors/monitors.json` (rebuild-nixos surfacing), `bin/` (helper executables)

**Sketch:** New repo `claudeos-fleet` with `.claude-plugin/plugin.json`, `commands/`, `agents/`, `skills/`, `hooks/hooks.json`, `.mcp.json`, `monitors/monitors.json`, `output-styles/`. Install via `--plugin-url` (v2.1.129) or set up a tiny marketplace.

**Effort:** ~1 week initial setup, then ongoing.
**Risk:** Medium — moves files around; need a migration path that keeps current hosts working.
**Dependencies:** G1 (subagents) is more useful when packaged this way.

### G3. `.mcp.json` is empty `[P0]`

**Today:** `/home/YOUR_USERNAME/nixos-config/.mcp.json` is `{"mcpServers": {}}`. The `nixos.md` skill claims MCP-NixOS is "configured in `.mcp.json`" — false. CLAUDE.md root also asserts this in "Dynamic Context." `~/.claude/settings.json.mcpServers` is also absent.

**Why for ClaudeOS (I1):** Docs describe a capability that doesn't exist. Two moves:
- **Minimum:** wire MCP-NixOS as documented
- **High-leverage:** add a custom **build-telemetry MCP server** exposing `rebuild-nixos` structured state — resources for current generation, last build status, generation history, rollback targets, `--audit` manifest history, flake.lock diff vs upstream; tools for `query-generation(n)`, `diff-generations(a, b)`, `pending-updates()`, `claim-rebuild()`, `release-rebuild()`. Turns `rebuild-nixos` from a black box into queryable data **without** invoking the script.

**Sketch (minimum):**
```json
{
  "mcpServers": {
    "mcp-nixos": {
      "command": "uvx",
      "args": ["mcp-nixos@latest"]
    }
  }
}
```

**Sketch (custom):**
```
pkgs/mcp-rebuild-telemetry/
├── default.nix              # builds Node/Bun MCP server
├── src/
│   ├── server.ts
│   └── resources/           # one file per resource
└── README.md
```

Then `rebuild-nixos` writes structured JSON event logs to `~/.local/state/rebuild-nixos/events.jsonl` (G6), and the MCP server reads them.

**Effort:** 30 min for MCP-NixOS; ~2 days for telemetry MCP.
**Risk:** Low / Medium.
**Dependencies:** Telemetry MCP depends on G6 (JSON event log).

### G4. No statusline `[P0]`

**Today:** No statusline. Nothing displays current host class (tech vs business), current generation, branch, or last build status while in Claude Code.

**Why for ClaudeOS (I6, I7):** Multi-host fleet with tech/business split → glanceable context matters. v2.1.141 added `terminalSequence` for desktop notifications, opening even richer integration.

**Sketch:**
```bash
# modules/home-manager/claude-code/statusline.sh
#!/usr/bin/env bash
# Receives session JSON on stdin
host=$(hostname -s)
host_class=$([ -f /etc/claudeos/host-class ] && cat /etc/claudeos/host-class || echo "?")
gen=$(readlink /run/current-system | grep -oE 'system-[0-9]+' | cut -d- -f2)
branch=$(git -C "$HOME/nixos-config" branch --show-current 2>/dev/null)
last=$(cat "$HOME/.local/state/rebuild-nixos/last-status" 2>/dev/null || echo "?")
echo "[$host $host_class | gen $gen | $branch | last:$last]"
```

Wire via `settings.json.statusLine = { type = "command"; command = "..."; }` in the Home Manager activation merger.

**Effort:** ~2 hours.
**Risk:** Trivial.
**Dependencies:** Writing `last-status` requires a 1-line addition to `rebuild-nixos` exit handler.

### G5. Phase 4 of rebuild-nixos is a stub `[P0]`

**Today:** `rebuild-nixos:919-935` checks two files exist. That's it.

**Why for ClaudeOS (I1, I5):** Phase 4 should validate declarative intent vs actual `~/.claude/` state:

- Plugin versions installed under `~/.claude/plugins/cache/` match `enabledPlugins` claims
- All `home.file` symlinks under `~/.claude/` are valid (no dangling)
- Custom hooks register in `settings.json.hooks.*` correctly (dry-run a JSON event through each)
- Custom subagents are syntactically valid (parse frontmatter)
- `~/.claude/seccomp/apply-seccomp` is executable and BPF SHA matches `pkgs/claude-seccomp.nix` expectations
- **Sandbox schema check** (G19): warn if `sandbox.seccomp.*` keys are in `settings.json` but the running CC version expects `sandbox.{enabled,filesystem,network}`
- Stale-file scan: warn if `~/.claude/agents/`, `output-styles/`, `commands/` contain non-Nix-managed files (drift detector)

**Sketch:** Move into `scripts/check-claude-config.sh` (testable in isolation), invoke from Phase 4. JSON output consumable by telemetry MCP.

**Effort:** ~3 hours.
**Risk:** Low — current phase does nothing.
**Dependencies:** None hard.

### G6. rebuild-nixos has no structured event log `[P1]`

**Today:** Logs are text at `$LOG_DIR/rebuild-$TIMESTAMP.log` (`:104-107`).

**Why for ClaudeOS:** Downstream consumers wanting this:
- Telemetry MCP (G3)
- `PushNotification` hook on build success/failure (G7)
- Statusline (G4) `last-status` file
- Plugin `monitors/monitors.json` (G22) — each event line becomes a CC notification
- Future `/loop`-based or `CronCreate`-based automation

**Sketch:** Add `log_event() { echo "{\"ts\":\"$(date -Iseconds)\",\"phase\":\"$1\",\"event\":\"$2\",...}" >> "$EVENT_LOG"; }` and sprinkle at phase boundaries.

**Effort:** ~2 hours.
**Risk:** Trivial.
**Dependencies:** None. Enables G3, G4, G7, G22.

### G7. No PushNotification integration `[P1]`

**Today:** `rebuild-nixos` prints to stdout. No desktop/phone notification on long-build completion or failure.

**Why for ClaudeOS (I3):** When a remote business host rebuilds, the admin should know without polling. v2.1.141 `terminalSequence` in statusline plus `Notification` hook + Channels MCPs (Telegram) make this much easier than it was even 3 months ago.

**Sketch:**
- Local: `notify-send` on rebuild success/failure
- Cross-host: leverage Channels (Telegram MCP plugin) — a `Stop`-hook subagent summarizes and pushes
- Or simpler: `PushNotification` tool from a hook agent

**Effort:** ~1 hour local; ~3 hours cross-host.
**Risk:** Low.
**Dependencies:** G6.

### G8. No use of CronCreate / Routines `[P1]`

**Today:** `nix flake update` runs only when manually invoked. Same for `--verify-bootstrap`. Background scheduling primitives (`CronCreate`/`CronList`/`CronDelete`, with 7-day auto-expiry) and cloud Routines unused.

**Why for ClaudeOS (I2, I5):**
- **Nightly:** `nix flake update` + open PR with lockfile diff (committed only after CI green)
- **Weekly:** `./rebuild-nixos --audit` unattended, manifest diffed, alerts on unexpected FOD additions
- **Quarterly:** Full reproducibility re-verification across all hosts
- **Routines (cloud)** with GitHub trigger — kick off a fleet rebuild when CI on `master` goes green

**Sketch:** Two-track approach. Local: NixOS systemd timers calling `claude -p "..."` (declarative — fits I1). Cloud: Routines for cross-fleet orchestration.

**Effort:** ~2 hours per scheduled task.
**Risk:** Low (local) / Medium (Routines is research preview).
**Dependencies:** None.

### G9. Output styles consumed, never published `[P2]`

**Today:** `explanatory-output-style` and `learning-output-style` enabled. Both general-purpose. No `nixos-maintainer` style.

**Why for ClaudeOS:** A custom style could enforce:
- "When suggesting a package, cite the table from CLAUDE.md to declare which module file it belongs in"
- "When proposing a change to a `tl-biz-*` or `ama-biz-*` host, check Invariant #7 (tech↔business separation) and call out potential leakage"
- "When responding to a request that touches `rebuild-nixos`, note relevant exit-code semantics and rollback path"

**Effort:** ~3 hours.
**Risk:** Trivial.
**Dependencies:** G2 (plugin) is the natural home.

### G10. Plan-mode policy undeclared `[P2]`

**Today:** `company-policies.md:12` instructs "start complex tasks in plan mode" but no programmatic enforcement.

**Why for ClaudeOS (I3):** Some operations should *never* run without an approved plan: anything touching `rebuild-nixos`, `flake.nix`, `hosts/*`, `modules/hardware/*`. A `UserPromptSubmit` hook can check the prompt for keywords and inject a plan-mode directive.

**Sketch:**
```sh
# UserPromptSubmit hook
PROMPT=$(jq -r '.prompt' <&0)
if echo "$PROMPT" | grep -qiE 'rebuild|flake.nix|hosts/|hardware/'; then
  jq -n --arg msg "This area requires plan mode. Press Shift+Tab twice." \
    '{"decision":"continue","systemMessage":$msg}'
fi
```

**Effort:** ~2 hours.
**Risk:** Could be annoying if too broad; start conservative.
**Dependencies:** None.

### G11. `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set but unused `[P2]`

**Today:** Flag enabled (`default.nix:56`) but no team workflows invoked.

**Why for ClaudeOS:** Teams are the natural primitive for fleet ops:
- A `fleet-rebuild` team where each teammate owns one host and rebuilds in parallel
- A `supply-chain-audit` team where each teammate owns one phase (FOD verification, license audit, vulnerability scan)

Either start using the flag, or remove it (declarative integrity).

**Effort:** ~1 day for one real team workflow.
**Risk:** Experimental flag — could break in a future CC update.
**Dependencies:** Best built atop G1 (subagents).

### G12. `claude-automation` flake input is ARCHIVED `[P0]` (was G16)

**Today:** Listed at `flake.nix:59-62` and pulled into `outputs` (`:93`). Per the upstream README, **the project was archived on March 4, 2026**, explicitly "superseded by Claude Code's native features (skills, `permissions.allow/ask/deny`, `claudeMd`, `skillOverrides`, `claudeMdExcludes`, auto memory, `/memory`, `.claude/rules/`)."

I find no explicit reference to its outputs in any module file. The comment at `flake.nix:57` says "CLAUDE.md management tools" — yet `rebuild-nixos:919-935` Phase 4 says "Claude configs are now hand-maintained" (which is consistent with the upstream being archived).

**Why for ClaudeOS (I1, I2, I5):** Three reasons this is P0, not P1 or P2:
1. **Growing drift** — every flake.lock bump pulls from a dead repo. Anything new in CC after March 4 (Agent View, `/goal`, Routines, Channels, new hooks, sandbox schema) the input cannot help with.
2. **Closure bloat** — it pulls Python + 27 Jinja2 templates, evaluated even if unused.
3. **Supply-chain auditability (I5)** — an archived repo can be transferred or compromised without anyone watching upstream.

**Action options:**
1. **Remove the input** (`flake.nix:59-62, 93`) and `flake.lock` entry. Verify nothing breaks: `nix flake check`, `nix build .#nixosConfigurations.framework-16.config.system.build.toplevel --dry-run`.
2. **Fork it** to `jacopone/claudeos-fleet` and rebuild the bits you actually use (likely none, given Phase 4's stub state).
3. **Document the keep decision** in `flake.nix` comment with a MAINTAINER note explaining what it provides that native CC features don't.

Recommendation: option 1.

**Effort:** 1 hour (verify, remove, rebuild test).
**Risk:** Low — if it's truly unused, removal is safe.
**Dependencies:** None.

### G13. Sandbox settings schema may be obsolete `[P0]` (was implicit)

**Today:** `modules/home-manager/claude-code/default.nix:51-54` writes:
```nix
"sandbox": {"seccomp": {
  "bpfPath": ($home + "/.claude/seccomp/unix-block.bpf"),
  "applyPath": ($home + "/.claude/seccomp/apply-seccomp")
}}
```

The 2026 sandbox docs page (`code.claude.com/docs/en/sandboxing`) lists a top-level `sandbox` settings object with:
```
enabled, failIfUnavailable, autoAllowBashIfSandboxed,
filesystem.{allowWrite, denyWrite, allowRead, denyRead},
network.{allowedDomains, deniedDomains, allowAllUnixSockets, allowLocalBinding},
bwrapPath (v2.1.133), socatPath (v2.1.133)
```

`sandbox.seccomp.*` is **not** listed in the current schema. Either:
- The seccomp wiring is silently ignored (your custom BPF doesn't run — biggest risk)
- It's still honored via a legacy/extension path (best case)
- It moved to a different settings key (medium risk — need to find it)

**Why for ClaudeOS (I4):** Invariant #4 says "Sandbox isolation … don't bypass." If the seccomp filter is silently no-op'd, the invariant is unmet without anyone knowing.

**Action:**
1. Run `claude --print-settings-schema` (if available) or fetch the live schema doc; confirm whether `sandbox.seccomp.*` is recognized.
2. Verify at runtime: in a sandboxed session, attempt to bind a Unix socket — should fail with EPERM if seccomp is active.
3. If obsolete: either migrate to native sandbox controls (`sandbox.filesystem.*` + `sandbox.network.allowAllUnixSockets: false`?) **or** find the new wiring path for custom BPF.

**Effort:** 2 hours investigation + (if migration needed) ~half day.
**Risk:** **High if obsolete** — security control silently disabled.
**Dependencies:** None.

### G14. `scripts/claude-autonomous.sh` largely superseded by Agent View `[P0 pilot, P1 migration]`

**Today:** ~700-line shell script implementing: per-task git worktree creation, headless `claude` invocation with `--dangerously-skip-permissions`, Ralph loop (max-iter loop with COMPLETED.md/BLOCKERS.md exit), research mode (autoresearch metric-keep-or-revert), tmux session for unattended runs, log file aggregation.

**What v2.1.139 ships (May 11, 2026):**
- **Agent View / `claude agents` TUI**: dispatch many sessions, peek/attach/detach. Supervisor process keeps them alive without a terminal. `/bg`, `←`, `claude --bg`. CLI mgmt: `claude attach/logs/stop/respawn/rm`.
- **Auto-isolating worktrees** under `.claude/worktrees/` (config: `worktree.baseRef` default `fresh`, `worktree.bgIsolation` v2.1.143).
- **`/goal`** command: sets completion condition, runs until met, with elapsed/turns/tokens overlay.

This covers ~80% of `claude-autonomous.sh`: worktree isolation (auto), background runs (`--bg` + supervisor), completion criteria (`/goal` instead of file markers), log access (`claude logs`).

What `claude-autonomous.sh` *uniquely* provides:
- Research-mode autoresearch loop (metric-driven keep/revert) — not in Agent View AFAICT
- Strict mode (80% coverage + security scan injection) — could be a custom prompt template
- Headless Playwright MCP override for demo screenshots — could be per-agent `mcpServers` config
- Pre-baked TDD / judge-driven prompts — could be reusable prompts or skills

**Why for ClaudeOS (I3, I4, I6):**
- Native primitive = less custom shell to maintain
- Auto-worktree means no manual `.worktrees/` cleanup (your Phase 14 already does some of this)
- `--bg` supervisor is more reliable than tmux session loss on shell exit
- Per-agent `mcpServers` frontmatter cleaner than overriding `.mcp.json` at `claude-autonomous.sh:250-260`

**Action:**
1. **Pilot (P0):** Use `claude agents` for one real task that would have used `claude-autonomous.sh`. Document differences. Time-box: 4 hours.
2. **Migrate task-mode (P1):** Port the simple `--no-ralph` and Ralph-loop modes to Agent View + `/goal`. Keep the script as fallback.
3. **Preserve research mode (P2):** That autoresearch pattern is genuinely novel and not yet a CC primitive. Keep as-is or convert to a custom subagent (`autoresearch-runner`).
4. **Deprecate strict mode prompts:** Move TDD/strict prompts into reusable skill or prompt templates.

**Effort:** 4h pilot, 1d migration, 1d strict-mode preservation.
**Risk:** Medium — script is heavily used. Migrate incrementally.
**Dependencies:** None hard; the script can coexist with Agent View.

### G15. `claudeMd` managed setting unused `[P0]`

**Today:** `company-policies.md` is wired via `home.file` symlink at `modules/home-manager/claude-code/default.nix:12`. Symlinks in `~/.claude/` can be deleted, replaced, or shadowed by a user (your own `claude-business-hooks` activation at `business/home-manager/default.nix:32-46` literally mutates `~/.claude/settings.json`).

The 2026 `claudeMd` managed setting (in `/etc/claude-code/managed-settings.json` on Linux per the settings page) injects org-wide CLAUDE.md content that **cannot be excluded by users**. This is the *correct* deployment path for ClaudeOS company policies.

**Why for ClaudeOS (I1, I7):**
- True declarativity: managed-settings.json is owned by `environment.etc` (root-only)
- Business users can't accidentally or deliberately bypass company policies
- Tech-business separation cleaner: `claudeMd` for hard rules, user CLAUDE.md for personal additions

**Sketch:**
```nix
# new module: modules/common/claude-code-managed.nix
{ pkgs, ... }: {
  environment.etc."claude-code/managed-settings.json".source =
    pkgs.writeText "managed-settings.json" (builtins.toJSON {
      claudeMd = builtins.readFile ./company-policies.md;
      # Plus other org-wide locks:
      strictKnownMarketplaces = true;
      blockedMarketplaces = [ ];
      # Optional:
      # autoMode.hard_deny = [ ... ];
      # policyHelper = "/run/wrappers/bin/claudeos-policy-helper";
    });
}
```

Then `home.file.".claude/CLAUDE.md".source` at `default.nix:12` becomes optional / a personal note layer, not the policy layer.

**Effort:** ~3 hours.
**Risk:** Low — additive at first; can run both paths during transition.
**Dependencies:** G16 (helps the rules-vs-policies split).

### G16. `.claude/rules/` with path-scoped frontmatter unused `[P1]`

**Today:** CLAUDE.md is monolithic at `modules/home-manager/claude-code/company-policies.md` (45 lines but growing). The CLAUDE.md root file is now 173 lines after the recent "ClaudeOS" rewrite. Everything loads regardless of what you're working on.

**Why for ClaudeOS (I1, I6):** `.claude/rules/` (2026) supports `paths:` frontmatter glob, loaded on demand when matching files are read. Split monolith into:

- `.claude/rules/git.md` (`paths: .git/**, **/.git/**`) — current §Git Workflow content
- `.claude/rules/rebuild-nixos.md` (`paths: rebuild-nixos, scripts/**, modules/**/claude-code/**`) — Phase semantics, exit-code conventions
- `.claude/rules/business-hosts.md` (`paths: modules/business/**, hosts/*-biz-*/**`) — Invariant #7 enforcement
- `.claude/rules/hardware.md` (`paths: modules/hardware/**, hosts/*/hardware-configuration.nix`) — auto-gen warnings, T2-Mac quirks
- `.claude/rules/flake.md` (`paths: flake.nix, flake.lock`) — MAINTAINER comment requirement
- Core CLAUDE.md keeps only invariants + project overview

Smaller context per task, more precise guidance.

**Effort:** ~4 hours (refactor + verify load-on-demand works).
**Risk:** Low.
**Dependencies:** G15 (managed-settings rewires CLAUDE.md authority).

### G17. New 2026 hook events unused `[P1]`

**Today:** Repo wires one event (`PreToolUse` for business guardrail). Of the 27+ events documented, 0 admin hooks live.

**Why for ClaudeOS:** High-value events listed in §1.3 with concrete ClaudeOS use cases. Highest-leverage three:

1. **`FileChanged`** — auto-trigger `nix flake check` after `flake.nix` edit, surface result inline before user re-reads
2. **`InstructionsLoaded`** — verify CLAUDE.md hash matches canonical; refuse to proceed on drift
3. **`PreCompact`** — save context snapshot to `.claude/rules/` so compaction doesn't drop critical state

**Effort:** ~2 hours per hook.
**Risk:** Low.
**Dependencies:** None.

### G18. `monitors/monitors.json` not used `[P1]`

**Today:** No plugin shipping a monitor. `rebuild-nixos` output is invisible to in-session Claude.

**Why for ClaudeOS:** A `claudeos-fleet` plugin's `monitors/monitors.json` could declare:
```json
{
  "monitors": [{
    "name": "rebuild-nixos-events",
    "command": ["tail", "-F", "~/.local/state/rebuild-nixos/events.jsonl"]
  }]
}
```

Each event line becomes a CC notification, surfacing rebuild progress mid-session without polling.

**Effort:** ~2 hours after G2 (plugin) and G6 (event log).
**Risk:** Low.
**Dependencies:** G2, G6.

### G19. Channels (Telegram/iMessage push) unused `[P2]`

**Today:** No bridge from external messengers into running CC sessions.

**Why for ClaudeOS:** A Telegram channel plugin (research preview, v2.1.80) could push:
- "tl-biz-001 rebuild succeeded, gen 84" → admin's Telegram
- "ama-biz-001 needs reboot" → user's Telegram (with reply → triggers `/reboot` in their session)
- "flake.lock drift detected" → channel + auto-creates a Routine to investigate

`channelsEnabled` and `allowedChannelPlugins` settings to control exposure.

**Effort:** ~1 day to set up + test one channel.
**Risk:** Medium — research preview; API may change.
**Dependencies:** G2 (plugin) is a natural home; G6 (events log) feeds it.

### G20. Routines (cloud) unused `[P2]`

**Today:** No cloud-side automation.

**Why for ClaudeOS:** GitHub-triggered Routines could:
- On `master` push: rebuild reference image of `framework-16` host in a CI box; diff closure against expected; fail if unexpected delta
- On `flake.lock` change in PR: run `nix flake check` against all `nixosConfigurations.*` and post status to PR
- Weekly: `--audit` rerun, diff against prior, alert on drift

**Effort:** ~1 day per routine (write + test).
**Risk:** Medium — research preview, API `/fire` endpoint behind experimental header.
**Dependencies:** None hard.

### G21. Stale `.claude/` archaeology `[P0 cleanup]`

**Today:** ~75KB of stale audit/analytics files predating "Phase 8 (Adaptive Learning) removal." See §2.7.

**Why for ClaudeOS (I1):** These files mislead future AI agents reading the repo. Auto-memory would happily reference outdated `tool-analytics.md`. They violate the "no temporal markers / no hyperbole" doc policy by being literal frozen snapshots from Feb.

**Action:** `git rm` the 7 listed files in §2.7. Move `tdd-guard/` to `.gitignore` if Phase 14 doesn't already handle it.

**Effort:** ~10 minutes.
**Risk:** Trivial.

### G22. `nixos.md` slash command is context-only `[P2]`

**Today:** `commands/nixos.md` is descriptive (`description: NixOS domain knowledge — flakes, modules, Home Manager, audio, MCP servers, CI/CD`). Skills explain; commands act.

**Action:** Split:
- `/nixos-package <query>` command that calls MCP-NixOS and returns "use `pkgs.X` in `modules/Y/packages.nix`"
- `nixos-context` skill loading on demand

**Effort:** ~2 hours.
**Risk:** Trivial.
**Dependencies:** G3 (MCP-NixOS wired).

### G23. No skills published `[P2]`

**Today:** Consume `superpowers`, `gstack`, `document-skills`, etc. Publish zero.

**Why:** Candidates:
- `claudeos-onboarding` — installing a new host (parallels `INSTALL.md`)
- `nix-flake-debug` — systematic flow when `nix flake check` fails
- `framework-16-power` — diagnostic flow for Strix Point power anomalies

**Effort:** ~2 hours per skill.
**Risk:** Trivial.
**Dependencies:** G2 (plugin) is natural home.

### G24. Settings keys neither set nor documented `[P2]`

**Today:** ~30 settings keys (§1.4) are at default. Some defaults are silent — a value change in CC could alter behavior without anyone noticing.

**Action:** For each key in §1.4, explicitly set or comment "default is OK because …" in `default.nix` or `company-config.json`. Especially:
- `worktree.baseRef` — implied behavior of Agent View
- `parentSettingsBehavior` — what happens when both `~/.claude/settings.json` and project `.claude/settings.json` exist
- `autoMode.hard_deny` — does anything need a permanent denial?
- `disableRemoteControl` — set `true` on business hosts

**Effort:** ~2 hours to inventory and decide.
**Risk:** Low.
**Dependencies:** None.

---

## 4. `rebuild-nixos` Deep Dive

A 1478-line script with 14 numbered phases (5, 6, 8 vacated). Below: phase-by-phase pass focused on Claude Code integration opportunities.

### Structural observations

- **Phase numbering has gaps** (`:457` → Phase 2 from Phase 1, `:919` is Phase 4 after Phase 2.8, `:938` jumps to Phase 7, `:1049` Phase 9, then `:1191` says "Phases 11-14"). Archaeology — Phases 5, 6, 8 were removed. Renumber once stable, or annotate gaps with comments.
- **`NIXOS_REBUILD_WRAPPER=1`** at `:33` — env vars are weak attestation. With v2.1.136 `policyHelper`, a short-lived signed token would be cleaner. Marginal security; flag for paranoid mode.
- **Trap handler at `:11-30`** is robust for cleanup but does not log a structured failure event — see G6.
- **`prompt_user`** at `:182-194` is clean. Could route long prompts through a subagent (e.g., changelog draft → `changelog-summarizer` subagent rather than `$EDITOR`).
- **BATS tests** at `tests/bash/rebuild-nixos/{test-input-parsing,test-pipefail-protection,test-script-structure}.bats` cover 3 axes. Phase logic largely uncovered.

### Phase-by-phase audit

| Phase | Lines | What it does | CC integration opportunity |
|-------|-------|--------------|---------------------------|
| 0 — Eval-Cache Management | 360-456 | Clears `~/.cache/nix/eval-cache-*` and the trusted-settings.json override that can resurrect it | `log_event` on cache clear; surface in MCP |
| 1 — Update Flake Inputs (admin) | 457-500 | Conditional `nix flake update` | Dispatch to per-input subagent: update one input at a time, run `nix flake check` per input, open separate commits — much cleaner blame |
| 2 — Test Build | 501-564 | Dry-build to validate | Pipe `nom` output to a subagent on failure → "summarize first 3 errors and propose fixes"; auto-`--fresh` retry on detected cache-related errors |
| 2.5 — Package Diff Preview | 565-614 | `nvd diff` preview | Exact job for the `generation-differ` subagent (G1). Replace inline output with subagent summary on long diffs |
| 2.7.4-2.7.5 — Audit Trail Export | 615-731 | Source manifest + closure export (`--audit`) | Emit JSON manifest alongside; consumable by supply-chain MCP server |
| 2.8 — Bootstrap Package Verification | 732-825 | Deep reproducibility check | `log_event` per verified package; surface trend over time via MCP resource |
| 3 — Activate Configuration | 826-918 | `switch` or `boot` activation | `PushNotification`/Channel on completion (G7, G19); on failure, dispatch `flake-debugger` subagent (G1) with stderr context |
| 4 — Claude Config Check (admin) | 919-935 | **17-line stub** | Full rewrite — see G5 |
| 7 — Changelog Draft Generation (admin) | 938-1045 | Calls `scripts/generate-changelog-draft.sh` | Replace shell script with a `changelog-summarizer` subagent: pass commit list, ask for conventional-commit-grouped output with auto-grouping by file area; user previews and confirms |
| 9 — User Acceptance | 1049-1083 | Switch-mode prompt | On `--boot` mode (new at `:142-150`), schedule a `ScheduleWakeup` to remind/verify after reboot |
| 10 — Generation Cleanup | 1084-1190 | Generation pruning | `log_event` on prune; MCP resource for generation history |
| 11 — Disk Space Analysis (admin) | 1195-1265 | Disk usage report | No Claude integration needed; pure shell |
| 12 — Cache Cleanup (admin) | 1266-1338 | Nix cache cleanup | No Claude integration needed |
| 13 — Claude Temp File Cleanup | 1339-1370 | Removes `learner_counter_*` and `security_warnings_state_*` orphans | Also clean: stale files in `.claude/` per G21, `.backup` files in `~/.claude/hooks/`, dangling symlinks |
| 14 — Claude Backup Cleanup | 1372-1408 | Interactive `.backups/` cleanup | Auto-mode if older than N days; record cleanup events |

### Test coverage gap

`tests/bash/rebuild-nixos/` covers parse/pipefail/structure. Untested:
- Phase 0 trusted-settings.json clobber logic (one of the trickiest bits in the script)
- Phase 2.8 bootstrap verification correctness
- Phase 3 boot-mode handler (`:142-150` is new per commit `7cc071a feat(rebuild-nixos): add --boot mode`)
- Phase 7 changelog state-file logic

Deserves BATS expansion independent of CC integration.

### Refactor candidates (non-CC)

- Phases 11-14 admin-only block runs as one big `if` (`:1192-1410`). Could be a function per phase.
- Trap handler `:11-30` should `_log_failure_event` for structured logging.
- Phase numbering renumber once stable; or replace numbered phases with named functions registered to a phase registry (NixOS-module-like), allowing plugins to inject phases.

---

## 5. Prioritized Roadmap

Tagged `[risk:stable|beta|experimental]` based on §1 inventory.

### P0 — High impact, low-to-medium effort, this week

| # | Title | Impact | Effort | Risk | Files / new | Depends |
|---|-------|--------|--------|------|-------------|---------|
| P0-1 | Remove `claude-automation` flake input (or document keep) | 5 | 1h | stable | `flake.nix:59-62, 93`, `flake.lock` | — |
| P0-2 | Verify sandbox settings schema; migrate if obsolete | 5 | 2h investigation, +0.5d if migration | stable | `default.nix:51-54`, `company-config.json` | — |
| P0-3 | Migrate `company-policies.md` to `claudeMd` managed setting | 4 | 3h | stable | new `modules/common/claude-code-managed.nix`, `default.nix:12` | — |
| P0-4 | Pilot Agent View (`claude agents` TUI) as `claude-autonomous.sh` replacement | 5 | 4h | stable | `scripts/claude-autonomous.sh`, new helper | — |
| P0-5 | Wire `.mcp.json` with MCP-NixOS minimum | 4 | 30min | stable | `.mcp.json` | — |
| P0-6 | Ship 4 declarative subagents | 5 | 1d | stable | `modules/home-manager/claude-code/agents/*.md` | — |
| P0-7 | Statusline (host/class/gen/branch/last-build) | 4 | 2h | stable | `modules/home-manager/claude-code/statusline.sh`, `default.nix` | (P1-1 optional) |
| P0-8 | Refactor `rebuild-nixos:919-935` Phase 4 into real validator | 4 | 3h | stable | `rebuild-nixos`, `scripts/check-claude-config.sh` | — |
| P0-9 | Clean stale `.claude/` files | 3 | 10min | stable | `git rm …` | — |

### P1 — High impact, medium-to-large effort, this month

| # | Title | Impact | Effort | Risk | Files / new | Depends |
|---|-------|--------|--------|------|-------------|---------|
| P1-1 | Add `log_event` JSON structured logging to `rebuild-nixos` | 4 | 2h | stable | `rebuild-nixos` | enables P0-7, P1-2, P1-3, P1-6 |
| P1-2 | Custom build-telemetry MCP server | 4 | 2d | stable | new `pkgs/mcp-rebuild-telemetry/` | P1-1 |
| P1-3 | `PushNotification`/`Notification` hook on rebuild events | 3 | 3h | stable | new hook | P1-1 |
| P1-4 | Publish `claudeos-fleet` plugin (commands+agents+skills+hooks+monitors) | 4 | 1w | stable | new repo `claudeos-fleet` | P0-6 |
| P1-5 | CronCreate / systemd timer for nightly `nix flake update` + PR | 4 | 4h | stable | new systemd timer or `~/.claude/cron/` | — |
| P1-6 | `monitors/monitors.json` for `rebuild-nixos` event stream | 3 | 2h | stable | inside `claudeos-fleet` | P1-1, P1-4 |
| P1-7 | Refactor CLAUDE.md monolith into `.claude/rules/` with `paths:` globs | 3 | 4h | stable | new `.claude/rules/*.md` | P0-3 |
| P1-8 | Migrate Ralph-loop tasks from `claude-autonomous.sh` to Agent View + `/goal` | 4 | 1d | stable | `claude-autonomous.sh` | P0-4 |
| P1-9 | Wire 3 high-value new hook events (`FileChanged`, `InstructionsLoaded`, `PreCompact`) | 3 | 6h | stable | new admin hooks | — |

### P2 — Lower impact or higher risk, this quarter

| # | Title | Impact | Effort | Risk | Files / new | Depends |
|---|-------|--------|--------|------|-------------|---------|
| P2-1 | Custom output style `nixos-maintainer` | 2 | 3h | stable | new `output-styles/nixos-maintainer.md` | P1-4 |
| P2-2 | Plan-mode policy via `UserPromptSubmit` hook | 3 | 2h | stable | new hook | — |
| P2-3 | Real agent-teams workflow (`fleet-rebuild` or `supply-chain-audit`) | 3 | 1d | **experimental** | new helper commands | P0-6 |
| P2-4 | Refactor `nixos.md` into `/nixos-package` action + `nixos-context` skill | 2 | 2h | stable | `commands/nixos.md`, new skill | P0-5 |
| P2-5 | Publish 3 skills (`claudeos-onboarding`, `nix-flake-debug`, `framework-16-power`) | 3 | 6h total | stable | inside `claudeos-fleet` | P1-4 |
| P2-6 | Expand BATS coverage for Phases 0, 2.8, 3 (`--boot`), 7 | 3 | 1d | stable | `tests/bash/rebuild-nixos/` | — |
| P2-7 | Phase renumbering / phase-registry refactor | 2 | 2d | stable | `rebuild-nixos` | P2-6 |
| P2-8 | Stronger `NIXOS_REBUILD_WRAPPER` attestation (signed token + `policyHelper`) | 2 | 4h | stable | `rebuild-nixos`, hook configs | — |
| P2-9 | Per-input flake-update subagent flow (Phase 1) | 3 | 1d | stable | `rebuild-nixos`, new agent | P0-6 |
| P2-10 | Auto-mode for Phase 14 (`.backups/` cleanup by age) | 2 | 1h | stable | `rebuild-nixos` | — |
| P2-11 | Preserve `claude-autonomous.sh` research-mode as `autoresearch-runner` subagent | 3 | 4h | stable | new subagent | P0-4 |
| P2-12 | Telegram channel plugin for fleet ops notifications | 3 | 1d | **beta** | inside `claudeos-fleet` | P1-4, P1-1 |
| P2-13 | GitHub-triggered Routine for CI-driven fleet rebuild | 3 | 1d | **research preview** | cloud Routine | P1-1 |
| P2-14 | Inventory + explicitly set or document the ~30 settings keys in §1.4 | 2 | 2h | stable | `company-config.json` | — |
| P2-15 | `disableRemoteControl=true` on business hosts | 2 | 1h | stable | `modules/business/home-manager/default.nix` | — |
| P2-16 | Strict-mode prompt templates from `claude-autonomous.sh` → reusable skill | 2 | 2h | stable | new skill | P0-4 |

### Dependency graph

```
P0-1 (remove archived input) ───→ no deps unblocked
P0-2 (sandbox schema verify) ────→ unlocks invariant #4 confidence
P0-3 (claudeMd managed) ─────────→ P1-7 (rules refactor)
P0-4 (Agent View pilot) ─────────→ P1-8 (migrate Ralph), P2-11 (research mode), P2-16 (strict prompts)
P0-5 (MCP-NixOS) ────────────────→ P2-4 (nixos.md refactor)
P0-6 (subagents) ────────────────→ P1-4 (plugin), P2-3 (teams), P2-9 (per-input update)
P1-1 (log_event) ────────────────→ P0-7 (statusline), P1-2 (telemetry MCP), P1-3 (notifications), P1-6 (monitor), P2-12 (Telegram), P2-13 (Routine)
P1-4 (plugin) ───────────────────→ P1-6 (monitor inside), P2-1 (style), P2-5 (skills), P2-12 (Telegram)
```

### Suggested execution order (one possible sequence)

1. **Triage first** (P0-1 remove archived input, P0-2 sandbox verify) — ~3 hours. These are blocking unknowns; resolve before anything else.
2. **Cleanup** (P0-9 stale files, ~10min).
3. **Foundation** (P1-1 log_event, ~2h; P0-8 Phase 4 validator, ~3h; P0-3 claudeMd, ~3h) — these unlock most others. ~1 day.
4. **Highest-leverage primitives** (P0-6 subagents, ~1d; P0-7 statusline, ~2h; P0-5 MCP-NixOS, 30min). ~1.5 days.
5. **Agent View pilot** (P0-4, ~4h) — start the migration off `claude-autonomous.sh`.
6. **Plugin packaging** (P1-4 `claudeos-fleet`) once you have 4+ subagents, the statusline, and the new admin hooks. ~1 week.
7. **Scheduling + notifications** (P1-3, P1-5, P1-9) as you have time.
8. **Polish** (P2 items) at quarterly cadence; research-preview items (channels, routines) when their docs stabilize.

---

## Appendix A — Stale artifacts to remove (G21 detail)

```sh
git rm .claude/CLAUDE_CODE_ANALYSIS.md     # 25KB, 2026-02-09
git rm .claude/tool-analytics.md           # 42KB, 2026-02-09
git rm .claude/mcp-analytics.md            # 920B, 2026-02-09
git rm .claude/permissions_auto_generated.md  # 3.8KB, 2026-01-11
git rm .claude/ANALYSIS_SUMMARY.txt        # 3.9KB, 2026-02-06
git rm .claude/CLAUDE.local.md             # 1.7KB, stale auto-gen
git rm .claude/mcp.json                    # 23B, empty placeholder

# Local (not in git):
rm -rf ~/.claude/hooks/*.backup
```

Before removing, run `git log -- .claude/CLAUDE_CODE_ANALYSIS.md` to confirm origin (likely one-shot run of an analysis tool that was never re-run).

## Appendix B — Investigation prerequisites

Resolve `[verify]` items before acting on dependent recommendations:

- **`claude-automation` consumption** (G12): grep `flake.nix` outputs and all `hosts/*/default.nix`, `modules/**/*.nix` for `claude-automation.*`. If unwired, remove (P0-1).
- **MCP-NixOS expected location** (G3): confirm with `claude --print mcp list` or equivalent that neither `.mcp.json` nor `~/.claude/settings.json` provides it elsewhere. Empirically both are empty.
- **`alwaysThinkingEnabled` vs `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING`** (`default.nix:55, 27`): these may be redundant. Verify against current CC docs.
- **Sandbox schema** (G13, P0-2): the critical investigation — verify `sandbox.seccomp.*` is still honored or migrate to current schema.

## Appendix C — Out of scope

- Business-track CC improvements (per session scope: "you only — maximize personal capability")
- Non-Claude-Code Nix improvements unrelated to a CC integration
- Implementation of any recommendation (per session scope: "audit + recommend only")
- AI tools other than Claude Code (Cursor, Antigravity, Gemini CLI)
- Comparison with other AI coding agents

## Appendix D — Tool-name corrections (clarifying this session's earlier text)

| Name used earlier | Correct 2026 name | Notes |
|-------------------|-------------------|-------|
| `TeamCreate` | (no tool — natural language to lead agent) | Teams gated by `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`; created conversationally |
| `ScheduleWakeup` | `ScheduleWakeup` (correct) | Exists; dynamic `/loop` pacing |
| `CronCreate`/`List`/`Delete` | `CronCreate`/`CronList`/`CronDelete` | 7-day auto-expiry; `CLAUDE_CODE_DISABLE_CRON=1` to disable |

## Appendix E — Docs URL migration

Old: `docs.claude.com/en/docs/claude-code/<page>`
New: `code.claude.com/docs/en/<page>` (301 redirects in place)
Index: `code.claude.com/docs/llms.txt`

Repo references to update:
- `modules/home-manager/claude-code/commands/nixos.md` — references MCP-NixOS via `.mcp.json` (no docs URL; OK)
- `CLAUDE.md` root — "Dynamic Context" section mentions MCP-NixOS; OK
- Any other `claude.com/...` link in `docs/**` or comments — re-grep before P0-3.

## Appendix F — June 15 2026 billing change

Per `code.claude.com/docs/en/headless`: from June 15, 2026, Agent SDK and `claude -p` on subscription plans will draw from a **separate monthly Agent SDK credit**. Implication for ClaudeOS:

- `scripts/claude-autonomous.sh:637-639` runs `claude -p` heavily during long Ralph loops and research-mode runs
- Agent View (P0-4) is *not* `claude -p` based — it uses the interactive supervisor — so migration may reduce billing exposure
- Worth pricing-modeling before June 15

## Appendix G — Quick wins outside the audit scope (informational)

If during execution you also want low-hanging cleanup:

- **Delete `~/.claude/hooks/*.backup`** (local, not in git)
- **Delete `tdd-guard/` directory** in `.claude/` if confirmed orphan
- **Add `xhigh` to consider** as alternative to `max` for `CLAUDE_CODE_EFFORT_LEVEL` on Opus 4.7 (`default.nix:28`)
- **`alwaysThinkingEnabled: true` (`default.nix:55`)** — verify still relevant alongside the env var; may be redundant

---

## Changelog

- 2026-05-18: Initial draft with §1 placeholder
- 2026-05-18: §1 inventory completed from research agent findings; added G12-G24 covering 2026 features (archived input, sandbox schema, Agent View, claudeMd, .claude/rules/, new hooks, monitors, channels, routines); P0 list expanded 5→9
- 2026-05-18: All 9 P0 items implemented per `docs/plans/2026-05-18-claudeos-p0-implementation.md` in 34 commits on `personal`. Status by P0:
  - **P0-1** ✅ claude-automation flake input removed (with `rebuild-nixos:476` LOCAL_INPUTS + `devenv.nix:46` comment also cleaned)
  - **P0-2** ✅ sandbox schema investigated and migrated. Critical finding: `sandbox.seccomp.bpfPath` was being silently stripped by Claude Code's Zod schema since deployment. `vendor/seccomp-src/apply-seccomp.c` now supports dual calling convention (legacy 2-arg + new compile-time BPF_PATH for Claude Code runtime). `claude-seccomp` 0.0.26 → 0.0.27. AF_UNIX socket creation now actually blocks (verified post-rebuild)
  - **P0-3** ✅ company-policies.md migrated to `claudeMd` managed setting in `/etc/claude-code/managed-settings.json` (root-owned, user-deletion-proof). `home.file ~/.claude/CLAUDE.md` symlink removed. Schema fix: `strictKnownMarketplaces`/`blockedMarketplaces` keys removed when first deployment hit "Expected array, but received boolean" — those keys expect arrays of source-pattern objects (queued as follow-up #20)
  - **P0-4** ✅ Agent View pilot designed and documented. Task 23 + 25 docs landed; Task 24 (actually running `claude agents --bg`) deferred to user execution since it requires a fresh CLI invocation outside the implementing session
  - **P0-5** ✅ MCP-NixOS wired in project `.mcp.json` (un-ignored from `.gitignore`). Uses the Nix-pinned `mcp-nixos` wrapper from `modules/core/packages.nix:178-181` (not `uvx mcp-nixos@latest`) for Invariant #2 reproducibility
  - **P0-6** ✅ 4 declarative subagents (`flake-debugger`, `package-finder`, `generation-differ`, `supply-chain-auditor`) deployed via Home Manager. Critical fix mid-implementation: invented frontmatter fields (`isolation: worktree`, `preload_skills`, `mcpServers`) were silently ignored by Claude Code's actual subagent schema; intent moved into prose Constraints sections so agents actually request the behavior they advertise. Stale CLAUDE.md line refs replaced with stable section names. `supply-chain-auditor` manifest path corrected to `~/.nixos-audit/sources-*.manifest` (per `rebuild-nixos:617`)
  - **P0-7** ✅ statusline live: `[host class | gen N | branch | last:?]` showing fleet context glanceably. `modules/common/host-class.nix` writes `/etc/claudeos/host-class` per hostname pattern. Plan's `/run/current-system` generation detection adapted to read `/nix/var/nix/profiles/system-N-link` (real layout). Schema verified against Claude Code 2.1.143 binary before deployment (lesson from P0-6 frontmatter theater)
  - **P0-8** ✅ `rebuild-nixos:919-935` 17-line stub replaced with `scripts/check-claude-config.sh` invocation. 5 checks: plugin_version, symlink, subagent_frontmatter, sandbox_attestation, stale_file. Emits structured JSON event array (consumable by future P1-2 telemetry MCP). Exit codes 0/1/2 for info/warn/error. Live run finds 25 info + 5 warn + 0 error against current `~/.claude/` state; the 5 warns surface real declarative drift (4 plugins missing `.claude-plugin/plugin.json`, 1 expected missing-agents-dir pre-rebuild)
  - **P0-9** ✅ ~75KB of stale `.claude/` archaeology removed (CLAUDE_CODE_ANALYSIS, tool-analytics, mcp-analytics, permissions_auto_generated, ANALYSIS_SUMMARY, CLAUDE.local.md, mcp.json placeholder)

  Plan deviations caught at review gates (each is a plan defect, not implementation issue):
  - P0-1: plan's narrow rg patterns missed `rebuild-nixos:476` array element and `devenv.nix:46` comment (extension authorized atomically)
  - P0-2: plan's "Step 2 + Step 3" had placeholder Options A/B/C; Task 3 investigation drove the chosen approach (compile-time BPF_PATH via Nix derivation -D define)
  - P0-3: plan's `strictKnownMarketplaces: true` and `blockedMarketplaces: []` didn't match Claude Code's actual schema (arrays of source-pattern objects); keys removed in fix commit
  - P0-6: plan's invented subagent frontmatter (per the audit's own §1 inventory speculation) doesn't match Claude Code's actual subagent fields (`name`, `description`, `tools`, `model` only)
  - P0-7: plan's `/run/current-system | grep system-N` didn't match real symlink layout
  - P0-8: plan's pseudocode for plugin cache assumed flat layout; actual is `cache/<marketplace>/<plugin>/<version-hash>/.claude-plugin/plugin.json`

  6 follow-up tasks queued (#15-#22) covering: doc rot from claude-automation removal, BATS test hardening (paths + skip-vs-fail), dry-run corruption in jq merger, sandbox.enabled override of user opt-out, lib.mkDefault wrapping for marketplace locks, validator settings.json parseability check, validator test exit-code grep tightening, plugin cache concurrency warn message.

  Session-bookend artifacts:
  - Audit doc (this file, 933 lines)
  - Implementation plan (`docs/plans/2026-05-18-claudeos-p0-implementation.md`, 2160 lines)
  - Sandbox investigation finding (`docs/plans/2026-05-18-sandbox-schema-finding.md`, 277 lines)
  - Agent View pilot definition (`docs/plans/2026-05-18-agent-view-pilot-task.md`, 88 lines)
  - Agent View findings template (`docs/plans/2026-05-18-agent-view-pilot-findings.md`, 77 lines)
