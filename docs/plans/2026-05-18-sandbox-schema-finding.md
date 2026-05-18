# Sandbox Settings Schema Investigation — P0-2a Finding

> Task 3 of `docs/plans/2026-05-18-claudeos-p0-implementation.md`.
> Resolves P0-2 investigation prerequisite from the 2026-05-18 audit (audit §G13).
>
> Claude Code under inspection: `2.1.143` (build `2026-05-15T17:39:39Z`, git
> `cfb8132e4c3551e2773f41a1900efd1cc93637db`), Nix store path
> `/nix/store/b4pviq7rl1j13dsbq55nvpgigvwfcg2z-claude-code-2.1.143`.

## Bottom line

`sandbox.seccomp.applyPath` IS recognized by the live Claude Code schema and IS
read by the runtime. `sandbox.seccomp.bpfPath` is **NOT recognized** — it was
silently stripped by the Zod schema. Additionally, the runtime invocation of
`apply-seccomp` does NOT pass the BPF path as an argument, so the user's
vendored `apply-seccomp.c` (which expects `argv[1] = <bpf-path>`) is
incompatible with the current Claude Code calling convention regardless of
schema correctness.

**Recommended action: migrate.** Track in Task 4 (P0-2b).

---

## Step 1 — Documentation review

Source: `https://code.claude.com/docs/en/sandboxing` and
`https://code.claude.com/docs/en/settings`, fetched 2026-05-18.

Documented `sandbox.*` properties as of v2.1.143:

| Property | Notes |
| -------- | ----- |
| `enabled` | top-level toggle |
| `failIfUnavailable` | hard-fail if sandbox unavailable |
| `autoAllowBashIfSandboxed` | auto-allow bash inside sandbox |
| `allowUnsandboxedCommands` | escape-hatch toggle for `dangerouslyDisableSandbox` |
| `excludedCommands` | regex list of commands to run outside sandbox |
| `enableWeakerNestedSandbox` | Docker/nested-sandbox mode (weakens isolation) |
| `enableWeakerNetworkIsolation` | weakens network isolation |
| `bwrapPath` | explicit path to `bwrap` binary (v2.1.133+) |
| `socatPath` | explicit path to `socat` binary (v2.1.133+) |
| `filesystem.{allowWrite,denyWrite,allowRead,denyRead,allowManagedReadPathsOnly}` | path-based isolation |
| `network.{allowedDomains,deniedDomains,allowUnixSockets,allowAllUnixSockets,allowLocalBinding,allowMachLookup,allowManagedDomainsOnly,httpProxyPort,socksProxyPort}` | network controls |

**`sandbox.seccomp.*` is not mentioned in the published documentation** — not
as current, not as legacy, not as deprecated. The only place the string
`sandbox.seccomp.bpfPath and applyPath in settings.json` appears is inside the
CLI binary itself, in a `/sandbox` Dependencies tab warning text rendered when
seccomp is missing (see Step 2). It is not in the public docs.

## Step 2 — Live CLI schema query

`claude --print-settings-schema` does not exist:

```
$ claude --print-settings-schema 2>&1 | head -1
error: unknown option '--print-settings-schema'
```

`claude config get sandbox` is also not available (the `config` subcommand is
ambiguous in v2.1.143).

Fell back to **binary string analysis** on
`/nix/store/b4pviq7rl1j13dsbq55nvpgigvwfcg2z-claude-code-2.1.143/bin/.claude-unwrapped`.

### Audit/normalization filter (`om8`)

The settings auditor enumerates **recognized** sandbox subkeys:

```js
sandbox: new Set([
  "enabled", "failIfUnavailable", "allowUnsandboxedCommands",
  "network", "filesystem", "ignoreViolations", "excludedCommands",
  "autoAllowBashIfSandboxed", "enableWeakerNestedSandbox",
  "enableWeakerNetworkIsolation", "ripgrep"
])
```

`seccomp` is NOT in this set — so the analytics/reporter path treats it as
unknown. The schema is parsed with `PP().strip().parse(H)`, a Zod schema with
`.strip()` (unknown keys silently dropped from the normalized object).

