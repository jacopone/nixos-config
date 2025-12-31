# VHS script demonstrating the closed-loop: rebuild → auto-update → AI knows
# Run with: vhs docs/assets/rebuild-demo.tape

Output docs/assets/rebuild-demo.gif
Set FontSize 16
Set Width 1000
Set Height 500
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set PlaybackSpeed 1.0

# Title frame
Type "# NixOS Self-Documenting AI Integration"
Enter
Sleep 1s
Type "clear"
Enter
Sleep 300ms

# Step 1: Show a tool in packages.nix
Type "# Step 1: Tool declared in packages.nix"
Enter
Sleep 500ms
Type "rg 'ripgrep' modules/core/packages.nix | head -3"
Enter
Sleep 2s

# Step 2: Run rebuild (abbreviated output)
Type ""
Enter
Type "# Step 2: Rebuild updates AI documentation"
Enter
Sleep 500ms
Type "./rebuild-nixos --dry-run 2>&1 | tail -10"
Enter
Sleep 3s

# Step 3: Show CLAUDE.md was updated
Type ""
Enter
Type "# Step 3: CLAUDE.md now includes tool info"
Enter
Sleep 500ms
Type "rg 'ripgrep' CLAUDE.md"
Enter
Sleep 2s

# Step 4: Show the closed loop concept
Type ""
Enter
Type "# The Closed Loop:"
Enter
Sleep 500ms
Type "echo 'packages.nix → rebuild → CLAUDE.md → AI knows'"
Enter
Sleep 3s

# Final message
Type ""
Enter
Type "# Zero manual documentation. Zero drift."
Enter
Sleep 2s
