# Amatino project setup — auto-clones repos, sets env vars, initializes devenv venvs
# For business-profile machines (Pietro's workstation, etc.)
#
# What this does:
# 1. Sets $AMATINO_F24_DIR and $AMATINO_PLUGINS_DIR env vars
# 2. Clones amatino-f24-compilazione and amatino-plugins on first rebuild
# 3. Initializes the devenv venv (pip install) on first rebuild
# 4. Creates ~/.config/f24/config.toml template (if not present)
# 5. Registers amatino-plugins marketplace + installs send-f24 and passaggio-contabile
{ config, pkgs, lib, ... }:

let
  amatinoDir = "${config.home.homeDirectory}/amatino";
  f24Dir = "${amatinoDir}/amatino-f24-compilazione";
  pluginsDir = "${amatinoDir}/amatino-plugins";
  configDir = "${config.home.homeDirectory}/.config/f24";
  configFile = "${configDir}/config.toml";

  configTemplate = ''
    # F24 Entratel Pipeline Configuration
    # Fill in your credentials below.
    # This file was auto-created by NixOS — fill in and run: chmod 600 ~/.config/f24/config.toml

    [intermediario]
    codice_fiscale = ""
    tipo = "04"
    cognome = ""
    nome = ""
    sesso = ""
    data_nascita = ""
    comune_nascita = ""
    provincia_nascita = ""

    [security]
    utef_p12_path = ""
    utec_p12_path = ""
    password = ""

    [credentials]
    codice_utente = ""
    password = ""
    pin = ""

    [pipeline]
    java_path = "java"
    control_module_jar = ""
    entratel_cli_dir = "lib/desktop_telematico"
    entratel_multifile_dir = "lib/entratel_multifile"
  '';
in
{
  # Environment variables — available in all shells and to Claude Code
  home.sessionVariables = {
    AMATINO_F24_DIR = f24Dir;
    AMATINO_PLUGINS_DIR = pluginsDir;
  };

  # Clone repos + initialize venv + create config template on rebuild
  home.activation.amatino-setup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Guard: GitHub auth required for private AmatinoTeam repos
    if ! ${pkgs.gh}/bin/gh auth status &>/dev/null; then
      echo ""
      echo "╔══════════════════════════════════════════════════════════════╗"
      echo "║  Amatino repos require GitHub auth. Run:                    ║"
      echo "║                                                             ║"
      echo "║    gh auth login                                            ║"
      echo "║                                                             ║"
      echo "║  Then rebuild. Skipping repo clone + venv setup.            ║"
      echo "╚══════════════════════════════════════════════════════════════╝"
      echo ""
    else
      # Clone f24 engine if not present
      if [ ! -d "${f24Dir}" ]; then
        $DRY_RUN_CMD mkdir -p "${amatinoDir}"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
          https://github.com/AmatinoTeam/amatino-f24-compilazione.git \
          "${f24Dir}"
        $VERBOSE_ECHO "Cloned amatino-f24-compilazione"
      fi

      # Clone plugins repo if not present
      if [ ! -d "${pluginsDir}" ]; then
        $DRY_RUN_CMD mkdir -p "${amatinoDir}"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
          https://github.com/AmatinoTeam/amatino-plugins.git \
          "${pluginsDir}"
        $VERBOSE_ECHO "Cloned amatino-plugins"
      fi

      # Initialize devenv venv if not present
      if [ ! -d "${f24Dir}/.venv" ]; then
        $DRY_RUN_CMD ${pkgs.python313}/bin/python -m venv "${f24Dir}/.venv"
        $DRY_RUN_CMD "${f24Dir}/.venv/bin/pip" install --quiet \
          -r "${f24Dir}/requirements.txt"
        $VERBOSE_ECHO "Initialized F24 Python venv"
      fi
    fi

    # Create config template if not present (no GitHub auth needed)
    if [ ! -f "${configFile}" ]; then
      $DRY_RUN_CMD mkdir -p "${configDir}"
      $DRY_RUN_CMD cat > "${configFile}" << 'TOMLEOF'
${configTemplate}TOMLEOF
      $DRY_RUN_CMD chmod 600 "${configFile}"
      $VERBOSE_ECHO "Created F24 config template at ${configFile}"
    fi
  '';

  # Register Amatino marketplace + install plugins via Claude Code CLI
  # Runs after repos are cloned (amatino-setup) and settings exist (claude-settings-merge)
  home.activation.amatino-claude-plugins = lib.hm.dag.entryAfter [ "writeBoundary" "amatino-setup" "claude-settings-merge" ] ''
    PLUGINS="${pluginsDir}"

    if [ ! -d "$PLUGINS/.claude-plugin" ]; then
      $VERBOSE_ECHO "Amatino plugins repo not cloned yet — skipping plugin registration"
    elif ! command -v claude &>/dev/null; then
      $VERBOSE_ECHO "Claude Code CLI not in PATH — skipping plugin registration"
    else
      # Register marketplace (idempotent — skips if already added)
      if ! claude plugin marketplace list 2>/dev/null | grep -q "amatino-plugins"; then
        $DRY_RUN_CMD claude plugin marketplace add "$PLUGINS" --scope user
        $VERBOSE_ECHO "Registered amatino-plugins marketplace"
      fi

      # Install plugins (idempotent — skips if already installed)
      for plugin in send-f24 passaggio-contabile; do
        if ! claude plugin list 2>/dev/null | grep -q "$plugin@amatino-plugins"; then
          $DRY_RUN_CMD claude plugin install "$plugin@amatino-plugins" --scope user
          $VERBOSE_ECHO "Installed $plugin"
        fi
      done
    fi
  '';
}
