# Tech profile configuration — extends base.nix with power-user tools and settings
# Used by: nixos (ThinkPad X1), framework-16
{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./base.nix
    ../../modules/core/packages.nix
    ../../modules/core/nix-ld.nix # nix-ld: run Playwright's downloaded chromium (gstack browse)
  ];

  # Environment
  environment.variables = {
    EDITOR = "hx";
  };

  # Raise RLIMIT_MEMLOCK (locked memory) for dev tooling. The systemd default of
  # 8 MiB is too small for io_uring-based tools: semgrep (eio/io_uring) fails
  # `io_uring_queue_init` with ENOMEM during the pre-commit `security-patterns`
  # hook, which otherwise forces `git commit --no-verify`. Set on BOTH managers
  # so user-session scopes (terminal apps under user@.service) inherit it too.
  # 1 GiB is a ceiling, not a reservation — a process only locks what it needs.
  systemd.settings.Manager.DefaultLimitMEMLOCK = 1073741824;
  systemd.user.settings.Manager.DefaultLimitMEMLOCK = 1073741824;

  # User account (tech profile includes input + adbusers groups)
  users.users.${username} = {
    isNormalUser = true;
    description = "Primary User";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "adbusers" "dialout" ];
    packages = with pkgs; [ ];
  };

  # SSH access (tech hosts only)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Packages
  nixpkgs.config.allowUnfree = true;

  # Chrome Extension Management (full tech set)
  programs.chromium = {
    enable = true;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "fjoaledfpmneenckfbpdfhkmimnjocfa" # NordVPN proxy
      "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
      "lodbfhdipoipcjmlebjbgmmgekckhpfb" # Harper (private grammar checker)
      "pbmlfaiicoikhdbjagjbglnbfcbcojpj" # Simplify Gmail
      "ohfgljdgelakfkefopgklcohadegdpjf" # Smallpdf
      "ipikiaejjblmdopojhpejjmbedhlibno" # SwiftRead
      "jjhefcfhmnkfeepcpnilbbkaadhngkbi" # Readwise Highlighter
      "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome (browser automation)
      "mmlmfjhmonkocbjadbfplnigmagldckm" # Playwright MCP Bridge (browser automation for Claude Code)
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
      "aghfnjkcakhmadgdomlmlhhaocbkloab" # Just Black (dark theme)
    ];
  };

  # State version should be set per-host (based on installation date)
}
