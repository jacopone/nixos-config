# Claude Code business guardrail — blocks dangerous operations
# Deployed via NixOS Home Manager as immutable Nix store symlink
# Input: JSON on stdin with tool_name and tool_input
# Output: JSON decision on stdout, or silent exit 0 to approve

set -euo pipefail

# Fail open if dependencies unavailable
if ! command -v jq &>/dev/null; then exit 0; fi

INPUT=$(cat)
if [ -z "$INPUT" ]; then exit 0; fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
if [ -z "$TOOL_NAME" ]; then exit 0; fi

block() {
  jq -n --arg reason "$1" '{"decision":"block","reason":$reason}'
  exit 0
}

case "$TOOL_NAME" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

    # --- Destructive git operations ---
    if echo "$CMD" | grep -qE 'git\s+push\s+.*(-f\b|--force)'; then
      block "Force push blocked — can destroy remote history. Ask your admin."
    fi
    if echo "$CMD" | grep -qE 'git\s+reset\s+--hard'; then
      block "git reset --hard blocked — destroys uncommitted work. Use git stash or ask admin."
    fi
    if echo "$CMD" | grep -qE 'git\s+(checkout|restore)\s+\.'; then
      block "Discarding all changes blocked. Use git stash to save work, or ask admin."
    fi
    if echo "$CMD" | grep -qE 'git\s+clean\s+.*-[a-zA-Z]*f'; then
      block "git clean -f blocked — permanently deletes untracked files. Ask admin."
    fi
    if echo "$CMD" | grep -qE 'git\s+branch\s+.*-D'; then
      block "Force branch delete blocked — can lose unmerged work. Use -d or ask admin."
    fi
    if echo "$CMD" | grep -qE 'git\s+.*--no-verify'; then
      block "--no-verify blocked — skips safety checks. Fix the issue instead."
    fi

    # --- Catastrophic file deletion ---
    if echo "$CMD" | grep -qE '\brm\b.*-[a-zA-Z]*r' && echo "$CMD" | grep -qE '\brm\b.*\s(/|~|\.)(\s|$)'; then
      block "Recursive delete on root/home/project directory blocked. Be specific about what to delete."
    fi

    # --- Publishing and deploying ---
    if echo "$CMD" | grep -qE '\b(npm\s+publish|docker\s+push)\b'; then
      block "Publishing packages/containers is admin-only."
    fi
    if echo "$CMD" | grep -qE '\bgcloud\s+(run\s+)?deploy\b'; then
      block "GCP deployment is admin-only."
    fi

    # --- System administration ---
    if echo "$CMD" | grep -qE '(^|\s)sudo\s'; then
      block "sudo blocked — tell your user to run this command manually."
    fi
    if echo "$CMD" | grep -qE '\bnixos-rebuild\b'; then
      block "nixos-rebuild blocked — tell your user to run it manually."
    fi

    # --- Remote code execution ---
    if echo "$CMD" | grep -qE '(curl|wget)\s.*\|\s*(bash|sh)'; then
      block "Piping remote scripts to shell blocked — security risk. Download and review first."
    fi

    # --- Insecure permissions ---
    if echo "$CMD" | grep -qE '\bchmod\s+777\b'; then
      block "chmod 777 blocked — world-writable is insecure. Use 755 or 644."
    fi
    ;;

  Write|Edit)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

    case "$FILE" in
      */.github/workflows/*)
        block "CI/CD workflows are admin-only. Describe your change and ask admin." ;;
      */Dockerfile|*/Dockerfile.*)
        block "Dockerfiles are admin-only. Ask admin." ;;
      */.env|*/.env.production|*/.env.staging)
        block "Environment files may contain secrets. Use .env.development.local for local config." ;;
      *.pem|*.key|*.secret|*.credential|*.p12|*.pfx|*.jks)
        block "Secret/key files must not be modified via Claude Code." ;;
      */flake.nix|*/flake.lock)
        block "Nix flake files are admin-only. Ask admin." ;;
      */devenv.nix)
        block "devenv.nix is admin-only. Ask admin." ;;
      */docker-compose*.yml|*/docker-compose*.yaml)
        block "Docker Compose files are admin-only. Ask admin." ;;
    esac
    ;;
esac

# Allow everything not explicitly blocked
exit 0
