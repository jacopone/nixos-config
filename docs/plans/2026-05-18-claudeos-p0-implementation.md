# ClaudeOS P0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement all 9 P0 items from `docs/plans/2026-05-18-claude-code-advancements-audit.md` — close the gap between ClaudeOS's invariants and the Claude Code 2026 feature surface.

**Architecture:** Five phases in dependency order. Phase 1 resolves triage unknowns (archived input, sandbox schema, stale files). Phase 2 corrects settings architecture (claudeMd managed setting, MCP wiring). Phase 3 ships new declarative primitives (4 subagents, statusline). Phase 4 turns `rebuild-nixos` Phase 4 from a stub into a real validator. Phase 5 pilots Agent View as `claude-autonomous.sh` successor. Each Task ends with a commit. End-to-end verification between phases.

**Tech Stack:** Nix flakes, Home Manager, Bash, jq, BATS for shell tests. New artifacts: 4 subagent markdown files, 1 statusline shell script, 1 managed-settings NixOS module, 1 validator shell script, 1 MCP config entry.

**Branch policy:** All work on `personal` per `CLAUDE.md:131-138`. Direct commits OK (CI auto-syncs to `master`). After this plan, optionally split into per-Phase PRs for review hygiene.

**Prerequisite:** `./rebuild-nixos` requires sudo. Claude must NOT run it (`CLAUDE.md:145-146`); after each Phase, tell the user to rebuild and verify before moving on.

---

## Sequence and dependency graph

```
Phase 1 — Triage (~3h)
  Task 1: P0-9 stale files cleanup
  Task 2: P0-1 remove claude-automation input
  Task 3: P0-2a sandbox schema investigation
  Task 4: P0-2b sandbox migration (conditional on Task 3)

Phase 2 — Settings architecture (~4h)
  Task 5: P0-5 wire MCP-NixOS minimum
  Task 6: P0-3a managed-settings.json NixOS module
  Task 7: P0-3b migrate CLAUDE.md to claudeMd
  Task 8: P0-3 E2E verification

Phase 3 — Declarative primitives (~10h)
  Task 9-12: P0-6 four subagents (one per task)
  Task 13: P0-6 wire subagents in Home Manager
  Task 14: P0-7a statusline shell script
  Task 15: P0-7b wire statusline in settings.json merger

Phase 4 — rebuild-nixos validator (~3h)
  Task 16: P0-8a extract check-claude-config.sh skeleton
  Task 17: P0-8b plugin version validity check
  Task 18: P0-8c symlink validity check
  Task 19: P0-8d subagent frontmatter parsing
  Task 20: P0-8e sandbox attestation check
  Task 21: P0-8f stale-file scan
  Task 22: P0-8g wire validator into Phase 4

Phase 5 — Agent View pilot (~4h)
  Task 23: P0-4a pilot task definition
  Task 24: P0-4b execute pilot via `claude agents`
  Task 25: P0-4c findings doc + decision

Final
  Task 26: Full E2E verification across all P0 changes
  Task 27: Update audit doc changelog
```

**Total estimated effort:** ~24 hours of focused work (audit estimate was ~23h; pad ~1h for E2E checks).

---

# PHASE 1 — Triage

## Task 1: Remove stale `.claude/` files (P0-9)

**Why:** ~75KB of files from the deprecated "Phase 8 Adaptive Learning" system pollute project context and mislead future AI agents. See audit §2.7 and §G21.

**Files:**
- Delete: `.claude/CLAUDE_CODE_ANALYSIS.md`
- Delete: `.claude/tool-analytics.md`
- Delete: `.claude/mcp-analytics.md`
- Delete: `.claude/permissions_auto_generated.md`
- Delete: `.claude/ANALYSIS_SUMMARY.txt`
- Delete: `.claude/CLAUDE.local.md`
- Delete: `.claude/mcp.json`

**Step 1: Verify each file is truly stale (not used by an active script)**

Run:
```bash
for f in CLAUDE_CODE_ANALYSIS.md tool-analytics.md mcp-analytics.md permissions_auto_generated.md ANALYSIS_SUMMARY.txt CLAUDE.local.md mcp.json; do
  echo "=== $f ==="
  rg -l "\.claude/$f" . --hidden 2>/dev/null | rg -v '^\.claude/' || echo "  no references outside .claude/"
done
```

Expected: each file should report "no references outside .claude/" — meaning no script reads it. If any file IS referenced, STOP and investigate before deleting.

**Step 2: Confirm origin of the largest file**

Run: `git log --follow --oneline -- .claude/CLAUDE_CODE_ANALYSIS.md | head -5`
Expected: should show it was created by a one-shot run, not actively maintained.

**Step 3: Delete the files via git**

Run:
```bash
git rm .claude/CLAUDE_CODE_ANALYSIS.md
git rm .claude/tool-analytics.md
git rm .claude/mcp-analytics.md
git rm .claude/permissions_auto_generated.md
git rm .claude/ANALYSIS_SUMMARY.txt
git rm .claude/CLAUDE.local.md
git rm .claude/mcp.json
```

**Step 4: Verify `.claude/` is cleaner**

Run: `ls -la .claude/`
Expected: only `settings.local.json`, `.changelog-last-processed`, `commands/`, `tdd-guard/`, `.backups/`, `.backups` remain.

**Step 5: Note for follow-up** — `tdd-guard/` and `.backups/` are also legacy candidates; defer to a separate cleanup since they're directories with potentially-still-useful contents.

**Step 6: Commit**

```bash
git commit -m "$(cat <<'EOF'
chore(claude): remove stale Phase 8 Adaptive Learning artifacts

Removes 7 files (~75KB) from the deprecated learning system noted in
rebuild-nixos:1047. Files were one-shot outputs (CLAUDE_CODE_ANALYSIS,
tool-analytics, permissions_auto_generated, mcp-analytics, ANALYSIS_SUMMARY)
or empty placeholders (mcp.json, stale CLAUDE.local.md). None referenced
by active scripts.
EOF
)"
```

---

## Task 2: Remove `claude-automation` flake input (P0-1)

**Why:** The upstream `github:jacopone/claude-nixos-automation` was archived March 4, 2026, "superseded by Claude Code's native features." Every flake.lock bump pulls from a dead repo. See audit §G12.

**Files:**
- Modify: `flake.nix:59-62` (input declaration)
- Modify: `flake.nix:93` (outputs parameter)
- Modify: `flake.lock` (auto-regenerated)

**Step 1: Search for any usage of the input**

Run:
```bash
rg "claude-automation\." -t nix --hidden 2>/dev/null
rg "claude-automation\." -g '*.sh' --hidden 2>/dev/null
rg "inputs\.claude-automation" --hidden 2>/dev/null
```

Expected: zero hits outside `flake.nix:59-62, 93`. If there ARE hits, STOP — the input is wired somewhere; redesign the migration (either keep with deprecation comment, or migrate the dependent code first).

**Step 2: Capture baseline build hash before removal**

Run:
```bash
HOST=$(hostname -s)
nix path-info --derivation .#nixosConfigurations.$HOST.config.system.build.toplevel 2>/dev/null | head -1
```
Save the path. After removal it should be identical (proves no semantic change).

**Step 3: Remove the input declaration**

In `flake.nix`, delete lines 57-62:
```nix
    # Claude NixOS Automation - CLAUDE.md management tools
    # MAINTAINER: @jacopone (YOU) | AUTO-UPDATE: Via rebuild-nixos --refresh
    claude-automation = {
      url = "github:jacopone/claude-nixos-automation";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

**Step 4: Remove from outputs parameter**

In `flake.nix:93`, change:
```nix
outputs = { self, nixpkgs, home-manager, nixos-hardware, claude-code-nix, code-cursor-nix, whisper-dictation, claude-automation, antigravity-nix, gws, ... }@inputs:
```
to:
```nix
outputs = { self, nixpkgs, home-manager, nixos-hardware, claude-code-nix, code-cursor-nix, whisper-dictation, antigravity-nix, gws, ... }@inputs:
```

**Step 5: Regenerate `flake.lock`**

Run: `nix flake lock`
Expected: removes the `claude-automation` entry from `flake.lock` and any pure-deps that were only pulled by it. Verify with: `grep -c claude-automation flake.lock` → should print `0`.

**Step 6: Validate**

Run: `nix flake check`
Expected: passes. If it errors with "attribute claude-automation missing", a module file still references it — go back to Step 1 and search more carefully.

**Step 7: Compare derivation hashes**

Run the same path-info command as Step 2. The derivation hash MAY differ (closure of inputs changed). What matters is `nix flake check` passes; the next rebuild will activate the change.

**Step 8: Commit**

```bash
git add flake.nix flake.lock
git commit -m "$(cat <<'EOF'
chore(flake): remove archived claude-automation input

Upstream github:jacopone/claude-nixos-automation was archived 2026-03-04,
superseded by Claude Code's native features (skills, permissions.allow/ask/deny,
claudeMd, skillOverrides, claudeMdExcludes, auto memory, /memory, .claude/rules/).
No module in this repo references it; closure size drops accordingly.
EOF
)"
```

**Step 9: Tell user to rebuild and verify**

User runs: `./rebuild-nixos --quick`
Expected: clean build, system activates without errors. If anything breaks, the input WAS wired somewhere not caught by Step 1 — investigate and amend.

---

## Task 3: Investigate sandbox settings schema (P0-2a)

**Why:** `modules/home-manager/claude-code/default.nix:51-54` writes `sandbox.seccomp.{bpfPath,applyPath}` which predates the current top-level `sandbox` schema. May be silently no-op'd. See audit §G13.

**Files:**
- Read only: `modules/home-manager/claude-code/default.nix:51-54`, `pkgs/claude-seccomp.nix`

**Step 1: Fetch the current sandbox docs**

Use WebFetch on `https://code.claude.com/docs/en/sandboxing` and on `https://code.claude.com/docs/en/settings` looking for the `sandbox` key. Extract the full schema.

