# Amatino project setup — auto-clones repos, sets env vars, initializes devenv venvs
# For business-profile machines (Pietro's workstation, etc.)
#
# What this does:
# 1. Sets $AMATINO_F24_DIR and $AMATINO_PLUGINS_DIR env vars
# 2. Clones amatino-f24-compilazione and amatino-plugins on first rebuild
# 3. Initializes the devenv venv (pip install) on first rebuild
# 4. Creates ~/.config/f24/config.toml template (if not present)
# 5. Enables the send-f24 and passaggio-contabile plugins (local paths)
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

    # Create config template if not present
    if [ ! -f "${configFile}" ]; then
      $DRY_RUN_CMD mkdir -p "${configDir}"
      $DRY_RUN_CMD cat > "${configFile}" << 'TOMLEOF'
${configTemplate}TOMLEOF
      $DRY_RUN_CMD chmod 600 "${configFile}"
      $VERBOSE_ECHO "Created F24 config template at ${configFile}"
    fi
  '';

  # Enable Amatino plugins via local paths in Claude Code settings
  home.activation.amatino-claude-plugins = lib.hm.dag.entryAfter [ "writeBoundary" "claude-settings-merge" ] ''
    SETTINGS="$HOME/.claude/settings.json"
    PLUGINS="${pluginsDir}"

    if [ -f "$SETTINGS" ]; then
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
        --arg plugins "$PLUGINS" \
        '
        .enabledPlugins[($plugins + "/send-f24")] = true |
        .enabledPlugins[($plugins + "/passaggio-contabile")] = true
      ' "$SETTINGS" > "''${SETTINGS}.tmp" \
      && mv "''${SETTINGS}.tmp" "$SETTINGS"
    fi
  '';
}
