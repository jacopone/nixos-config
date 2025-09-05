# NixOS Configuration Migration Plan

This document outlines the plan to migrate the current NixOS configuration to a more structured and modular setup, inspired by the `zaneyos` configuration.

## Benefits of the New Structure

*   **Separation of Concerns:** Clear separation between machine-specific (`hosts`), user-specific (`users`), and reusable (`modules`) configurations.
*   **Modularity:** The configuration is broken down into smaller, more manageable files.
*   **Reusability:** Modules can be easily reused across different hosts and users.

## The Plan

### Phase 1: Restructuring Your Configuration

**Step 1: Create the new directory structure.**
Create the foundational directories for the new configuration:
```
/home/guyfawkes/nixos-config/
├── hosts/
│   └── nixos/
├── modules/
│   └── core/
└── users/
    └── guyfawkes/
```

**Step 2: Move your host-specific configuration.**
Move `configuration.nix` and `hardware-configuration.nix` to `hosts/nixos/` and update `flake.nix` to point to the new location.

**Step 3: Move your user-specific configuration.**
Move `home.nix` to `users/guyfawkes/` and update the main configuration to import it from its new location.

### Phase 2: Modularizing Your Configuration

**Step 4: Modularize your system packages.**
Create a dedicated module for system-wide packages (`modules/core/packages.nix`) and import it into the main configuration.

**Step 5: Modularize your Home Manager configuration.**
Begin breaking down `home.nix` into smaller, more focused modules (e.g., for shell, git, editor, etc.).

### Phase 3: Advanced Improvements

**Step 6: Introduce profiles.**
Create `profiles` to group modules for specific use cases (e.g., a `desktop` profile or a `development` profile).

**Step 7: Secrets Management.**
Implement a solution for managing secrets in the configuration, such as `agenix` or `sops-nix`.