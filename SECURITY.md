---
status: active
created: 2025-12-18
updated: 2025-12-18
type: reference
lifecycle: persistent
---

# Security Policy

## Supported Versions

This is a personal NixOS configuration. Security updates are applied via:
- NixOS unstable channel (rolling updates)
- Weekly `nix flake update` via automated maintenance

| Component | Version | Supported |
|-----------|---------|-----------|
| NixOS | 25.11 (unstable) | Yes |
| Flake inputs | Latest | Yes |

## Reporting a Vulnerability

If you discover a security issue in this configuration:

1. **Do not open a public issue** for security vulnerabilities
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 1 week
- **Fix (if applicable)**: Depends on severity

## Security Considerations

### What This Repository Contains

- NixOS system configuration (declarative, reproducible)
- Home Manager user configuration
- Fish shell aliases and abbreviations
- Development environment setup

### What This Repository Does NOT Contain

- Secrets, passwords, or API keys
- SSH keys or certificates
- Personal data or credentials

### Security Best Practices Used

1. **No hardcoded secrets** - All sensitive data via environment variables or external secret managers
2. **Declarative configuration** - Full system state tracked in git
3. **Reproducible builds** - Nix ensures build reproducibility
4. **Minimal attack surface** - Only necessary packages installed
5. **Regular updates** - Automated weekly flake updates

## Dependency Security

Dependencies are managed through Nix flakes with locked versions in `flake.lock`. Security updates are applied via:

```bash
nix flake update  # Updates all inputs
./rebuild-nixos   # Applies changes with safety checks
```

## Contact

- GitHub Issues: For non-security bugs and feature requests
- Private: Use GitHub's security advisory feature for vulnerabilities