### Actual schema with seccomp (Zod object)

However, a separate Zod object literal in the binary defines the seccomp
subschema:

```js
seccomp: Qt1.optional().describe("Custom seccomp binary paths (Linux only)…")
```

where

```js
Qt1 = U8.object({
  applyPath: U8.string().optional()
    .describe("Path to the apply-seccomp binary"),
  argv0: U8.string().optional()
    .describe("Invoke apply-seccomp as a multicall binary that dispatches on
               the ARGV0 environment variable. When set, applyPath is used
               verbatim (no existence check) and the invocation inside bwrap is
               prefixed with ARGV0=<this value>. The caller is responsible for
               ensuring applyPath resolves inside the bwrap namespace and that
               the target binary implements the apply-seccomp interface when
               ARGV0 matches.")
})
```

So the **schema accepts `sandbox.seccomp.{applyPath, argv0}`** but **NOT
`bpfPath`**. The string `bpfPath` does not appear anywhere as a schema field —
only inside the user-facing hint text `"…or copy vendor/seccomp/* from
sandbox-runtime and set sandbox.seccomp.bpfPath and applyPath in
settings.json"`. That hint refers to an older schema; the current binary's
Qt1 schema is `{applyPath, argv0}` only.

### Runtime reads

The dependency checker (`eFK`) and sandbox-config plumbing read from a
parsed sandbox config object `H1`:

```js
let A = eFK({
  seccompConfig: H1?.seccomp,
  bwrapPath:    H1?.bwrapPath,
  socatPath:    H1?.socatPath,
})
```

and

```js
function It1() { return H1?.seccomp }
```

`H1` aligns with the recognized sandbox subkeys (`bwrapPath`, `socatPath`,
`ripgrep`), confirming `H1` is the parsed `sandbox` settings object. So
`H1.seccomp` does correspond to `settings.sandbox.seccomp`. Because Zod
`.strip()` drops unknown keys, `bpfPath` does not survive parsing — only
`applyPath` and `argv0` reach `H1.seccomp` at runtime.

### Invocation builder (`Ot1`)

When constructing the sandbox command line, Claude Code builds the
`apply-seccomp` prefix as:

```js
function Ot1(applyPath, argv0) {
  if (argv0) {
    if (!applyPath) throw Error("seccompConfig.argv0 requires seccompConfig.applyPath");
    return `ARGV0=${quote([argv0])} ${quote([applyPath])} `;
  }
  let resolved = cA6(applyPath);
  return resolved ? `${quote([resolved])} ` : void 0;
}
```

Critically: **no BPF path is passed as an argument**. Claude Code expects the
`apply-seccomp` binary to know its own filter location (either bundled
alongside or hardcoded via the `argv0` multicall mechanism).

The CLI also searches for `apply-seccomp` at vendor paths under
`vendor/seccomp/${arch}/apply-seccomp`, falling back to global npm
installations under `<prefix>/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/${arch}/`.

## Step 3 — Runtime verification

Chose option (a) per the task brief — ran the syscall test in the ambient
session.

```
$ python3 -c "import socket; s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); print('socket created — seccomp NOT active')"
socket created — seccomp NOT active in this ambient session
```

**Caveat**: this session is a regular interactive Claude session, not a
sandboxed one. There is no `SANDBOX_RUNTIME=1` env var, no `/tmp/claude`
directory, and no socat bridges on `:3128`/`:1080`. So this test only proves
that no seccomp filter is active on Claude's own subprocess shell — it does
not directly exercise the autonomous-worktree code path.

**Static evidence is stronger**, however:

1. The Nix module writes `sandbox.seccomp.bpfPath` — this is a Zod-unrecognized
   key and is silently stripped before reaching runtime. Only `applyPath`
   survives.
2. Even if `applyPath` survives, the runtime builds the invocation as
   `<applyPath> <command>`, which does NOT pass the BPF file path to the
   vendored `apply-seccomp.c`. That binary's `main()` requires `argv[1]` to be
   the BPF filter file path; it would instead receive the target command name
   and try to open it as a BPF filter — `open(filter_path, O_RDONLY)` would
   succeed for an executable file but reading 8-byte instructions would
   produce garbage and `prctl(PR_SET_SECCOMP, …)` would fail (or worse,
   apply a corrupt filter then exec something else).

