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

**Step 7: Secrets Management with `agenix`.**
We have set up `agenix` to manage secrets in your NixOS configuration. Here's how you can use it.

**What is `agenix`?**

`agenix` is a tool that allows you to store secrets (like passwords and API keys) in your configuration repository in an encrypted format. The secrets are only decrypted when you build your NixOS system, which makes it safe to store them in a Git repository.

**Your Secrets File**

Your encrypted secrets are stored in the file `secrets.nix.age`. You should commit this file to your Git repository.

**Editing Secrets**

To edit your secrets, you need to decrypt the `secrets.nix.age` file, make your changes, and then re-encrypt it. `agenix` provides a simple command to do this:

1.  **Open the secrets file for editing:**
    ```bash
    agenix -e secrets.nix
    ```
    This command will decrypt `secrets.nix.age` into a temporary `secrets.nix` file and open it in your default editor.

2.  **Edit your secrets:**
    The `secrets.nix` file is a simple Nix attribute set. You can add, remove, or modify secrets here. For example:
    ```nix
    {
      "my_secret" = "this is a new secret";
      "another_secret" = "this is another secret";
    }
    ```

3.  **Save and close the editor:**
    When you save and close the editor, `agenix` will automatically re-encrypt the file to `secrets.nix.age` and delete the temporary unencrypted file.

**Using Secrets in Your Configuration**

You can use your secrets in your NixOS configuration by referencing them through the `config.age.secrets` attribute set. For example, to use the `my_secret` value in an environment variable:

```nix
environment.variables.MY_SECRET = config.age.secrets.my_secret.path;
```

When you rebuild your system, `agenix` will make the secret available at the specified path, and the environment variable `MY_SECRET` will be set to the content of the secret.

**IMPORTANT: Storing Your Private Key**

To be able to decrypt your secrets, you must store the `agenix` private key on your system. This key is **not** stored in the Git repository for security reasons.

You need to create the file `/etc/nixos/age.key` with the following content:

```
AGE-SECRET-KEY-1NFGZFXGJVNLKYLNLMZQYVVZE30EL2LXU7WV33RJVPQ05K45NYT2QQLTFY3
```

You can do this by running the following commands as the `root` user:

```bash
mkdir -p /etc/nixos
echo 'AGE-SECRET-KEY-1NFGZFXGJVNLKYLNLMZQYVVZE30EL2LXU7WV33RJVPQ05K45NYT2QQLTFY3' > /etc/nixos/age.key
chmod 600 /etc/nixos/age.key
```

**Without this file, your system will fail to build.**
