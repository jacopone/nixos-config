# Strix Point Spontaneous Reboot Investigation — ama-tech-001

> **Status:** ROOT CAUSE IDENTIFIED (2026-06-05). Interim mitigation staged
> (PR #17, `pcie_ports=native`); firmware cure (`7619M0WD`) pending an LVFS/WD
> publish for the 500GB SKU (see 2026-06-06 note).
> **Host:** ama-tech-001 (Framework 16, AMD Ryzen AI 9 HX 370, Strix Point)
> **Opened:** 2026-05-22
> **Related code:** `hosts/ama-tech-001/crash-diagnostics.nix`, `modules/hardware/framework-16.nix`
> **Supersedes:** the informal investigation noted in `crash-diagnostics.nix` (2026-04-30)

## 2026-06-05 — ROOT CAUSE IDENTIFIED: WD SN7100 HMB firmware → PCIe AER → sync flood

A hard reset at **2026-06-05 19:02** (awake, on AC, near-idle — terminal + idle
GNOME) was the **first crash captured with the unambiguous hardware signature**:

```
x86/amd: Previous system reset reason [0x08000800]:
         an uncorrected error caused a data fabric sync flood event
```

This is **categorically different** from the earlier `[0x00080800]` resets the
investigation had been tracking. `[0x00080800]` = "software wrote 0x6 to 0xCF9"
is **also exactly what a normal `reboot` writes** — so it is *ambiguous* (clean
reboot ⟷ SMM reset) and does NOT by itself prove a crash. Re-classifying the
last 10 boots by shutdown markers, **9 of 10 were CLEAN**; the snapshots that
decoded CF9 sit on top of clean reboots. So **hypothesis H0 (CF9 = firmware/SMM
crash reset) was largely chasing normal reboots.** The only confirmed crash in
~12 days is this `0x08000800` sync flood. (BIOS 03.06, applied 2026-05-24, did
not stop it — but it does appear to have cut frequency from ~daily to ~1/12d.)

**Matched to Framework issue tracker [#41](https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/41)**
and the [FW13 HX 370 48-crash dataset](https://community.frame.work/t/fw13-amd-ai-300-hx-370-48-data-fabric-sync-flood-crashes-in-2-months-comprehensive-data/80338).
The mechanism, now confirmed on this machine:

- The NVMe is a **DRAM-less `WD_BLACK SN7100 500GB` on firmware `7615M0WD`** —
  the exact drive + firmware the community confirmed as a sync-flood trigger
  (fix: `7619M0WD`). It uses the PCIe **Host Memory Buffer** (`allocated 64 MiB
  host memory buffer` in dmesg), and its buggy HMB firmware emits a stream of
  **correctable PCIe AER errors** (~30–80/hr in reference cases).
- The **Framework BIOS claims PCIe AER via ACPI `_OSC` and never reports those
  errors to the OS** — confirmed here: `/sys/.../aer_dev_correctable` counters
  are empty and `pcie_ports=native` was not set. The errors accumulate silently
  until one escalates to **uncorrectable**, and the Infinity Fabric **sync-floods**.
- Empty pstore / no MCE / no BERT is **expected** for a sync flood (the reset
  fires below the CPU's exception handlers) — it does NOT argue against a HW fault.

**Adversarial verification** (independent skeptic agents): CF9-ambiguity
SUPPORTED; "absence of MCE/BERT doesn't rule out HW fault" SUPPORTED; **"sync
flood is usually the RAM" REFUTED** (the reference dataset ruled out memory: a
1→2 DIMM swap changed nothing; NVMe firmware was the fix). WiFi is the stock
**MediaTek MT7925** (the *clean* card, not the AX210 trigger) — that path ruled out.

### The fix (in priority order)

> **2026-06-06 — firmware cure is not on LVFS *stable* yet.** `sudo fwupdmgr
> update` reports `WD BLACK SN7100 500GB` under "Devices with no available
> firmware updates" (still `7615M0WD`); the drive is `Updatable` but no
> `7619M0WD` payload is published on the stable remote for the 500GB SKU. So the
> firmware cure is temporarily out of reach via the default path, which promotes
> `pcie_ports=native` from "verify" to the **primary interim mitigation**.
> (Earlier note that fwupd "lists it as a pending update" was a misread.)

1. **PRIMARY (interim) — `pcie_ports=native pcie_ecrc=on` + rebuild.** Staged in
   `crash-diagnostics.nix` (PR #17). This is *not just* observability: upstream
   (jcdutton, issue #41) found native OS AER ownership **converts the would-be
   sync floods into correctable AER events the kernel handles gracefully** — so
   it can stop the reboots even before the firmware is fixed. It also surfaces
   the SN7100's error stream (`ras-mc-ctl --errors`, per-boot snapshots) so the
   eventual firmware cure can be confirmed by the AER count falling to **zero**.
2. **THE CURE — update the SN7100 firmware `7615M0WD → 7619M0WD`** (vendor
   Sandisk, `NVME\VEN_15B7&DEV_5045`). Not on the LVFS *stable* remote yet; new
   NVMe firmware usually lands in `lvfs-testing` first, so try:
   ```
   sudo fwupdmgr enable-remote lvfs-testing   # testing channel (disabled by default)
   sudo fwupdmgr refresh --force
   fwupdmgr get-updates                       # look for SN7100 -> 7619M0WD
   sudo fwupdmgr update                        # on AC power; reboots to apply
   ```
   If still absent, fall back to **SanDisk/WD Dashboard on Windows** (no Linux
   updater exists) — a one-time Windows USB / dual-boot. Re-check LVFS stable
   periodically; the payload will likely be promoted there in time.
3. If sync floods recur *after* the firmware update with zero NVMe AER: pursue
   the secondary upstream trigger (heavy iGPU↔RAM traffic / UMA — see H1 notes
   and `amdgpu.gttsize`/`vm_update_mode` discussion in the research), then the
   single-DIMM memory test as a last resort.

The detailed reset-reason / boot-classification / upstream-research evidence for
this conclusion is in the conversation log of 2026-06-05; the sections below are
the **prior (pre-root-cause) investigation**, kept for history.

## Problem

`ama-tech-001` hard-resets without warning, leaving filesystems unclean on the
next boot. No kernel panic is captured. The first documented occurrences were
2026-04-12/20/21/22/24/30; the pattern has continued through 2026-05-22.

This is **independent of** the MT7925 Bluetooth fix and the eDP flicker fix
applied 2026-05-22 (kernel pin to 6.18.20 + `amdgpu.dcdebugmask=0x1010`). The
reboots predate both and occur across all kernel versions.

## Evidence gathered

### Crash history (from `/var/log/crash-diagnostics/` snapshots)

| Date / boot snapshot | Prev kernel | Verdict | GPU fault before crash |
|---|---|---|---|
| 2026-05-04 17:20 | 6.18.24 | crash | no journal data (volatile) |
| 2026-05-04 23:17 | 6.18.26 | crash | no journal data |
| 2026-05-05 07:14 | 6.18.26 | crash | no journal data |
| 2026-05-07 12:57 | 6.18.26 | crash | no journal data |
| 2026-05-11 10:12 | 6.18.26 | crash | no journal data |
| 2026-05-12 08:57 | 6.18.26 | crash | no journal data |
| 2026-05-13 08:25 | 6.18.26 | **crash** | **`MES ring buffer is full` ×261** |
| 2026-05-22 12:18 | 6.18.20 | **crash** | **`enc1_stream_encoder_dp_blank` timeout ×2**; reset reason `[0x00080800]` CF9 |
| 2026-05-24 08:49 | 6.18.20 | **crash** | `gnome-session`/`gdm` `int3` traps in libglib during a live `nixos-rebuild switch`; reset reason `[0x00080800]` CF9 |

Clean shutdowns interleave throughout (6.18.26 and 6.18.31). The 2026-05-22
crash occurred while the machine was awake and near-idle (last userspace
activity 12:17:40, reset before 12:18:52) — not during suspend/resume, not
under rebuild load.

**2026-05-24 (instance #7, first caught by the reset-reason instrumentation):**
Same `[0x00080800]` CF9 reset signature as 2026-05-22 — two independent crashes
now share the exact reset code, confirming a single consistent mechanism.
Occurred ~7 min after a live `./rebuild-nixos` switch that restarted the GNOME
stack (the nixpkgs bump changed glib → old `gnome-session`/`gdm` processes
`trap int3` in `libglib-2.0.so.0.8600.3` as they were torn down). The
display-stack restart is a *plausible trigger* on this GPU-implicated machine,
but the gap weakens causation and the issue fires roughly daily regardless.
**Mitigation to test:** prefer `./rebuild-nixos --boot` on this host (stage for
next boot, no live display-stack restart) to avoid activation turbulence.

### Hard facts

1. **pstore is empty after every crash** despite `oops=panic` + `panic=15`
   being active. The kernel never reaches its panic handler → the reset
   originates below the kernel (SoC or EC), or the kernel is wedged.
2. **Kernel-version-independent.** Crashes on 6.18.20, .21, .24, .26. The only
   kernel with zero crashes in the snapshot window is 6.18.31, but that is a
   2-boot sample and not significant.
3. **The two crashes with usable journal data both show amdgpu GPU faults
   immediately prior** (MES scheduler saturation; DP encoder timeout). The six
   early crashes have no journal data (journald was volatile at the time), so
   absence of GPU signatures there is not evidence of absence.

### Firmware baseline (complete, via `framework_tool --versions`)

- Mainboard: Laptop 16 (AMD Ryzen AI 300 Series), MassProduction
- **BIOS: 03.05** (2026-03-13) — UEFI ESRT `0.0.3.5`
- **EC: 3.0.5 (tulip)** `tulip-3.0.5-178a77d` (2026-03-12), image RO
- PD controllers: 0.0.22 (both L/R)
- Firmware installed mid-March; first crashes 2026-04-12 → crashes occur *under
  this firmware*, not because it is ancient.

### Newer firmware exists: BIOS 03.06 (on LVFS)

`fwupdmgr get-updates` offers System Firmware `0.0.3.6` (BIOS 03.06, EC
`ec_306_eb68558`). Changelog (verbatim):
- "Resolved intermittent system hangs or black screens occurring during the
  entry or resume phases of Hybrid Shutdown."
- "Fixed a Yellow Bang affecting the AMD Audio Co-Processor and HD Audio
  Controller when resuming from Hybrid Shutdown."
- "Fixed an issue where Bluetooth audio output was non-functional." (BT *audio*,
  not the btmtk `wmt func ctrl` kernel regression — unrelated to our pin.)
- Known issue remaining: "Intermittent CPU frequency lock at 600MHz following
  S3/Modern Standby resume."

**Caveat:** 3.06's stability fixes are scoped to *Hybrid Shutdown entry/resume*.
Our crashes occur during normal awake operation (today's near-idle), so 3.06 may
not address them. Worth applying regardless (newer, related fixes, removes a
variable), but not a confirmed cure.

## Hypotheses (ranked)

### Register evidence (2026-05-23) — reset reason now KNOWN

Kernel 6.18.20 includes the mainline "x86/CPU/AMD: Print the reason for the last
reset" patch. The boot *after* the 2026-05-22 crash printed:

```
x86/amd: Previous system reset reason [0x00080800]: software wrote 0x6 to reset control register 0xCF9
```

This is a **CF9h software reset (0x00080800)** — NOT the sync flood (0x08000800)
of Framework issue #41. The earlier sync-flood hypothesis is **refuted by direct
register evidence** for this crash.

### H0 — Firmware/SMM-issued CF9 reset *(leading, register-supported)*

The kernel says software wrote 0x6 to port 0xCF9, but: no clean-shutdown logs,
no kernel panic, empty pstore, and the systemd runtime watchdog is disabled
(`RuntimeWatchdogUSec=0`, `sp5100_tco` loaded but unarmed). The only actor that
can write 0xCF9 *invisibly to the kernel* is SMM (System Management Mode) — BIOS
/ EC firmware running below the OS. An SMI handler reacting to a detected fault
(thermal, power, PD, or an internal hang monitor) issues the CF9 reset.

- **Supports:** matches the register read exactly; explains empty pstore (kernel
  never runs its panic path), no clean shutdown, kernel-version independence
  (firmware-level), at-idle timing. Returns to the original 2026-04-30
  hypothesis ("silent firmware reset on EC/SoC"), now with evidence.
- **Implication:** strongly motivates the BIOS 03.06 update and reporting the
  reset-reason data to Framework. Also means the GPU faults (H1) are more likely
  *symptoms of the freeze* than the cause.
- **Relationship to the kernel pin:** firmware-level cause → the 6.18.20 BT pin
  does not affect reboot frequency. The earlier pin-vs-reboot tension is largely
  dissolved.

### H1 — Strix Point iGPU hang as the SMM trigger *(secondary)*

amdgpu wedges (MES ring saturation, DCN 3.5 DP encoder timeout); the kernel
freezes; the EC/SMM fault monitor then issues the CF9 reset (the H0 mechanism).
GPU hang = trigger, firmware CF9 = mechanism.

- **Supports:** both data-rich crashes show amdgpu faults; empty pstore (kernel
  wedged in GPU code, never panics); kernel-version-independence (amdgpu Strix
  Point support buggy across 6.18.x); `cwsr_enable=0` was already needed for
  "MES ring saturation and GPU reset loops" per `framework-16.nix`.
- **Contradicts / gaps:** 6 early crashes lack data; one *clean* boot also had a
  DP timeout (so GPU faults are not always fatal).

### H2 — Framework EC / BIOS firmware fault *(original hypothesis)*

The EC or BIOS spontaneously resets the SoC; GPU faults are coincidental.

- **Supports:** silent reset, no pstore, kernel-independent — all consistent.
- **Contradicts / gaps:** does not explain why the data-rich crashes correlate
  with GPU faults specifically.
- Note: H1 and H2 may be the *same* mechanism (GPU hang → EC watchdog). The
  watchdog firing is H2's machinery; the GPU hang is H1's trigger.

### H3 — Power delivery / USB-C PD instability *(low)*

- **Supports:** chronic `usb 3-4.1` device resets; UCSI history on this host.
- **Contradicts / gaps:** weak; no direct tie to the reset moments.

## Next steps / action items

- [x] **Establish firmware baseline.** Done: BIOS 03.05 / EC 3.0.5 (see above).
- [x] **Update to BIOS 03.06 via LVFS.** Done 2026-05-24 — System Firmware now
      `0.0.3.6` (verified via `fwupdmgr get-devices`; no pending update). Running
      gen 68 on it. NOTE: this boot prints NO kernel reset reason (prior boots
      always showed `[0x00080800]`), so BIOS 03.06 likely changed FCH
      `S5_RESET_STATUS` handling — the reset-reason instrumentation may no longer
      capture future crashes the same way; revisit only if a crash recurs.
- [ ] **Observe for recurrence.** Success criterion: no spontaneous reboot for
      ~1 week of normal use (instance #7 ran ~1d20h before crashing; interval was
      variable). As of 2026-05-25 the gen-68 session is 18h+ stable and the prior
      gen-67 session ended in a clean shutdown — promising, not yet conclusive.
      If a reboot recurs: check `/var/log/crash-diagnostics/` and take the reset
      reason to Framework's SoftwareFirmwareIssueTracker (#41).
- [x] **Instrument `S5_RESET_STATUS` capture.** Done — kernel 6.18.20 already
      decodes it; `crash-diagnostics.nix` now greps the per-boot "reset reason"
      line into every snapshot. First read (2026-05-22 crash): `[0x00080800]`
      CF9 software reset → refuted sync flood, established H0 (firmware/SMM CF9).
- [x] **Rule out OS watchdog.** Done — `RuntimeWatchdogUSec=0` (systemd runtime
      watchdog disabled); `sp5100_tco` loaded but unarmed; no lockup events. Not
      an OS-initiated watchdog reset.
- [ ] **Try BIOS setting: disable "PCIE Dynamic Link Power Management."** A
      community report ties random reboots to PCIe ASPM at the BIOS level
      (separate from our kernel `pcie_aspm=off`). Test if 3.06 doesn't help.
- [ ] **Improve crash capture for H1.** Confirm persistent journald is enabled
      (recent snapshots have data; early ones did not). Consider enabling the
      `panic_on_warn=1` option already stubbed in `crash-diagnostics.nix` to
      convert amdgpu `WARN()`s into captured panics. Weigh against false-reset
      risk.
- [ ] **Add amdgpu state logging.** Periodic capture of MES ring state, GPU
      temp/clocks, and a hook on `enc1_stream_encoder_dp_blank` to snapshot GPU
      state when a DP timeout fires (extend the existing
      `display-recovery-watchdog`).
- [ ] **Resolve the kernel-pin tension.** Today's BT/flicker fix pins kernel to
      6.18.20 (oldest amdgpu, most GPU bugs). If H1 holds, this may *increase*
      reboot frequency vs 6.18.31. Track crash frequency on 6.18.20 over the
      next 1–2 weeks and compare. If reboots worsen, the BT pin and the reboot
      fix are in direct conflict and need rethinking (e.g., btmtk revert patch
      on a newer kernel instead of a version pin).
- [ ] **Check upstream trackers** (kernel.org bugzilla, Framework community,
      AMD) for Strix Point / DCN 3.5 iGPU hang, MES ring saturation, and DP
      encoder timeout reports on 6.18.x.

## Open questions

- Do amdgpu faults precede *all* crashes, or only some? (Needs more data-rich
  crashes now that journald persists.)
- Is the external monitor (DP-3 via USB-C) implicated? Both DP-encoder-timeout
  crashes coincide with an external display attached.
- Does crash frequency actually differ by kernel version, controlling for
  uptime and workload?
- Is firmware up to date?

## Evidence log

- Snapshots: `/var/log/crash-diagnostics/*.log` (one per boot; prior-boot kernel
  ringbuffer + EC console + pstore listing).
- Diagnostic that produced the crash-history table: per-snapshot scan for
  shutdown markers (clean) vs their absence (crash), plus grep counts of
  `MES ring buffer is full` and `enc1_stream_encoder_dp_blank`.
- Today's crash snapshot: `/var/log/crash-diagnostics/20260522-101854.log`.
