# VHS script to demonstrate rebuild-nixos updating Claude Code configurations
# Run with: vhs docs/assets/rebuild-demo.tape

# Output configuration
Output docs/assets/rebuild-demo.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 50ms
Set PlaybackSpeed 0.5

# Show the nixos-config directory
Type "cd ~/nixos-config"
Enter
Sleep 500ms

# Clear screen for clean demo
Type "clear"
Enter
Sleep 500ms

# Show the rebuild command with explanation
Type "# Every rebuild updates Claude's knowledge automatically"
Sleep 1s
Enter
Type "./rebuild-nixos"
Sleep 2s
Enter

# Wait for the update to happen (simulate)
Sleep 3s
Type "# Simulating rebuild process..."
Enter
Sleep 2s

# Show the key part where Claude configs get updated
Type "echo '--> Updating Claude Code configurations...'"
Enter
Sleep 500ms
Type "echo '    ✅ Claude Code configurations updated'"
Enter
Type "echo '       - User policies: ~/.claude/CLAUDE-USER-POLICIES.md (preserved)'"
Enter
Type "echo '       - System CLAUDE.md: ~/.claude/CLAUDE.md (updated)'"
Enter
Type "echo '       - Project CLAUDE.md: ./CLAUDE.md (updated)'"
Enter
Sleep 2s

# Show that CLAUDE.md was updated
Type "clear"
Enter
Sleep 500ms
Type "# Check what was updated"
Sleep 1s
Enter
Type "head -20 CLAUDE.md"
Enter
Sleep 2s

# Show the closing loop concept
Type "clear"
Enter
Sleep 500ms
Type "echo 'System state → rebuild → auto-documentation → AI knowledge'"
Enter
Sleep 2s
Type "echo 'The closed loop keeps Claude Code always in sync'"
Enter
Sleep 3s