Expected: confirm the top-level `sandbox` schema lists `enabled`, `failIfUnavailable`, `autoAllowBashIfSandboxed`, `filesystem.*`, `network.*`, `bwrapPath`, `socatPath` and **whether `sandbox.seccomp.*` appears anywhere** (legacy compat, current schema, or deprecated).

**Step 2: Query the live CLI for its current expected schema**

Run: `claude --print-settings-schema 2>/dev/null | jq '.properties.sandbox' 2>/dev/null`
Expected: JSON schema for the `sandbox` key. If the command does not exist, try: `claude config get sandbox` or check `claude --help | grep -i sandbox`.

**Step 3: Verify the seccomp filter is actually active at runtime**

Run inside a sandboxed Claude session:
```bash
# this Bash call goes through the sandbox; if seccomp is active, AF_UNIX socket creation should fail
python3 -c "import socket; s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); print('socket created — seccomp NOT active')" 2>&1 | head -3
```
Expected (if seccomp active): the Python call should fail with `PermissionError`. If it prints "socket created", the seccomp filter is being ignored.

**Step 4: Record finding**

Create `docs/plans/2026-05-18-sandbox-schema-finding.md` with:
- Current schema (from Step 1+2)
- Whether `sandbox.seccomp.*` is recognized (yes / no / legacy)
- Runtime verification result (active / inactive)
- Recommended action: keep / migrate / hybrid

**Step 5: Commit the finding doc**

```bash
git add docs/plans/2026-05-18-sandbox-schema-finding.md
git commit -m "$(cat <<'EOF'
docs(plans): sandbox settings schema investigation finding

Resolves P0-2 investigation prerequisite from the 2026-05-18 audit.
Records current sandbox schema, whether sandbox.seccomp.* is recognized,
and runtime verification of seccomp BPF active state.
EOF
)"
```

---

## Task 4: Migrate sandbox config (P0-2b, conditional)

**Trigger:** Only execute if Task 3 found `sandbox.seccomp.*` is silently ignored or deprecated.

**Why:** Invariant #4 (sandbox isolation) requires the seccomp filter to actually run; if the legacy schema is ignored, security control is silently disabled.

**Files:**
- Modify: `modules/home-manager/claude-code/default.nix:51-54`
- Optionally modify: `pkgs/claude-seccomp.nix` (if BPF wiring path changed)

**Step 1: Write a verification test**

Create `tests/bash/sandbox/test-seccomp-active.bats`:
```bash
#!/usr/bin/env bats

@test "AF_UNIX socket creation blocked in sandboxed shell" {
  # When claude is invoked with seccomp active, AF_UNIX should fail
  run claude -p --bare 'python3 -c "import socket; socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)"' 2>&1
  # Expected: non-zero exit OR PermissionError in stderr
  [[ "$status" -ne 0 || "$output" =~ "PermissionError" ]]
}
```

Run: `bats tests/bash/sandbox/test-seccomp-active.bats`
Expected: **FAIL** currently (proves the test catches the broken state).

**Step 2: Modify the settings merge**

In `modules/home-manager/claude-code/default.nix`, replace lines 51-54:
```nix
"sandbox": {"seccomp": {
  "bpfPath": ($home + "/.claude/seccomp/unix-block.bpf"),
  "applyPath": ($home + "/.claude/seccomp/apply-seccomp")
}},
```

with the migrated schema (final form depends on Task 3 finding — pick ONE):

**Option A (if `bwrapPath`/`socatPath` is the new wiring):**
```nix
"sandbox": {
  "enabled": true,
  "failIfUnavailable": true,
  "bwrapPath": ($home + "/.claude/seccomp/apply-seccomp"),
  "network": {"allowAllUnixSockets": false}
},
```

**Option B (if `sandbox.seccomp.*` is documented as legacy-compat):**
Leave as-is but add `"_comment": "Legacy schema; CC v2.1.x docs confirm honored alongside top-level sandbox.*"` for future reviewers.

**Option C (if a completely different wiring path):**
Implement per Task 3 finding.

**Step 3: Rebuild + retest**

Tell user: run `./rebuild-nixos --quick`. After completion:

Run: `bats tests/bash/sandbox/test-seccomp-active.bats`
Expected: **PASS**.

**Step 4: Commit**

```bash
git add modules/home-manager/claude-code/default.nix tests/bash/sandbox/test-seccomp-active.bats
# also pkgs/claude-seccomp.nix if modified
git commit -m "$(cat <<'EOF'
fix(claude-sandbox): migrate seccomp wiring to current settings schema

The sandbox.seccomp.{bpfPath,applyPath} keys predate the 2026 top-level
sandbox schema. Migrates to <chosen schema> so Invariant #4 (sandbox
isolation) remains enforced. Adds BATS test that AF_UNIX socket creation
is blocked inside a sandboxed Claude session.
EOF
)"
```

---

## Phase 1 E2E verification

**Step 1: Confirm flake input removal didn't break anything**

Run: `nix flake check`
Expected: passes.

**Step 2: Confirm seccomp is actually active**

Run: `bats tests/bash/sandbox/test-seccomp-active.bats` (if Task 4 was executed)
Expected: PASS.

**Step 3: Confirm `.claude/` is cleaner**

Run: `ls -la .claude/ | wc -l`
Expected: 8-10 lines (down from 16). Stale files gone, live files intact.

**Step 4: User rebuild + verify**

User runs: `./rebuild-nixos`
Expected: build succeeds, sandbox active, no regressions in CC behavior.

---

# PHASE 2 — Settings architecture

## Task 5: Wire MCP-NixOS minimum (P0-5)

**Why:** `.mcp.json` is empty despite the `nixos.md` skill and CLAUDE.md root claiming MCP-NixOS is configured. See audit §G3.

**Files:**
- Modify: `.mcp.json` (currently `{"mcpServers": {}}`)

**Step 1: Write a verification test**

Run: `claude mcp list 2>&1 | head -5` (or equivalent — check `claude mcp --help`)
Expected currently: empty list.

**Step 2: Wire MCP-NixOS**

Replace contents of `.mcp.json` with:
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

**Step 3: Test MCP-NixOS responds**

In a new Claude session from this repo:
- Verify `mcp-nixos` appears in available MCP servers
- Try invoking one of its tools (e.g., search for `ripgrep` package)

Expected: returns valid NixOS package info.

**Step 4: Update the `nixos.md` skill text if needed**

Read `modules/home-manager/claude-code/commands/nixos.md:18`. Verify the claim "MCP-NixOS server (configured in `.mcp.json`)" is now accurate.

**Step 5: Commit**

```bash
git add .mcp.json
git commit -m "$(cat <<'EOF'
feat(mcp): wire MCP-NixOS at project root

.mcp.json was empty despite skill and CLAUDE.md claiming MCP-NixOS is
configured. Wires the documented `uvx mcp-nixos@latest` entry so the
22K+ NixOS options and 130K+ packages are queryable in-session.
EOF
)"
```

---

## Task 6: Add managed-settings.json NixOS module (P0-3a)

**Why:** `claudeMd` injected via `/etc/claude-code/managed-settings.json` cannot be excluded by users, unlike the current `~/.claude/CLAUDE.md` symlink. True org-wide enforcement of company policies. See audit §G15.

**Files:**
- Create: `modules/common/claude-code-managed.nix`
- Modify: `hosts/common/base.nix` or appropriate import point to include the new module

**Step 1: Verify the right import point**

Run: `rg "import.*modules/common" hosts/ -t nix`
Expected: identifies where `modules/common/*.nix` files get imported (likely `hosts/common/base.nix` or `hosts/common/default.nix`).

**Step 2: Write a verification test**

Create `tests/bash/managed-settings/test-managed-settings.bats`:
```bash
#!/usr/bin/env bats

@test "managed settings file exists" {
  [ -f /etc/claude-code/managed-settings.json ]
}

@test "managed settings is valid JSON" {
  jq empty /etc/claude-code/managed-settings.json
}

@test "managed settings includes claudeMd content" {
  result=$(jq -r '.claudeMd' /etc/claude-code/managed-settings.json)
  [[ -n "$result" && "$result" != "null" ]]
}

@test "managed settings claudeMd matches company-policies.md source" {
  managed=$(jq -r '.claudeMd' /etc/claude-code/managed-settings.json)
  source_md=$(cat /home/YOUR_USERNAME/nixos-config/modules/home-manager/claude-code/company-policies.md)
  [ "$managed" = "$source_md" ]
}
```

