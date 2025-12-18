---
status: active
created: 2025-12-18
updated: 2025-12-18
type: guide
lifecycle: persistent
---

# Contributing

This is a personal NixOS configuration shared for learning and inspiration. Here's how you can engage with the project.

## Best Ways to Contribute

### Fork and Adapt

The recommended approach is to **fork this repository** and adapt it for your own setup:

1. Fork via GitHub
2. Clone your fork
3. Customize for your hardware and preferences
4. Share your improvements with the community

### Share Your Setup

Built something interesting based on this config? Open a [Discussion](https://github.com/jacopone/nixos-config/discussions) to share it.

### Report Issues

Found a bug or broken link? [Open an issue](https://github.com/jacopone/nixos-config/issues) with:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Your NixOS version (`nixos-version`)

### Suggest Improvements

Have an idea? Open a [Discussion](https://github.com/jacopone/nixos-config/discussions) first to discuss before submitting a PR.

## Pull Requests

PRs are welcome for:
- Documentation fixes
- Typo corrections
- Link updates
- Generic improvements that benefit all users

PRs that are **less likely** to be merged:
- Personal preferences (different editor, different shell)
- Hardware-specific changes
- Opinionated tool choices

## Code Style

### Nix Files

- Follow existing formatting conventions
- Use descriptive attribute names
- Group related packages logically
- Include URLs for package references when helpful

```nix
# Good
environment.systemPackages = with pkgs; [
  fd           # Modern find replacement - https://github.com/sharkdp/fd
  ripgrep      # Ultra-fast grep - https://github.com/BurntSushi/ripgrep
];

# Avoid
environment.systemPackages = with pkgs; [fd ripgrep bat eza];  # No descriptions
```

### Documentation

- Use YAML frontmatter with status tracking
- No temporal markers ("NEW", "Phase 2", dates in headings)
- Factual language, avoid marketing speak
- Present tense for current behavior
- Imperative mood for instructions

## Questions?

- **General questions**: [Discussions](https://github.com/jacopone/nixos-config/discussions)
- **Bug reports**: [Issues](https://github.com/jacopone/nixos-config/issues)
- **NixOS help**: [NixOS Discourse](https://discourse.nixos.org/)

## Recognition

Contributors are recognized in release notes and the README acknowledgments section.

Thanks for your interest in improving this project.
