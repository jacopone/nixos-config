# gstack `browse` libstdc++ fix — declarative, self-reapplying wrapper.
#
# gstack's headless-Chromium `browse` tool (used by the QA/design Claude Code
# skills) embeds sharp's prebuilt @img/sharp-linux-x64 binding. That .node
# dlopen()s libstdc++.so.6 at runtime; the bun-compiled ELF has a nix-store
# glibc interpreter (so the process starts) but no RPATH to a C++ runtime, so
# the load fails with ERR_DLOPEN_FAILED on NixOS. `browse` is a long-running
# daemon, so the fix must live in the daemon's environment.
#
# gstack is not nix-packaged: it is cloned into ~/.claude/skills/gstack and
# self-updates via `./setup` / gstack-upgrade, which overwrites dist/browse.
# A home-manager activation step is therefore the durable seam — it reinstates
# a scoped wrapper on every rebuild, surviving tool updates, where a one-off
# patched binary would be clobbered. nix-ld cannot help here: it only shims
# binaries whose interpreter is /lib64/ld-linux-x86-64.so.2, and this binary's
# interpreter is a nix-store path.
#
# Shared module: imported by claude-code/default.nix, which both mkTechHost
# (modules/home-manager/default.nix) and mkBusinessHost
# (modules/business/home-manager/default.nix) pull in. The browse binary only
# exists where gstack is installed, so the runtime guard keeps this inert on
# hosts without it.
{ lib, pkgs, ... }:

let
  # Scoped wrapper installed in place of gstack's dist/browse. It locates the
  # real binary (dist/browse.bin) relative to itself, so it is independent of
  # $HOME or the absolute skills path. The 'gstack-browse-libstdcxx-wrapper'
  # marker in the body is what the activation greps for to recognise its own
  # work (idempotency).
  browseWrapper = pkgs.writeShellScript "gstack-browse-libstdcxx-wrapper" ''
    # gstack-browse-libstdcxx-wrapper — managed by home-manager
    # (modules/home-manager/claude-code/gstack-browse-libfix.nix). Do not edit:
    # `./setup` / gstack-upgrade overwrites dist/browse, and the next
    # nixos-rebuild reinstates this wrapper.
    #
    # sharp's prebuilt binding dlopen()s libstdc++.so.6; the bun ELF carries no
    # RPATH to a C++ runtime. Inject the pinned gcc runtime lib dir for THIS
    # process and the daemon it spawns only — never a global LD_LIBRARY_PATH
    # (that overrides other binaries' RPATH and can destabilise them).
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
    exec "$(${pkgs.coreutils}/bin/dirname "$(${pkgs.coreutils}/bin/readlink -f "$0")")/browse.bin" "$@"
  '';
in
{
  # Reinstate the wrapper after each rebuild. Ordered after writeBoundary so
  # $HOME file operations are safe. Deliberately NOT ordered after the
  # business-only `gstack-install` entry, so the same code evaluates on tech
  # hosts too; the cost is that on a business host's first activation the
  # wrapper lands one rebuild after gstack is cloned (self-heals next rebuild).
  home.activation.gstack-browse-libfix =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DIST="$HOME/.claude/skills/gstack/browse/dist"
      BROWSE="$DIST/browse"
      REAL="$DIST/browse.bin"

      # No-op unless gstack's browse is installed on this host. Use `if` rather
      # than `... || exit` so this never aborts sibling activation scripts.
      if [ -e "$BROWSE" ]; then
        if ${pkgs.gnugrep}/bin/grep -q 'gstack-browse-libstdcxx-wrapper' "$BROWSE" 2>/dev/null; then
          # Already our wrapper. Re-copy so the embedded gcc-lib store path
          # tracks the current generation (it changes across nixpkgs bumps).
          # Only when the real binary is present.
          if [ -e "$REAL" ]; then
            $DRY_RUN_CMD install -m755 "${browseWrapper}" "$BROWSE"
          fi
        elif ${pkgs.file}/bin/file -b "$BROWSE" | ${pkgs.gnugrep}/bin/grep -q '^ELF '; then
          # A fresh bun ELF: first install, or `./setup` / gstack-upgrade rebuilt
          # dist/browse (leaving a now-stale browse.bin). Promote it to
          # browse.bin and install our wrapper over browse.
          $DRY_RUN_CMD mv -f "$BROWSE" "$REAL"
          $DRY_RUN_CMD install -m755 "${browseWrapper}" "$BROWSE"
        elif [ -e "$REAL" ]; then
          # browse is a foreign script (e.g. the legacy hand-rolled stopgap that
          # globs /nix/store/*-gcc-*-lib). The real ELF already sits at
          # browse.bin — supersede the stopgap with our pinned wrapper.
          $DRY_RUN_CMD install -m755 "${browseWrapper}" "$BROWSE"
        fi
        # else: browse is neither ours, an ELF, nor is there a browse.bin — we
        # cannot locate the real binary, so leave it untouched rather than break it.
      fi
    '';
}