Combined, this is sufficient evidence that the sandbox seccomp BPF filter is
**not active under the current configuration**. Invariant #4 (sandbox
isolation) is at risk for `scripts/claude-autonomous.sh` runs that rely on
Claude Code's native sandbox.

For complete certainty a re-verification should run after the migration in
Task 4, ideally by launching `scripts/claude-autonomous.sh` with the
post-migration configuration and inside that worktree running the same Python
AF_UNIX probe. That test is **deferred to Task 4 acceptance**.

## Step 4 — Recommended action

**Migrate** (Task 4 / P0-2b). Required changes to
`modules/home-manager/claude-code/default.nix`:

1. **Drop `bpfPath`** from the JSON merge — it is silently stripped and serves
   no purpose other than to mislead future readers into thinking seccomp is
   declaratively configured.

2. **Move `applyPath` under a `sandbox.enabled = true` parent** — without
   `sandbox.enabled`, none of the sandbox machinery runs. The user's
   `settings.json` should look like:

   ```json
   {
     "sandbox": {
       "enabled": true,
       "failIfUnavailable": true,
       "seccomp": {
         "applyPath": "/home/<user>/.claude/seccomp/apply-seccomp"
       }
     }
   }
   ```

3. **Switch the vendored `apply-seccomp.c` to a multicall/wrapper design**
   so that the BPF file path is either:
   - resolved by the binary itself relative to its own location (e.g.,
     `dirname(argv[0])/unix-block.bpf`), OR
   - hardcoded at build time via the Nix-store-derived absolute path
     (`/nix/store/...-claude-seccomp/share/claude-seccomp/unix-block.bpf`).

   Option (b) is the cleanest fit for Nix: pass the BPF path as a
   compile-time `-D` define in `pkgs/claude-seccomp.nix`. This decouples
   from Claude Code's calling convention entirely.

4. **Optionally adopt `argv0` mode** if Anthropic's multicall convention
   stabilizes, but the wrapper-with-baked-in-BPF approach is simpler and
   doesn't depend on Anthropic preserving the multicall hook.

5. **Add a runtime probe** in `rebuild-nixos` validator phase (planned
   Task 16-22) that re-runs the AF_UNIX socket test inside an
   `claude-autonomous.sh` launch, so regressions are caught at activation
   rather than at autonomous-run time.

### Hybrid alternative (not recommended)

Keep `bpfPath` in the merged settings as a no-op breadcrumb for humans, but
also fix the runtime. Rejected because:

- The unknown-key strip is silent — there's no surface evidence the breadcrumb
  is doing anything.
- Future Anthropic schema versions may upgrade `.strip()` to `.strict()` and
  start erroring on unknown keys, which would suddenly break the user.

### Keep (do nothing)

Rejected — the current state silently violates Invariant #4.

## Citations

- `https://code.claude.com/docs/en/sandboxing` (fetched 2026-05-18)
- `https://code.claude.com/docs/en/settings#sandbox-settings` (fetched 2026-05-18)
- `/nix/store/b4pviq7rl1j13dsbq55nvpgigvwfcg2z-claude-code-2.1.143/bin/.claude-unwrapped`
  functions: `om8` (auditor), `eFK` (depcheck), `It1`/`Kt1`/`_t1`/`cA6`
  (seccomp resolution), `Ot1` (invocation builder), `Qt1` (Zod sandbox.seccomp
  schema)
- `modules/home-manager/claude-code/default.nix:51-54` (current Nix module)
- `pkgs/claude-seccomp.nix` (vendored builder)
- `vendor/seccomp-src/apply-seccomp.c:36-50` (entrypoint requires `argv[1]` as
  BPF path)
- `scripts/claude-autonomous.sh:607` ("Using Claude Code native sandbox
  (bubblewrap + seccomp)")
