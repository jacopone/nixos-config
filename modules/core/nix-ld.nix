# nix-ld — run unpatched, dynamically-linked binaries built for a generic-FHS
# interpreter (/lib64/ld-linux-x86-64.so.2) on NixOS. Tech-host scoped (imported
# from hosts/common/default.nix, NOT base.nix), so business hosts stay locked
# down and gain no general ability to run arbitrary foreign binaries.
#
# WHY: gstack's `browse` (the QA/design Claude Code skills) drives Playwright,
# which downloads a chrome-headless-shell into ~/.cache/ms-playwright. That
# binary's interpreter is /lib64/ld-linux-x86-64.so.2; NixOS's default stub
# aborts it ("NixOS cannot run dynamically linked executables out of the box",
# nix.dev/permalink/stub-ld), so headless capture fails with "Target page,
# context or browser has been closed" and no screenshot is produced.
#
# Why not pin a nix chromium via PLAYWRIGHT_BROWSERS_PATH instead: it is NOT
# durable. gstack's bundled Playwright pins a chromium revision (1208 at time of
# writing) while nixpkgs' playwright-driver tracks a different one (1217), and the
# two drift on every gstack ./setup or `nix flake update`, re-breaking the match.
# nix-ld replaces the abort-stub at /lib64/ld-linux with a shim that honours
# NIX_LD + NIX_LD_LIBRARY_PATH, so Playwright's own correctly-versioned download
# runs as-is — today and across updates. This complements the libstdc++ wrapper
# in modules/home-manager/claude-code/gstack-browse-libfix.nix (that fixes sharp
# inside the bun ELF; this fixes the chromium Playwright launches).
{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;

    # Shared-library closure chrome-headless-shell needs. The first block is the
    # binary's direct DT_NEEDED set (22 libs, from `ldd` on the Playwright
    # chromium); the rest are libraries chromium dlopen()s at runtime (fonts,
    # GL, printing, X11 extensions). All names verified against this nixpkgs.
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++ / libgcc_s

      # NSS / NSPR (TLS, certificate handling)
      nss
      nspr

      # GLib / GTK / ATK / AT-SPI toolkit + accessibility
      glib
      gtk3
      atk
      at-spi2-atk
      at-spi2-core
      pango
      cairo
      gdk-pixbuf

      # Graphics: DRM / GBM / GL / keymap
      libdrm
      libgbm
      mesa
      libGL
      libxkbcommon

      # X11 client libraries (the xorg.* set is deprecated in this nixpkgs —
      # these are now top-level lowercase packages)
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxrender
      libxtst
      libxi
      libxscrnsaver
      libxcursor
      libxshmfence

      # System services / fonts / audio
      dbus
      expat
      cups
      alsa-lib
      systemd # provides libudev.so.1
      fontconfig
      freetype
    ];
  };
}
