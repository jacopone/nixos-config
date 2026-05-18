# Claude Code seccomp filter - blocks Unix domain sockets in sandbox
# Built from @anthropic-ai/sandbox-runtime vendor source
# Source: vendor/seccomp-src/{apply-seccomp.c, seccomp-unix-block.c}
#
# Produces:
#   $out/share/claude-seccomp/apply-seccomp  - Loads BPF filter + execs command
#   $out/share/claude-seccomp/unix-block.bpf - Compiled BPF bytecode
#
# Usage in settings.json (post-2026-05-18 schema migration):
#   "sandbox": {
#     "enabled": true,
#     "failIfUnavailable": true,
#     "seccomp": { "applyPath": "<path-to-apply-seccomp>" }
#   }
# BPF path is now baked into the binary at compile time via -DBPF_PATH
# because Claude Code's Zod schema strips sandbox.seccomp.bpfPath and the
# runtime invocation builder does not pass it in argv.
# See: docs/plans/2026-05-18-sandbox-schema-finding.md
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "claude-seccomp";
  version = "0.0.27";
  src = ../vendor/seccomp-src;
  buildInputs = [ pkgs.libseccomp ];

  buildPhase = ''
    # Build BPF generator and produce the filter bytecode
    gcc -O2 -o seccomp-unix-block seccomp-unix-block.c -lseccomp
    ./seccomp-unix-block unix-block.bpf
    # Build apply-seccomp. BPF_PATH is baked in at compile time so Claude
    # Code's runtime can invoke apply-seccomp without passing the BPF path
    # as argv. Required because Claude Code's Zod schema strips
    # sandbox.seccomp.bpfPath and the runtime invocation builder does not
    # pass it. See: docs/plans/2026-05-18-sandbox-schema-finding.md
    gcc -O2 -DBPF_PATH="\"$out/share/claude-seccomp/unix-block.bpf\"" \
      -o apply-seccomp apply-seccomp.c
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
