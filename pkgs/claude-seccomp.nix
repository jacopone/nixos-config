# Claude Code seccomp filter - blocks Unix domain sockets in sandbox
# Built from @anthropic-ai/sandbox-runtime vendor source
# Source: vendor/seccomp-src/{apply-seccomp.c, seccomp-unix-block.c}
#
# Produces:
#   $out/share/claude-seccomp/apply-seccomp  - Loads BPF filter + execs command
#   $out/share/claude-seccomp/unix-block.bpf - Compiled BPF bytecode
#
# Usage in settings.json:
#   "sandbox": { "seccomp": { "bpfPath": "...", "applyPath": "..." } }
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "claude-seccomp";
  version = "0.0.26";
  src = ../vendor/seccomp-src;
  buildInputs = [ pkgs.libseccomp ];

  buildPhase = ''
    # Build BPF generator and produce the filter bytecode
    gcc -O2 -o seccomp-unix-block seccomp-unix-block.c -lseccomp
    ./seccomp-unix-block unix-block.bpf
    # Build apply-seccomp (loads BPF + execs target with filter active)
    gcc -O2 -o apply-seccomp apply-seccomp.c
  '';

  installPhase = ''
    mkdir -p $out/share/claude-seccomp
    cp apply-seccomp $out/share/claude-seccomp/
    chmod +x $out/share/claude-seccomp/apply-seccomp
    cp unix-block.bpf $out/share/claude-seccomp/
  '';

  meta = {
    description = "Seccomp BPF filter for Claude Code sandbox (blocks AF_UNIX socket creation)";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