Run: `bats tests/bash/managed-settings/test-managed-settings.bats`
Expected: **FAIL** all (file doesn't exist yet).

**Step 3: Create the NixOS module**

Create `modules/common/claude-code-managed.nix`:
```nix
# Managed Claude Code settings — org-wide policies injected at root level.
# These cannot be excluded by users (unlike ~/.claude/CLAUDE.md symlinks).
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G15
{ pkgs, ... }:

let
  companyPolicies = builtins.readFile ../home-manager/claude-code/company-policies.md;
  managedSettings = {
    claudeMd = companyPolicies;
    strictKnownMarketplaces = true;
    blockedMarketplaces = [];
  };
in
{
  environment.etc."claude-code/managed-settings.json".source =
    pkgs.writeText "claude-code-managed-settings.json"
      (builtins.toJSON managedSettings);
}
```

**Step 4: Import the module**

In the appropriate import point (per Step 1), add:
```nix
imports = [
  # ... existing imports ...
  ../../modules/common/claude-code-managed.nix
];
```

**Step 5: Validate**

Run: `nix flake check`
Expected: passes.

**Step 6: Tell user to rebuild and test**

User runs: `./rebuild-nixos --quick`
After completion:
Run: `bats tests/bash/managed-settings/test-managed-settings.bats`
Expected: **PASS** all 4 tests.

**Step 7: Commit**

```bash
git add modules/common/claude-code-managed.nix hosts/common/base.nix tests/bash/managed-settings/
git commit -m "$(cat <<'EOF'
feat(claude-code): inject company policies via claudeMd managed setting

Adds /etc/claude-code/managed-settings.json deployed by a new
modules/common/claude-code-managed.nix module. Injects company-policies.md
content via the 2026 claudeMd key, which (unlike the home-manager symlink
at ~/.claude/CLAUDE.md) cannot be excluded by users. Also locks
strictKnownMarketplaces=true and blockedMarketplaces=[] org-wide.

Required for Invariant #1 (true declarativity) and #7 (tech↔business
separation) — business users now cannot bypass company-wide rules.
EOF
)"
```

---

## Task 7: Migrate CLAUDE.md to claudeMd (P0-3b)

**Why:** Now that managed-settings.json carries the authoritative policies, the `home.file ~/.claude/CLAUDE.md` symlink becomes redundant (and confusing — two sources of truth). Convert it to a thin personal-additions layer.

**Files:**
- Modify: `modules/home-manager/claude-code/default.nix:12`
- Optionally: rename `company-policies.md` to clarify it's the managed source

**Step 1: Verify managed-settings carries the policies**

Run: `jq -r '.claudeMd' /etc/claude-code/managed-settings.json | head -5`
Expected: shows the start of `company-policies.md`.

**Step 2: Write a verification test**

Create `tests/bash/managed-settings/test-policy-source-of-truth.bats`:
```bash
#!/usr/bin/env bats

@test "company-policies.md is single source of truth" {
  # Verify ~/.claude/CLAUDE.md (if present) is NOT a duplicate of managed claudeMd
  if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    home_md=$(cat "$HOME/.claude/CLAUDE.md")
    managed=$(jq -r '.claudeMd' /etc/claude-code/managed-settings.json)
    [ "$home_md" != "$managed" ] || {
      echo "FAIL: $HOME/.claude/CLAUDE.md duplicates the managed claudeMd content"
      return 1
    }
  fi
}
```

Run: `bats tests/bash/managed-settings/test-policy-source-of-truth.bats`
Expected: currently **FAIL** because both files have the same content.

**Step 3: Remove the home.file CLAUDE.md symlink**

In `modules/home-manager/claude-code/default.nix:12`, delete:
```nix
home.file.".claude/CLAUDE.md".source = ./company-policies.md;
```

**Step 4: Validate**

Run: `nix flake check`
Expected: passes.

**Step 5: Tell user to rebuild**

User runs: `./rebuild-nixos --quick`

After completion:
- Verify `ls -l ~/.claude/CLAUDE.md` — should NOT exist (or be a stale orphan; if so, `rm ~/.claude/CLAUDE.md`).
- Run: `bats tests/bash/managed-settings/test-policy-source-of-truth.bats`
- Expected: **PASS** (no duplicate).

**Step 6: Verify Claude Code still loads the policies**

Start a new Claude Code session from `~/nixos-config`. Ask: "What is Invariant #7?"
Expected: Claude responds with "Tech↔business separation" — confirming `claudeMd` from managed-settings is being loaded.

**Step 7: Commit**

```bash
git add modules/home-manager/claude-code/default.nix
git commit -m "$(cat <<'EOF'
refactor(claude-code): single source of truth for company policies

Removes the home.file ~/.claude/CLAUDE.md symlink. Policies now live in
/etc/claude-code/managed-settings.json (root-owned, user-deletion-proof)
via the claudeMd managed setting added in the previous commit.
modules/home-manager/claude-code/company-policies.md remains the editable
source; the managed-settings module reads it at evaluation time.

Closes loop on G15 from the 2026-05-18 audit.
EOF
)"
```

---

## Task 8: Phase 2 E2E verification

**Step 1: MCP-NixOS works**

In a Claude session: invoke MCP-NixOS to look up `package:ripgrep`. Expected: returns version + description.

**Step 2: Managed settings active**

Run: `cat /etc/claude-code/managed-settings.json | jq .claudeMd | head -3`
Expected: shows ClaudeOS policies from `company-policies.md`.

**Step 3: No duplicate source-of-truth**

Run: `ls -la ~/.claude/CLAUDE.md 2>&1`
Expected: "No such file or directory" (the symlink is gone).

**Step 4: Policies actually loaded in Claude**

Start a new session from `~/nixos-config`. Run `/memory show` or ask Claude to recite Invariant #4. Expected: it knows "Sandbox isolation — autonomous work runs via scripts/claude-autonomous.sh ..."

---

# PHASE 3 — Declarative primitives

## Task 9: Create `flake-debugger` subagent (P0-6 part 1)

**Why:** Audit §G1. Subagent for parsing `nix flake check` failures and proposing fixes. Currently zero custom subagents.

**Files:**
- Create: `modules/home-manager/claude-code/agents/flake-debugger.md`

**Step 1: Write the agent definition**

Create `modules/home-manager/claude-code/agents/flake-debugger.md`:
```markdown
---
name: flake-debugger
description: Use proactively when `nix flake check` fails, when a flake input update causes evaluation errors, or when investigating "no such attribute" / "infinite recursion" / "missing input" errors in a Nix flake. Reads the failing output, identifies root cause, and proposes a specific fix anchored to a file:line in flake.nix or modules/.
tools: Read, Glob, Grep, Bash
isolation: worktree
preload_skills:
  - nixos
mcpServers:
  - mcp-nixos
---

You are a Nix flake debugging specialist for the ClaudeOS NixOS fleet.

## Your job

When called with the output of a failing `nix flake check` (or equivalent), you:

1. **Parse the error** — identify whether it is: (a) evaluation error (attribute missing, recursion, type), (b) input resolution failure (network, mismatched fingerprint), (c) module composition error (option already defined, mkForce conflict), or (d) build failure (derivation fails to compile).
2. **Locate the source** — find the exact file:line that triggers the error. Always cite a path.
3. **Explain the root cause** in 1-2 sentences. Anchor to either: which invariant is at risk (CLAUDE.md:30-49), or which Nix concept is being mis-applied.
4. **Propose a specific fix** — concrete code change with file:line. Do NOT just say "fix the import" — show the diff.
5. **Predict the next failure** — if there's likely a downstream error after this fix, mention it so the user isn't surprised.

## Constraints

- You are read-only by default. Do not edit files. Propose; the maintainer edits.
- Always invoke `nix flake check` (NOT `nixos-rebuild` — that requires sudo, per CLAUDE.md:145).
- If MCP-NixOS is configured, prefer it for option/package lookups over `nix-locate`.
- Cite file:line for every claim about repo state.

## Output format

```
## Error category
[evaluation / input resolution / module composition / build]

## Root cause
[1-2 sentences with file:line]

## Proposed fix
[exact diff with file:line]

## Next likely issue
[one sentence, or "none expected"]
```
```

**Step 2: Write a frontmatter parse test**

Create `tests/bash/subagents/test-frontmatter-valid.bats`:
```bash
#!/usr/bin/env bats

@test "flake-debugger frontmatter is valid YAML" {
  # Extract frontmatter block (between first two ---)
  awk '/^---$/{c++; next} c==1' \
    /home/YOUR_USERNAME/nixos-config/modules/home-manager/claude-code/agents/flake-debugger.md \
    | yq eval . > /dev/null
}

@test "flake-debugger has required fields" {
  fm=$(awk '/^---$/{c++; next} c==1' \
    /home/YOUR_USERNAME/nixos-config/modules/home-manager/claude-code/agents/flake-debugger.md)
  echo "$fm" | yq eval '.name' - | grep -q flake-debugger
  echo "$fm" | yq eval '.description' - | grep -qi "flake"
  echo "$fm" | yq eval '.tools' - | grep -q Read
}
```

Run: `bats tests/bash/subagents/test-frontmatter-valid.bats`
Expected: **PASS** (frontmatter is well-formed).

**Step 3: Commit (defer wiring to Task 13)**

```bash
git add modules/home-manager/claude-code/agents/flake-debugger.md tests/bash/subagents/
git commit -m "$(cat <<'EOF'
feat(claude-code): add flake-debugger subagent

First of four declarative subagents from the 2026-05-18 audit §G1.
Parses `nix flake check` failures, identifies root cause, proposes specific
fixes with file:line citations. isolation: worktree so debugging runs in a
fresh tree; preloads the nixos skill; uses mcp-nixos when available.

Wired into Home Manager in a later task.
EOF
)"
```

---

## Task 10: Create `package-finder` subagent (P0-6 part 2)

**Files:**
- Create: `modules/home-manager/claude-code/agents/package-finder.md`

**Step 1: Write the agent definition**

Create `modules/home-manager/claude-code/agents/package-finder.md`:
```markdown
---
name: package-finder
description: Use when the user asks for a NixOS package or program ("add X", "install Y", "what's the package name for Z"), or when proposing to add a tool to any modules/*/packages.nix file. Returns the canonical `pkgs.<attr>` path AND which module file it should live in per the ClaudeOS layout.
tools: Read, Grep
preload_skills:
  - nixos
mcpServers:
  - mcp-nixos
---

You are the package-search specialist for the ClaudeOS NixOS fleet.

## Your job

Given a tool / program / library name, return:

1. **The exact `pkgs.<attr>` path** — query MCP-NixOS, not your training data.
2. **Where it lives in this repo** — apply the table from CLAUDE.md:103-114:

| Change | File |
|--------|------|
| New system tool for tech hosts | `modules/core/packages.nix` |
| New tool for ALL hosts | `modules/common/packages.nix` |
| New tool for business hosts only | `modules/business/packages.nix` |
| User-level program / dotfile | `modules/home-manager/<category>/` |
| Pinned NPM tool | `modules/core/npm-versions.nix` |
| Per-vendor hardware quirk | `modules/hardware/<vendor>.nix` |

3. **Whether the package already exists in the repo** — grep modules/ first; do not double-add.
4. **A one-line description** from MCP-NixOS metadata, so the user knows what they're adding.
5. **The exact edit** — show the diff to make.

## Decision rules

- "Probably for tech hosts only" (CLI dev tools, niche utilities) → `modules/core/packages.nix`
- "Useful for everyone" (browsers, basic tools) → `modules/common/packages.nix`
- "Business user-facing" (office tools, GUI apps for non-devs) → `modules/business/packages.nix`
- "User-level config" (editor settings, shell aliases) → `modules/home-manager/<category>/`

## Output format

```
## Package
`pkgs.<attr>` — <one-line description from MCP-NixOS>

## Already in repo?
[yes (path:line) / no]

## Recommended location
`<file>` because [rule from CLAUDE.md table]

## Exact edit
[diff]
```
```

**Step 2: Frontmatter test (extend the existing bats file)**

Add to `tests/bash/subagents/test-frontmatter-valid.bats`:
```bash
@test "package-finder frontmatter is valid YAML" {
  awk '/^---$/{c++; next} c==1' \
    /home/YOUR_USERNAME/nixos-config/modules/home-manager/claude-code/agents/package-finder.md \
    | yq eval . > /dev/null
}
```

Run: PASS expected.

**Step 3: Commit**

```bash
git add modules/home-manager/claude-code/agents/package-finder.md tests/bash/subagents/test-frontmatter-valid.bats
git commit -m "$(cat <<'EOF'
feat(claude-code): add package-finder subagent

Second of four from 2026-05-18 audit §G1. Fronts MCP-NixOS, returns
`pkgs.<attr>` path + correct modules/*/packages.nix location per the
CLAUDE.md:103-114 table, checks for duplicates, and produces an exact diff.
Enforces Invariant #7 by routing tech vs business package additions.
EOF
)"
```

---

## Task 11: Create `generation-differ` subagent (P0-6 part 3)

**Files:**
- Create: `modules/home-manager/claude-code/agents/generation-differ.md`

**Step 1: Write the agent definition**

```markdown
---
name: generation-differ
description: Use when comparing two NixOS generations (e.g., rollback investigation, "what changed in last rebuild", post-rebuild summary), or when the user asks about closure changes. Runs `nvd diff` and produces a categorized summary by area (kernel/security/AI tools/business/etc).
tools: Bash, Read
isolation: worktree
preload_skills:
  - nixos
---

You are the generation-diff specialist for the ClaudeOS NixOS fleet.

## Your job

Given two generation numbers (or symbolic names like `current`, `previous`, or `rollback`):

1. **Run nvd diff** between the two generations: `nvd diff /nix/var/nix/profiles/system-N-link /nix/var/nix/profiles/system-M-link`
2. **Parse the output** into categories:
   - **Kernel & firmware** (linux*, firmware-*)
   - **Security** (openssl, glibc, sudo, polkit, etc.)
   - **AI toolchain** (claude-code-nix, code-cursor-nix, antigravity-nix, mcp-*)
   - **Business profile** (rclone, gemini-cli, libreoffice, etc.)
   - **Hardware-specific** (mesa, amdgpu, nvidia, broadcom)
   - **Other** (everything else)
3. **Flag drift surprises** — additions or removals that don't match any commit in the range. Cross-reference `git log` between the two generation dates.
4. **Estimate user-visible impact** — "kernel bump may require reboot," "openssl bump affects 47 dependents," etc.

## Constraints

- Read-only: you do not switch generations. You only report.
- If `nvd` is not in PATH, fail with a clear message — don't try `nix-diff` as a fallback (the output format is different and downstream parsing breaks).
- Respect ClaudeOS Invariant #3 (atomic rollback) — never suggest deleting generations; that's `rebuild-nixos` Phase 10's job.

## Output format

```
## Diff: generation $OLD → $NEW

### Kernel & firmware
[changes]

### Security
[changes]

### AI toolchain
[changes]

### Business profile
[changes]

### Hardware-specific
[changes]

### Other
[N changes — `nvd diff` for full list]

## Drift surprises
[flagged items, or "none"]

## User-visible impact
[one paragraph]
```
```

**Step 2: Frontmatter test extension**

Add to bats file: identical pattern as Task 10 Step 2.

**Step 3: Commit**

```bash
git add modules/home-manager/claude-code/agents/generation-differ.md tests/bash/subagents/test-frontmatter-valid.bats
git commit -m "$(cat <<'EOF'
feat(claude-code): add generation-differ subagent

Third of four from 2026-05-18 audit §G1. Runs nvd diff between two
generations, parses into 6 categories (kernel/security/AI/business/hardware/
other), cross-references git log for drift surprises, estimates user-visible
impact. Useful for post-rebuild summaries and rollback investigations.
EOF
)"
```

---

## Task 12: Create `supply-chain-auditor` subagent (P0-6 part 4)

**Files:**
- Create: `modules/home-manager/claude-code/agents/supply-chain-auditor.md`

**Step 1: Write the agent definition**

```markdown
---
name: supply-chain-auditor
description: Use after `./rebuild-nixos --audit` runs, or when investigating supply-chain anomalies (unexpected FOD, new flake input, vulnerability advisory matching a closure dependency). Diffs the exported `--audit` manifest against the prior one, flags unexpected additions, and anchors to Invariant #5.
tools: Bash, Read, Grep
isolation: worktree
---

You are the supply-chain audit specialist for the ClaudeOS NixOS fleet.
Anchored to Invariant #5 (supply-chain auditability) — every significant
input change deserves scrutiny.

## Your job

Given a current `--audit` manifest path (typically under `~/.local/state/rebuild-nixos/audit/` or wherever rebuild-nixos Phase 2.7 writes it):

1. **Locate the prior manifest** — look for the next-oldest file in the same directory.
2. **Diff manifests** — three categories:
   - **Added FODs** (new fixed-output derivations) — highest scrutiny
   - **Added flake inputs** (compare against `flake.nix` MAINTAINER comments)
   - **Bumped pins** (npm-versions.nix, claude-code-nix, etc.)
3. **For each added FOD**: name the upstream URL it pulls from. If the URL is on a new domain not seen in the prior manifest, FLAG it.
4. **For each added input**: check `flake.nix` for the `MAINTAINER:` comment. If missing, FLAG (Invariant #5 violation).
5. **Cross-reference NVD / CVE feeds** for any package in the diff with a recent advisory. Use `nix-locate` to find the affected closure paths.

## Output format

```
## Supply chain audit: $CURRENT vs $PRIOR

### Summary
[N FODs added, M inputs added, K pins bumped]

### Added FODs
[list with upstream URLs, flag new domains]

### Added inputs
[list with MAINTAINER status]

### Bumped pins
[list]

### Vulnerabilities (advisories matching closure)
[list with severity, affected paths]

### Recommended actions
[ordered list]
```

## Constraints

- Read-only. You never modify flake.nix or npm-versions.nix; you propose.
- Always run `./rebuild-nixos --audit` against the user, NEVER directly (sudo required).
- If no prior manifest exists (first audit run), report that and skip the diff section.
```

**Step 2: Frontmatter test extension**

Same pattern.

**Step 3: Commit**

```bash
git add modules/home-manager/claude-code/agents/supply-chain-auditor.md tests/bash/subagents/test-frontmatter-valid.bats
git commit -m "$(cat <<'EOF'
feat(claude-code): add supply-chain-auditor subagent

Fourth of four from 2026-05-18 audit §G1. Diffs --audit manifests across
runs, flags new FOD upstream URLs, validates MAINTAINER comments on added
inputs, cross-references closure paths against advisories. Anchored to
Invariant #5 (supply-chain auditability).
EOF
)"
```

---

## Task 13: Wire 4 subagents in Home Manager (P0-6 part 5)

**Why:** Subagent files exist but aren't deployed to `~/.claude/agents/`. Home Manager needs to symlink them.

**Files:**
- Modify: `modules/home-manager/claude-code/default.nix`

**Step 1: Write the wiring**

In `modules/home-manager/claude-code/default.nix`, after line 15 (`home.file.".claude/commands/nixos.md".source = ...`), add:

```nix
  # Custom subagents — symlinked to ~/.claude/agents/ from the Nix store
  home.file.".claude/agents/flake-debugger.md".source = ./agents/flake-debugger.md;
  home.file.".claude/agents/package-finder.md".source = ./agents/package-finder.md;
  home.file.".claude/agents/generation-differ.md".source = ./agents/generation-differ.md;
  home.file.".claude/agents/supply-chain-auditor.md".source = ./agents/supply-chain-auditor.md;
```

**Step 2: Validate**

Run: `nix flake check`
Expected: passes.

**Step 3: Tell user to rebuild**

User runs: `./rebuild-nixos --quick`

After completion:
Run: `ls -la ~/.claude/agents/`
Expected: 4 symlinks to `/nix/store/*` — flake-debugger.md, package-finder.md, generation-differ.md, supply-chain-auditor.md.

**Step 4: Write an integration test**

Create `tests/bash/subagents/test-agents-deployed.bats`:
```bash
#!/usr/bin/env bats

@test "all 4 custom subagents deployed" {
  for agent in flake-debugger package-finder generation-differ supply-chain-auditor; do
    [ -L "$HOME/.claude/agents/${agent}.md" ] || {
      echo "FAIL: ~/.claude/agents/${agent}.md missing or not a symlink"
      return 1
    }
  done
}

@test "deployed subagents point to nix store" {
  for agent in flake-debugger package-finder generation-differ supply-chain-auditor; do
    target=$(readlink "$HOME/.claude/agents/${agent}.md")
    [[ "$target" =~ ^/nix/store/ ]] || {
      echo "FAIL: ${agent}.md not pointing to nix store: $target"
      return 1
    }
  done
}
```

Run: `bats tests/bash/subagents/test-agents-deployed.bats`
Expected: **PASS** both.

**Step 5: Verify Claude can dispatch them**

In a fresh Claude session: ask "What subagents are available?" and confirm `flake-debugger`, `package-finder`, `generation-differ`, `supply-chain-auditor` appear in the list.

Then test one: "Use flake-debugger to investigate this output: [paste a real `nix flake check` error]". Expected: the agent loads with the correct frontmatter and produces output in the documented format.

**Step 6: Commit**

```bash
git add modules/home-manager/claude-code/default.nix tests/bash/subagents/test-agents-deployed.bats
git commit -m "$(cat <<'EOF'
feat(claude-code): deploy 4 custom subagents via home-manager

Wires flake-debugger, package-finder, generation-differ, supply-chain-auditor
into ~/.claude/agents/ as nix store symlinks. Adds BATS integration test
verifying symlinks land and point to /nix/store/.

Closes G1 from the 2026-05-18 audit. With CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
already set, these can also be composed into named teams in P2.
EOF
)"
```

---

## Task 14: Statusline shell script (P0-7a)

**Files:**
- Create: `modules/home-manager/claude-code/statusline.sh`
- Optionally: create `/etc/claudeos/host-class` file populated by NixOS

**Step 1: Write the statusline script**

Create `modules/home-manager/claude-code/statusline.sh`:
```bash
#!/usr/bin/env bash
# Claude Code statusline for ClaudeOS — surfaces host class, generation,
# branch, last-build status. Receives session JSON on stdin (unused for now;
# kept for future per-session context).
#
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G4
set -uo pipefail

# Drain stdin (session JSON) — currently unused but reserved
cat > /dev/null || true

host=$(hostname -s 2>/dev/null || echo "?")
host_class="?"
if [ -f /etc/claudeos/host-class ]; then
  host_class=$(cat /etc/claudeos/host-class)
fi

gen="?"
if [ -L /run/current-system ]; then
  gen_link=$(readlink /run/current-system)
  gen=$(echo "$gen_link" | grep -oE 'system-[0-9]+' | cut -d- -f2)
fi

branch="?"
if [ -d "$HOME/nixos-config/.git" ]; then
  branch=$(git -C "$HOME/nixos-config" branch --show-current 2>/dev/null || echo "?")
fi

last="?"
if [ -f "$HOME/.local/state/rebuild-nixos/last-status" ]; then
  last=$(cat "$HOME/.local/state/rebuild-nixos/last-status")
fi

echo "[${host} ${host_class} | gen ${gen} | ${branch} | last:${last}]"
```

Make it executable: `chmod +x modules/home-manager/claude-code/statusline.sh`

**Step 2: Write the host-class NixOS module (optional)**

Create `modules/common/host-class.nix`:
```nix
# Writes /etc/claudeos/host-class so the statusline knows whether this host
# is "tech" or "biz" without needing to parse the hostname.
{ config, lib, ... }:

let
  hostname = config.networking.hostName;
  isBusinessHost = lib.hasInfix "-biz-" hostname;
  hostClass = if isBusinessHost then "biz" else "tech";
in
{
  environment.etc."claudeos/host-class".text = hostClass;
}
```

Import in `hosts/common/base.nix` (same place as the managed-settings module from Task 6).

**Step 3: Write a test**

Create `tests/bash/statusline/test-statusline-format.bats`:
```bash
#!/usr/bin/env bats

setup() {
  STATUSLINE="/home/YOUR_USERNAME/nixos-config/modules/home-manager/claude-code/statusline.sh"
}

@test "statusline produces output" {
  out=$(echo '{}' | bash "$STATUSLINE")
  [ -n "$out" ]
}

@test "statusline format matches expected pattern" {
  out=$(echo '{}' | bash "$STATUSLINE")
  # Expect: [hostname class | gen N | branch | last:?]
  [[ "$out" =~ ^\[.+\ .+\ \|\ gen\ .+\ \|\ .+\ \|\ last:.+\]$ ]] || {
    echo "Unexpected format: $out"
    return 1
  }
}

@test "statusline reads host-class from /etc/claudeos/host-class" {
  if [ -f /etc/claudeos/host-class ]; then
    expected=$(cat /etc/claudeos/host-class)
    out=$(echo '{}' | bash "$STATUSLINE")
    [[ "$out" == *" $expected "* ]] || {
      echo "Expected '$expected' in output: $out"
      return 1
    }
  fi
}
```

Run: `bats tests/bash/statusline/test-statusline-format.bats`
Expected: tests 1 and 2 PASS; test 3 PASS only after `host-class.nix` is rebuilt-in (Task 14b after rebuild).

**Step 4: Commit (defer wiring into settings.json to Task 15)**

```bash
git add modules/home-manager/claude-code/statusline.sh modules/common/host-class.nix hosts/common/base.nix tests/bash/statusline/
git commit -m "$(cat <<'EOF'
feat(claude-code): statusline script + host-class environment file

Adds modules/home-manager/claude-code/statusline.sh that surfaces hostname,
host class (tech/biz), current generation, git branch, and last-build status
in the Claude Code prompt. Also adds modules/common/host-class.nix which
writes /etc/claudeos/host-class so the statusline doesn't have to parse
hostnames at runtime.

The statusline reads ~/.local/state/rebuild-nixos/last-status, which will
be populated by P1-1 (rebuild-nixos log_event). Until then, displays "?".
Wired into settings.json in the next commit.
EOF
)"
```

---

## Task 15: Wire statusline in settings.json merger (P0-7b)

**Files:**
- Modify: `modules/home-manager/claude-code/default.nix` (the jq merger at `:35-69`)
- Modify: `pkgs/claude-seccomp.nix` may need to expose statusline path? (No — separate concern.)

**Step 1: Extend the settings.json activation to include statusLine**

In `modules/home-manager/claude-code/default.nix`, in the `claude-settings-merge` activation, both branches of the if/else need a `statusLine` key.

**First-setup branch (line 47-57)**, add to the jq object:
```nix
'. + {
  "permissions": {"allow": .permissions.allow, "deny": []},
  "sandbox": <... existing ...>,
  "alwaysThinkingEnabled": true,
  "env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"},
  "statusLine": {
    "type": "command",
    "command": ($home + "/.config/claude-code/statusline.sh"),
    "padding": 0
  }
}'
```

Plus add a new `home.file` line earlier:
```nix
home.file.".config/claude-code/statusline.sh" = {
  source = ./statusline.sh;
  executable = true;
};
```

**Merge branch (line 60-67)**, add the statusLine to the jq pipeline:
```nix
'
.permissions.allow = ((.permissions.allow // []) + $company[0].permissions.allow | unique) |
.enabledPlugins = ($company[0].enabledPlugins * (.enabledPlugins // {})) |
.statusLine = {
  "type": "command",
  "command": ($home + "/.config/claude-code/statusline.sh"),
  "padding": 0
}
'
```

**Step 2: Validate**

Run: `nix flake check`
Expected: passes.

**Step 3: Tell user to rebuild**

User runs: `./rebuild-nixos --quick`

After completion:
- Verify `ls -l ~/.config/claude-code/statusline.sh` exists and is executable.
- Verify `jq .statusLine ~/.claude/settings.json` shows the command path.

**Step 4: Verify in a Claude Code session**

Start `claude` in `~/nixos-config`. The statusline should appear in the prompt: `[framework-16 tech | gen 247 | personal | last:?]`.

If it doesn't appear:
- Check `jq .statusLine ~/.claude/settings.json` — value must include `type: command, command: <path>`
- Check the path is executable
- Run the path manually with stdin: `echo '{}' | ~/.config/claude-code/statusline.sh`

**Step 5: Commit**

```bash
git add modules/home-manager/claude-code/default.nix
git commit -m "$(cat <<'EOF'
feat(claude-code): wire statusline in settings.json merger

Both the first-setup and merge branches of the jq merger now inject a
statusLine entry pointing to ~/.config/claude-code/statusline.sh. The
script (deployed by home.file) prints host, class, generation, branch,
last-build to the Claude Code prompt for glanceable fleet context.

Closes P0-7 / §G4 from 2026-05-18 audit. Once P1-1 (rebuild-nixos log_event)
lands, the "last:?" placeholder fills with success/failure indicators.
EOF
)"
```

---

## Phase 3 E2E verification

**Step 1: All 4 subagents present**

Run: `bats tests/bash/subagents/`
Expected: all pass.

**Step 2: Subagents are dispatchable**

In a Claude session: `Use package-finder to find the NixOS package for `ripgrep`.`
Expected: returns `pkgs.ripgrep`, recommends `modules/core/packages.nix` (or wherever it already lives), prints exact diff.

**Step 3: Statusline visible**

Start `claude` in `~/nixos-config`. The statusline appears at the bottom of the prompt.

**Step 4: Statusline updates on host change**

Verify host_class shows correct value (`tech` on framework-16, `biz` on tl-biz-001).

---

# PHASE 4 — rebuild-nixos Phase 4 validator

## Task 16: Extract `check-claude-config.sh` skeleton (P0-8a)

**Why:** `rebuild-nixos:919-935` is a 17-line stub. Extract the framework into a standalone script so it's testable and extensible.

**Files:**
- Create: `scripts/check-claude-config.sh`

**Step 1: Write the skeleton**

Create `scripts/check-claude-config.sh`:
```bash
#!/usr/bin/env bash
# Claude Code configuration validator.
# Replaces the stub at rebuild-nixos:919-935 with real checks that catch
# drift between declarative intent (NixOS / Home Manager) and the actual
# state of ~/.claude/.
#
# Exit code:
#   0 — all checks passed
#   1 — warnings (cosmetic, not blocking)
#   2 — errors (declarative drift, must investigate)
#
# Output: structured JSON (consumable by P1-2 telemetry MCP).
# Source: docs/plans/2026-05-18-claude-code-advancements-audit.md §G5
set -uo pipefail

CLAUDE_DIR="${HOME}/.claude"
NIXOS_CONFIG="${HOME}/nixos-config"
EXIT_CODE=0

# Collect events as JSON objects, print as a single array at end
declare -a EVENTS=()

emit() {
  local level="$1"  # info, warn, error
  local check="$2"
  local message="$3"
  EVENTS+=("$(jq -n --arg level "$level" --arg check "$check" --arg message "$message" \
    '{level: $level, check: $check, message: $message}')")
  case "$level" in
    error) EXIT_CODE=2 ;;
    warn) [ "$EXIT_CODE" -lt 1 ] && EXIT_CODE=1 ;;
  esac
}

# Checks go here in subsequent tasks
# check_plugin_versions
# check_symlinks_valid
# check_subagents_parseable
# check_sandbox_attestation
# check_stale_files

# Output JSON array
echo "${EVENTS[@]}" | jq -s .

exit "$EXIT_CODE"
```

Make executable: `chmod +x scripts/check-claude-config.sh`

**Step 2: Verify the skeleton runs**

Run: `./scripts/check-claude-config.sh`
Expected: prints `[]` (empty array, no checks yet), exit 0.

**Step 3: Write a test framework**

Create `tests/bash/check-claude-config/test-skeleton.bats`:
```bash
#!/usr/bin/env bats

@test "check-claude-config.sh runs successfully" {
  run "$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh"
  [ "$status" -eq 0 ]
}

@test "check-claude-config.sh outputs valid JSON" {
  run "$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh"
  echo "$output" | jq empty
}
```

Run: `bats tests/bash/check-claude-config/test-skeleton.bats`
Expected: PASS both.

**Step 4: Commit**

```bash
git add scripts/check-claude-config.sh tests/bash/check-claude-config/test-skeleton.bats
git commit -m "$(cat <<'EOF'
feat(check-claude-config): skeleton for Phase 4 validator

Replaces rebuild-nixos:919-935 stub in subsequent commits. Emits structured
JSON events with level (info/warn/error) for future consumption by the P1-2
telemetry MCP server. Exit codes: 0 clean, 1 warn, 2 error.
EOF
)"
```

---

## Task 17: Plugin version validity check (P0-8b)

**Files:**
- Modify: `scripts/check-claude-config.sh`

**Step 1: Write the failing test**

Add to `tests/bash/check-claude-config/test-skeleton.bats`:
```bash
@test "plugin-version check emits info per enabled plugin" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh")
  count=$(echo "$out" | jq '[.[] | select(.check == "plugin_version")] | length')
  [ "$count" -gt 0 ]
}
```

Run: FAIL expected.

**Step 2: Implement the check**

In `scripts/check-claude-config.sh`, before the `# Output JSON array` line, add:

```bash
check_plugin_versions() {
  local settings="${CLAUDE_DIR}/settings.json"
  [ ! -f "$settings" ] && { emit error plugin_version "settings.json missing"; return; }

  # Get enabled plugins from settings.json
  jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$settings" \
    | while IFS= read -r plugin_id; do
        # Extract marketplace and plugin name (format: name@marketplace)
        marketplace=$(echo "$plugin_id" | cut -d@ -f2)
        plugin_name=$(echo "$plugin_id" | cut -d@ -f1)
        cache_path="${CLAUDE_DIR}/plugins/cache/${marketplace}/${plugin_name}"

        if [ ! -d "$cache_path" ]; then
          emit warn plugin_version "plugin $plugin_id enabled but not in cache at $cache_path"
        else
          # Check version (if plugin.json present)
          version="?"
          [ -f "$cache_path/.claude-plugin/plugin.json" ] && \
            version=$(jq -r '.version // "?"' "$cache_path/.claude-plugin/plugin.json")
          emit info plugin_version "$plugin_id @ $version"
        fi
      done
}

check_plugin_versions
```

**Step 3: Run the test**

Run: `bats tests/bash/check-claude-config/test-skeleton.bats`
Expected: PASS (now emits at least one event per enabled plugin).

**Step 4: Manual verification**

Run: `./scripts/check-claude-config.sh | jq '.[] | select(.check == "plugin_version")'`
Expected: ~17 plugin entries with versions.

**Step 5: Commit**

```bash
git add scripts/check-claude-config.sh tests/bash/check-claude-config/test-skeleton.bats
git commit -m "$(cat <<'EOF'
feat(check-claude-config): plugin version validity check

Verifies every plugin enabled in settings.json is actually installed under
~/.claude/plugins/cache/, and reports its version from plugin.json. Warns
on enabled-but-missing (drift between settings.json claims and reality).
EOF
)"
```

---

## Task 18: Symlink validity check (P0-8c)

**Files:**
- Modify: `scripts/check-claude-config.sh`

**Step 1: Failing test**

Add to bats file:
```bash
@test "symlink check covers ~/.claude/agents/ and ~/.claude/commands/" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh")
  count=$(echo "$out" | jq '[.[] | select(.check == "symlink")] | length')
  [ "$count" -ge 1 ]  # At minimum the nixos.md command + 4 agents = 5
}
```

Run: FAIL expected.

**Step 2: Implement**

In `scripts/check-claude-config.sh`, add before output:
```bash
check_symlinks_valid() {
  for dir in agents commands hooks output-styles seccomp; do
    target="${CLAUDE_DIR}/${dir}"
    [ ! -d "$target" ] && continue

    find "$target" -maxdepth 1 -type l 2>/dev/null | while read -r link; do
      if [ ! -e "$link" ]; then
        emit error symlink "dangling symlink: $link"
      else
        store_target=$(readlink "$link")
        if [[ "$store_target" =~ ^/nix/store/ ]]; then
          emit info symlink "$(basename "$link") → nix store (OK)"
        else
          emit warn symlink "$(basename "$link") → $store_target (not nix store — drift?)"
        fi
      fi
    done
  done
}

check_symlinks_valid
```

**Step 3: Test**

Run: `bats tests/bash/check-claude-config/test-skeleton.bats`
Expected: PASS.

**Step 4: Manual verification**

Run: `./scripts/check-claude-config.sh | jq '.[] | select(.check == "symlink")'`
Expected: 5+ entries (nixos.md + 4 agents), all `→ nix store (OK)`.

**Step 5: Commit**

```bash
git commit -am "feat(check-claude-config): validate symlinks in ~/.claude/

Walks agents/, commands/, hooks/, output-styles/, seccomp/. Flags dangling
symlinks (error), and warns on links not pointing to /nix/store/ (drift)."
```

---

## Task 19: Subagent frontmatter parsing (P0-8d)

**Files:**
- Modify: `scripts/check-claude-config.sh`

**Step 1: Failing test**

```bash
@test "subagent check covers all .md files in ~/.claude/agents/" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh")
  count=$(echo "$out" | jq '[.[] | select(.check == "subagent_frontmatter")] | length')
  # At least 4 (the ones from Task 9-12)
  [ "$count" -ge 4 ]
}
```

Run: FAIL expected.

**Step 2: Implement**

In `scripts/check-claude-config.sh`:
```bash
check_subagents_parseable() {
  local agents_dir="${CLAUDE_DIR}/agents"
  [ ! -d "$agents_dir" ] && return

  for agent_file in "$agents_dir"/*.md; do
    [ -f "$agent_file" ] || continue
    name=$(basename "$agent_file" .md)

    # Extract frontmatter (lines between first two ---)
    frontmatter=$(awk '/^---$/{c++; next} c==1' "$agent_file")
    if [ -z "$frontmatter" ]; then
      emit error subagent_frontmatter "$name: missing frontmatter"
      continue
    fi

    # Validate required fields
    if ! echo "$frontmatter" | grep -q '^name:'; then
      emit error subagent_frontmatter "$name: missing 'name' field"
    elif ! echo "$frontmatter" | grep -q '^description:'; then
      emit error subagent_frontmatter "$name: missing 'description' field"
    else
      emit info subagent_frontmatter "$name: valid"
    fi
  done
}

check_subagents_parseable
```

**Step 3: Test**

PASS expected.

**Step 4: Commit**

```bash
git commit -am "feat(check-claude-config): parse and validate subagent frontmatter

Verifies every ~/.claude/agents/*.md has well-formed frontmatter with
required 'name' and 'description' fields. Catches subagents that won't
dispatch because their definition is malformed."
```

---

## Task 20: Sandbox attestation check (P0-8e)

**Files:**
- Modify: `scripts/check-claude-config.sh`

**Step 1: Failing test**

```bash
@test "sandbox attestation check runs" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh")
  count=$(echo "$out" | jq '[.[] | select(.check == "sandbox_attestation")] | length')
  [ "$count" -ge 1 ]
}
```

Run: FAIL expected.

**Step 2: Implement**

```bash
check_sandbox_attestation() {
  local seccomp_dir="${CLAUDE_DIR}/seccomp"

  if [ ! -d "$seccomp_dir" ]; then
    emit warn sandbox_attestation "no seccomp directory; sandbox may be disabled"
    return
  fi

  for required in apply-seccomp unix-block.bpf; do
    if [ ! -e "$seccomp_dir/$required" ]; then
      emit error sandbox_attestation "missing $required (Invariant #4 at risk)"
    fi
  done

  # Check apply-seccomp is executable
  if [ -e "$seccomp_dir/apply-seccomp" ] && [ ! -x "$seccomp_dir/apply-seccomp" ]; then
    emit error sandbox_attestation "apply-seccomp not executable"
  fi

  # Check settings.json includes the sandbox block
  if [ -f "${CLAUDE_DIR}/settings.json" ]; then
    has_sandbox=$(jq -r '.sandbox // {} | length' "${CLAUDE_DIR}/settings.json")
    if [ "$has_sandbox" -eq 0 ]; then
      emit error sandbox_attestation "settings.json has no sandbox block"
    else
      emit info sandbox_attestation "sandbox block present in settings.json"
    fi
  fi
}

check_sandbox_attestation
```

**Step 3: Test**

PASS expected (settings.json has the sandbox block from Task 4 if migrated, or the original block otherwise).

**Step 4: Commit**

```bash
git commit -am "feat(check-claude-config): sandbox attestation check

Verifies ~/.claude/seccomp/ contains both apply-seccomp (executable) and
unix-block.bpf, and that settings.json includes a sandbox block. Anchors
to Invariant #4 — sandbox isolation must remain enforceable."
```

---

## Task 21: Stale-file scan (P0-8f)

**Files:**
- Modify: `scripts/check-claude-config.sh`

**Step 1: Failing test**

```bash
@test "stale-file scan reports any orphans" {
  out=$("$BATS_TEST_DIRNAME/../../../scripts/check-claude-config.sh")
  # The check itself should always run, even if no stale files found
  count=$(echo "$out" | jq '[.[] | select(.check == "stale_file")] | length')
  [ "$count" -ge 1 ]
}
```

Run: FAIL expected.

**Step 2: Implement**

```bash
check_stale_files() {
  # Pattern: legacy files known to be orphans from removed Phase 8
  local stale_patterns=(
    "learner_counter_*"
    "security_warnings_state_*"
    "CLAUDE_CODE_ANALYSIS.md"
    "tool-analytics.md"
    "permissions_auto_generated.md"
  )

  local found=0
  for pattern in "${stale_patterns[@]}"; do
    matches=$(find "$CLAUDE_DIR" -maxdepth 2 -name "$pattern" 2>/dev/null | wc -l)
    if [ "$matches" -gt 0 ]; then
      emit warn stale_file "found $matches file(s) matching pattern $pattern"
      found=$((found + matches))
    fi
  done

  if [ "$found" -eq 0 ]; then
    emit info stale_file "no stale files found"
  fi
}

check_stale_files
```

**Step 3: Test**

PASS expected.

**Step 4: Manual verification**

Run: `./scripts/check-claude-config.sh | jq '.[] | select(.check == "stale_file")'`
Expected: `"info"` level "no stale files found" (since Task 1 cleaned them).

**Step 5: Commit**

```bash
git commit -am "feat(check-claude-config): stale-file scan

Detects orphans from the removed Phase 8 Adaptive Learning system —
learner_counter_*, security_warnings_state_*, CLAUDE_CODE_ANALYSIS.md,
tool-analytics.md, permissions_auto_generated.md. Warns rather than errors
so the script doesn't fail rebuild on cosmetic drift."
```

---

## Task 22: Wire validator into rebuild-nixos Phase 4 (P0-8g)

**Files:**
- Modify: `rebuild-nixos:919-935`

**Step 1: Replace the stub**

In `rebuild-nixos`, replace lines 919-935:

```bash
# === PHASE 4: Claude Config Validator (admin only) ===
if [ "$IS_BUSINESS_HOST" = false ]; then
step "Validating Claude Code configuration"

if dry_run_skip "validate Claude Code configurations"; then
    : # skip
else
    if [ -x "./scripts/check-claude-config.sh" ]; then
        VALIDATOR_OUT=$(./scripts/check-claude-config.sh 2>&1)
        VALIDATOR_EXIT=$?

        # Count events by level
        ERRORS=$(echo "$VALIDATOR_OUT" | jq '[.[] | select(.level == "error")] | length' 2>/dev/null || echo 0)
        WARNS=$(echo "$VALIDATOR_OUT" | jq '[.[] | select(.level == "warn")] | length' 2>/dev/null || echo 0)
        INFOS=$(echo "$VALIDATOR_OUT" | jq '[.[] | select(.level == "info")] | length' 2>/dev/null || echo 0)

        if [ "$VALIDATOR_EXIT" -eq 2 ]; then
            log_warning "Claude config validator: $ERRORS errors, $WARNS warnings"
            echo "$VALIDATOR_OUT" | jq '.[] | select(.level == "error") | "  ❌ [\(.check)] \(.message)"' -r
        elif [ "$VALIDATOR_EXIT" -eq 1 ]; then
            log_warning "Claude config validator: $WARNS warnings ($INFOS info)"
            echo "$VALIDATOR_OUT" | jq '.[] | select(.level == "warn") | "  ⚠ [\(.check)] \(.message)"' -r
        else
            log_success "Claude config validated: $INFOS checks passed"
            add_stat "Claude configs: $INFOS checks OK"
        fi
    else
        log_warning "Claude config validator missing at ./scripts/check-claude-config.sh"
    fi
fi
fi  # End admin-only Phase 4
```

**Step 2: Tell user to test**

User runs: `./rebuild-nixos --quick`
Expected during Phase 4: prints either "✅ Claude configs validated: N checks passed" or warnings/errors with check name and message.

**Step 3: Add a BATS test for the integration**

Create `tests/bash/rebuild-nixos/test-phase4-validator.bats`:
```bash
#!/usr/bin/env bats

@test "rebuild-nixos Phase 4 calls check-claude-config.sh" {
  grep -q "scripts/check-claude-config.sh" /home/YOUR_USERNAME/nixos-config/rebuild-nixos
}

@test "rebuild-nixos Phase 4 handles all 3 validator exit codes" {
  grep -q 'VALIDATOR_EXIT.*-eq 0\|VALIDATOR_EXIT.*-eq 1\|VALIDATOR_EXIT.*-eq 2' /home/YOUR_USERNAME/nixos-config/rebuild-nixos
}
```

Run: `bats tests/bash/rebuild-nixos/test-phase4-validator.bats`
Expected: PASS.

**Step 4: Commit**

```bash
git add rebuild-nixos tests/bash/rebuild-nixos/test-phase4-validator.bats
git commit -m "$(cat <<'EOF'
feat(rebuild-nixos): replace Phase 4 stub with check-claude-config.sh

Phase 4 was a 17-line stub that only verified two files exist. Now invokes
scripts/check-claude-config.sh and surfaces structured results: errors
(declarative drift), warnings (cosmetic), info (all-clear). Counts shown
in the rebuild summary.

Closes P0-8 / §G5 from 2026-05-18 audit.
EOF
)"
```

---

## Phase 4 E2E verification

**Step 1: Validator runs cleanly**

Run: `./scripts/check-claude-config.sh | jq -r '.[] | "\(.level): [\(.check)] \(.message)"'`
Expected: a list of ~20+ entries, mostly `info`, possibly a few `warn`, zero `error`.

**Step 2: rebuild-nixos integrates correctly**

User runs: `./rebuild-nixos --quick`
Expected: Phase 4 prints the validator summary and proceeds.

**Step 3: Drift detection works**

Manual test: temporarily break a symlink (`mv ~/.claude/commands/nixos.md ~/.claude/commands/nixos.md.bak`), run the validator. Expected: warning about dangling symlink. Restore: `mv ~/.claude/commands/nixos.md.bak ~/.claude/commands/nixos.md`.

---

# PHASE 5 — Agent View pilot

## Task 23: Pilot task definition (P0-4a)

**Why:** Need a real, scoped task to test `claude agents` against. Picking one of the audit's P1 items keeps it useful — if Agent View handles it well, you've made progress on the audit AND tested the new primitive.

**Files:**
- Create: `docs/plans/2026-05-18-agent-view-pilot-task.md`

**Step 1: Pick the pilot task**

The pilot should be:
- Small enough to finish in ~2 hours of agent runtime
- Self-contained (no waiting on user input mid-task)
- Has a verifiable success criterion
- Doesn't require sudo

Good candidate: **P1-1 — Add `log_event` JSON structured logging to `rebuild-nixos`**. It's:
- Self-contained edit to one file
- Success criterion: events.jsonl is populated with valid JSON after a dry-run
- ~2 hours estimated effort
- No sudo (just edits + dry-run testing)

**Step 2: Write the pilot task definition**

Create `docs/plans/2026-05-18-agent-view-pilot-task.md`:
```markdown
# Agent View Pilot — P1-1: rebuild-nixos log_event

**Goal:** Add structured JSON event logging to rebuild-nixos at every phase boundary.

**Success criterion (testable):**
1. `./rebuild-nixos --dry-run` produces `~/.local/state/rebuild-nixos/events.jsonl` with N+ JSON objects (one per phase boundary)
2. Every line is valid JSON parseable by `jq`
3. Each event has fields: `ts` (ISO timestamp), `phase` (phase number/name), `event` (start|complete|skip|fail), `duration_ms` (where applicable)
4. `bats tests/bash/rebuild-nixos/test-event-log.bats` passes

**Constraints:**
- Don't change existing log behavior (the text log at $LOG_FILE stays)
- Don't break --dry-run, --quick, --boot modes
- Don't add external dependencies beyond `jq` and `date` (both already in PATH)
- Set /goal completion when all 4 success criteria pass

**Out of scope:**
- The MCP server that consumes events.jsonl (that's P1-2, separate)
- Statusline's last-status file (that's a 1-line addition in the exit handler — fine to include if convenient)
```

**Step 3: Commit**

```bash
git add docs/plans/2026-05-18-agent-view-pilot-task.md
git commit -m "$(cat <<'EOF'
docs(plans): Agent View pilot task definition (P1-1 log_event)

Defines the pilot task to test `claude agents` as a replacement for
scripts/claude-autonomous.sh. Adding JSON structured event logging to
rebuild-nixos is self-contained, has a clear pass/fail criterion, and
unblocks 4 downstream items (statusline, telemetry MCP, notifications,
monitors) regardless of pilot outcome.
EOF
)"
```

---

## Task 24: Execute pilot via `claude agents` (P0-4b)

**Why:** Actually run Agent View, comparing against what `claude-autonomous.sh` would have done.

**Files:** None modified directly by this task; the pilot agent will produce changes to `rebuild-nixos` and test files.

**Step 1: Inventory baseline metrics**

Capture before-state to compare:
```bash
echo "Lines in rebuild-nixos: $(wc -l < rebuild-nixos)"
ls -la ~/.local/state/rebuild-nixos/ 2>/dev/null || echo "no state dir"
ls tests/bash/rebuild-nixos/
```
Save output.

**Step 2: Launch the pilot agent**

Run:
```bash
claude agents --bg \
  --goal "$(cat docs/plans/2026-05-18-agent-view-pilot-task.md)" \
  --add-dir ~/nixos-config
```

(Adjust syntax per actual `claude agents` CLI — may be `claude --bg` + `/goal` once in session. Check `claude agents --help` first.)

**Step 3: Monitor**

Run: `claude agents list` or `claude logs <session-id>` periodically.
Expected: agent works through the task. `/goal` overlay shows elapsed/turns/tokens.

**Step 4: Wait for completion or 4h timeout**

Don't poll obsessively. Let it run. The agent should terminate when `/goal` criteria are met (or fail loudly if blocked).

**Step 5: Review agent output**

When done:
- Check `git log` on the agent's worktree branch (auto-isolation puts it under `.claude/worktrees/`)
- Cherry-pick or merge the agent's commits if good
- Run the validator: `./scripts/check-claude-config.sh`
- Run the new test: `bats tests/bash/rebuild-nixos/test-event-log.bats`
- Run dry-run: `./rebuild-nixos --dry-run` and verify events.jsonl populated

**Step 6: No commit here** — the agent's commits are the result.

---

## Task 25: Findings doc + decision (P0-4c)

**Files:**
- Create: `docs/plans/2026-05-18-agent-view-pilot-findings.md`

**Step 1: Document findings**

Create `docs/plans/2026-05-18-agent-view-pilot-findings.md`:
```markdown
# Agent View Pilot — Findings

**Pilot task:** P1-1 add log_event to rebuild-nixos
**Outcome:** [completed | partial | failed]
**Duration:** [actual time elapsed]

## What worked
- [List of things Agent View handled well vs claude-autonomous.sh]

## What didn't work
- [Pain points, missing features, broken expectations]

## Comparison to `claude-autonomous.sh`

| Capability | Agent View | claude-autonomous.sh |
|------------|-----------|----------------------|
| Worktree isolation | auto (.claude/worktrees/) | manual git worktree |
| Background runs | --bg + supervisor | tmux session |
| Completion criteria | /goal | COMPLETED.md / BLOCKERS.md marker |
| Multi-iteration | implicit (within /goal) | Ralph loop (max-iter) |
| Log access | claude logs <id> | tail -f log file |
| Per-agent MCP config | frontmatter mcpServers | global .mcp.json override |
| Research-mode autoresearch | NOT SUPPORTED | --research --metric |
| Strict-mode prompts | not built-in | --strict flag |

## Recommendation

[Migrate fully | Migrate partial | Keep both | Stay on claude-autonomous.sh]

[Justify with 2-3 sentences referencing the table.]

## Migration items for follow-up (if migrating)

- [ ] Port simple task mode to Agent View
- [ ] Port Ralph-loop mode
- [ ] Preserve research mode as `autoresearch-runner` subagent (P2-11)
- [ ] Move strict-mode prompts to reusable skill (P2-16)
```

Fill in based on Task 24 results.

**Step 2: Commit**

```bash
git add docs/plans/2026-05-18-agent-view-pilot-findings.md
git commit -m "$(cat <<'EOF'
docs(plans): Agent View pilot findings + migration decision

Documents pilot outcome, capability comparison vs claude-autonomous.sh,
and recommendation. Closes P0-4 from 2026-05-18 audit. Migration items
queued as follow-up tasks per recommendation.
EOF
)"
```

---

# FINAL — E2E verification across all P0 changes

## Task 26: Full E2E verification

**Step 1: Run all new BATS suites**

```bash
bats tests/bash/sandbox/
bats tests/bash/managed-settings/
bats tests/bash/subagents/
bats tests/bash/statusline/
bats tests/bash/check-claude-config/
bats tests/bash/rebuild-nixos/  # existing + new test-phase4-validator
```
Expected: all PASS.

**Step 2: Validator clean run**

Run: `./scripts/check-claude-config.sh | jq -r '.[] | select(.level != "info")'`
Expected: empty (no warnings or errors).

**Step 3: Live Claude session sanity check**

Start `claude` in `~/nixos-config`. Verify:
- Statusline visible in prompt: `[framework-16 tech | gen N | personal | last:?]`
- All 4 custom subagents listed when asking for available subagents
- MCP-NixOS responds when asked to look up a package
- Managed `claudeMd` content loaded (test by asking Claude to cite Invariant #4)

**Step 4: Full rebuild**

User runs: `./rebuild-nixos`
Expected:
- Phase 4 prints validator summary
- No regressions in any phase
- Build completes successfully

**Step 5: Spot-check Invariants**

- I1 (declarativity): `.claude/` has no orphan files (`bats tests/bash/check-claude-config/`)
- I2 (reproducibility): `nix flake check` passes
- I3 (atomic rollback): generation count incremented; previous generation still bootable
- I4 (sandbox isolation): seccomp test in `tests/bash/sandbox/` passes
- I5 (supply-chain): claude-automation removed; flake.lock shrunk
- I6 (one-line host onboarding): adding a new host doesn't require touching CC config (unchanged)
- I7 (tech↔business separation): business hosts unaffected by all P0 changes (verify by running `bats` on a tl-biz-* if available)

---

## Task 27: Update audit doc changelog

**Files:**
- Modify: `docs/plans/2026-05-18-claude-code-advancements-audit.md` (changelog at bottom)

**Step 1: Append to changelog**

In the audit doc's `## Changelog` section, add:
```markdown
- 2026-05-18: All 9 P0 items implemented per docs/plans/2026-05-18-claudeos-p0-implementation.md.
  Status:
  - P0-1 ✅ claude-automation removed
  - P0-2 ✅ sandbox schema verified + migrated (if needed)
  - P0-3 ✅ claudeMd managed setting deployed; CLAUDE.md symlink removed
  - P0-4 ✅ Agent View pilot complete; findings in 2026-05-18-agent-view-pilot-findings.md
  - P0-5 ✅ MCP-NixOS wired
  - P0-6 ✅ 4 subagents deployed
  - P0-7 ✅ statusline live
  - P0-8 ✅ Phase 4 validator replaces stub
  - P0-9 ✅ stale .claude/ files removed
```

**Step 2: Commit**

```bash
git add docs/plans/2026-05-18-claude-code-advancements-audit.md
git commit -m "docs(plans): mark all 9 P0 items complete in audit changelog"
```

---

## Done. Next steps

- P1 batch (~1 week): foundation pieces unlock most P2s. Highest leverage: P1-1 already done as Agent View pilot; P1-3 plugin packaging is next.
- P2 batch (this quarter): polish, channels (research preview), routines (research preview), strict-mode preservation.
- Re-run `./scripts/check-claude-config.sh` periodically — it's now your drift detector.
