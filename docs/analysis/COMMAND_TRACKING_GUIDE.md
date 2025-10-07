# Command Source Tracking System - User Guide

**Status**: ✅ Installed and Active
**Location**: `~/.config/fish/conf.d/command-tracking.fish`
**Log File**: `~/.local/share/fish/command-source.jsonl`
**Purpose**: Track who/what runs commands (human, Claude Code, scripts) for tool adoption analysis

---

## Quick Start

The tracking system is already installed and active. It automatically logs every command you run with source attribution.

### Check Status

```bash
tracking-status
```

Shows:
- Is tracking enabled?
- How many commands logged
- Recent command sources

### View Analysis

```bash
tracking-analyze
```

Shows comprehensive breakdown:
- Commands by source (human vs AI vs scripts)
- Detection confidence levels
- Top commands per source
- Modern tool usage by source
- Time-based patterns

### Export for Comparison

```bash
tracking-export
```

Creates timestamped export in `~/nixos-config/docs/analysis/exports/` for baseline comparison.

---

## How It Works

### Source Detection (Multi-Layered)

**Layer 1: Environment Variables** (100% confidence)
- `CLAUDE_CODE_SESSION=1` → claude-code
- `GEMINI_CLI_SESSION=1` → gemini-cli
- `AIDER_SESSION=1` → aider

**Layer 2: Parent Process Detection** (80-90% confidence)
- Parent is Python → checks args for `claude`, `gemini`, `aider`
- Parent is bash → bash-script
- Parent is node → node-script

**Layer 3: Heuristic Pattern Matching** (60-90% confidence)
- Contains `<<EOF` → likely-ai (85%)
- 4+ pipe stages → likely-ai (70%)
- Path contains `/scripts/` → script (90%)
- Contains `--help` → human (80%)
- Contains typos → human (95%)

### What Gets Logged

Each command creates a JSON entry:
```json
{
  "ts": 1759851136,
  "cmd": "glow README.md",
  "src": "human",
  "confidence": 80,
  "method": "help-flag",
  "pwd": "~/nixos-config",
  "ppid": 12345,
  "shlvl": 2
}
```

Fields:
- `ts`: Unix timestamp
- `cmd`: Command (with secrets redacted)
- `src`: Source (human, claude-code, likely-ai, script, etc.)
- `confidence`: Detection confidence (0-100)
- `method`: How source was detected
- `pwd`: Working directory
- `ppid`: Parent process ID
- `shlvl`: Shell nesting level

---

## Safety Features

### 1. Secrets Redaction

Automatically redacts:
- Passwords: `-p password` → `-p ***`
- API keys: `API_KEY=secret` → `API_KEY=***`
- Tokens: `Bearer token` → `Bearer ***`
- Auth headers: `Authorization: xxx` → `Authorization: ***`

### 2. Never Breaks Shell

- All errors suppressed (fails silently)
- Timeout protection (max 1s for write)
- Always returns success code
- Never blocks command execution

### 3. Disk Space Management

- Auto-rotates when log > 10MB
- Compresses rotated logs with gzip
- Archives to `command-source.jsonl.YYYYMM.gz`

### 4. Kill Switch

Instantly disable tracking:
```bash
tracking-disable
```

Re-enable:
```bash
tracking-enable
```

### 5. Atomic Writes

- Uses `flock` for concurrent-safe writes
- Multiple shells can log simultaneously
- No corruption from race conditions

---

## Common Use Cases

### 1. "Who used modern tools more - me or Claude?"

```bash
tracking-analyze
```

Look at the "Modern Tool Usage by Source" section.

### 2. "What commands does Claude Code actually run?"

```bash
jq 'select(.src=="claude-code" or .src=="likely-ai") | .cmd' \
  ~/.local/share/fish/command-source.jsonl | head -20
```

### 3. "Review low-confidence detections"

```bash
jq 'select(.confidence < 70)' ~/.local/share/fish/command-source.jsonl | less
```

### 4. "What did I do yesterday?"

```bash
# Calculate yesterday's timestamps
set yesterday_start (date -d "yesterday 00:00" +%s)
set yesterday_end (date -d "yesterday 23:59" +%s)

jq --argjson start $yesterday_start --argjson end $yesterday_end \
  'select(.ts >= $start and .ts <= $end)' \
  ~/.local/share/fish/command-source.jsonl
```

### 5. "Compare modern vs traditional tools"

```bash
echo "=== eza vs ls ==="
echo "eza: $(jq -r 'select(.cmd | startswith("eza"))' ~/.local/share/fish/command-source.jsonl | wc -l)"
echo "ls:  $(jq -r 'select(.cmd | startswith("ls "))' ~/.local/share/fish/command-source.jsonl | wc -l)"

echo ""
echo "=== bat vs cat ==="
echo "bat: $(jq -r 'select(.cmd | startswith("bat"))' ~/.local/share/fish/command-source.jsonl | wc -l)"
echo "cat: $(jq -r 'select(.cmd | startswith("cat "))' ~/.local/share/fish/command-source.jsonl | wc -l)"
```

---

## Troubleshooting

### Issue: No commands being logged

**Check 1**: Is tracking enabled?
```bash
tracking-status
```

**Check 2**: Is log file writable?
```bash
touch ~/.local/share/fish/command-source.jsonl
```

**Check 3**: Are you in a Fish shell?
```bash
echo $SHELL
# Should show: /run/current-system/sw/bin/fish
```

**Check 4**: Is the hook loaded?
```bash
functions --query __track_command_source && echo "✅ Hook loaded" || echo "❌ Hook missing"
```

**Fix**: Reload Fish config
```bash
exec fish
```

### Issue: Commands logged but all show "human"

This is normal! Most commands ARE human. To test AI detection:

```bash
# Run a command with AI patterns
grep foo | sed s/a/b/ | awk '{print}' | sort | uniq

# Then check:
jq 'select(.src=="likely-ai") | .cmd' ~/.local/share/fish/command-source.jsonl | tail -1
```

### Issue: Disk space growing

**Check size**:
```bash
du -h ~/.local/share/fish/command-source.jsonl*
```

**Manual cleanup**:
```bash
# Keep only last month
rm ~/.local/share/fish/command-source.jsonl.202[0-4]*
```

**Adjust auto-rotation threshold**:
Edit `~/.config/fish/conf.d/command-tracking.fish`, line ~175:
```fish
if test $filesize -gt 10485760  # Change this (10MB default)
```

### Issue: Slow shell performance

**Test overhead**:
```bash
hyperfine "echo test"
# Should be < 50ms
```

**If > 100ms**:
1. Check if disk is slow (HDD, network mount)
2. Temporarily disable: `tracking-disable`
3. Move log to local disk: `/tmp/command-source.jsonl`

### Issue: Secrets not redacted

**Check what's logged**:
```bash
jq -r '.cmd' ~/.local/share/fish/command-source.jsonl | grep -i "password\|token\|key"
```

**Add custom pattern**:
Edit `~/.config/fish/conf.d/command-tracking.fish`, add to redaction section (~line 23):
```fish
set cmd (string replace -ra '(YOUR_PATTERN)\S+' '$1***' -- $cmd)
```

---

## Performance Impact

**Measured overhead per command**: ~10-30ms

Breakdown:
- Parent process detection: ~5ms
- JSON generation: ~5ms
- File write with flock: ~10-20ms

**Negligible for human typing** (commands take seconds anyway).

**May be noticeable** if running 100+ commands/second in a loop.

**Solution for high-frequency scripts**:
```bash
# Disable tracking just for this script
tracking-disable
./high-frequency-script.sh
tracking-enable
```

---

## Privacy & Security

### What's Logged

✅ Safe to log:
- Command names (ls, git, cat)
- Flags (--help, -la)
- File paths (public)
- Source attribution

❌ Automatically redacted:
- Passwords
- API keys
- Tokens
- Auth headers

### What's NOT Logged

- Command output
- File contents
- Network traffic
- Environment variables (except detection markers)

### Log Location

`~/.local/share/fish/command-source.jsonl` is:
- ✅ Local (never sent anywhere)
- ✅ User-only readable (chmod 600)
- ✅ Not in git (in .gitignore)
- ⚠️ Not encrypted (file system level security)

---

## Integration with Tool Adoption Study

This tracking system feeds into the tool adoption baseline study:

**Oct 2025 Baseline**: Established using historical Fish history (2,590 commands, no source attribution)

**Oct 2026 Review**: Will use this tracking data (with source attribution) to answer:
- Did humans adopt modern tools?
- Did Claude Code adopt modern tools?
- Which source uses which tools more?
- Are AI recommendations followed by humans?

**Export for comparison**:
```bash
tracking-export
# Creates: ~/nixos-config/docs/analysis/exports/tracking-export-YYYY-MM.json
```

---

## Advanced Usage

### Custom Queries

**Find all commands in a specific directory**:
```bash
jq 'select(.pwd | startswith("~/nixos-config"))' \
  ~/.local/share/fish/command-source.jsonl
```

**Group by hour of day**:
```bash
jq -r '.ts' ~/.local/share/fish/command-source.jsonl | \
  while read ts; date -d @$ts +%H; end | \
  sort | uniq -c
```

**Most common commands by AI**:
```bash
jq -r 'select(.src=="claude-code" or .src=="likely-ai") | .cmd' \
  ~/.local/share/fish/command-source.jsonl | \
  awk '{print $1}' | sort | uniq -c | sort -rn | head -20
```

**Confidence score distribution**:
```bash
jq -r '.confidence' ~/.local/share/fish/command-source.jsonl | \
  awk '{
    if ($1 >= 90) high++
    else if ($1 >= 70) med++
    else low++
  }
  END {
    print "High (90-100):", high
    print "Med (70-89):", med
    print "Low (<70):", low
  }'
```

### Create Monthly Reports

```bash
# Create a Fish function for monthly reports
function monthly-report
    set -l month (date +%Y-%m)
    set -l report ~/nixos-config/docs/analysis/monthly-report-$month.md

    echo "# Command Tracking Report - $month" > $report
    echo "" >> $report

    echo "## Summary" >> $report
    tracking-analyze >> $report

    echo "" >> $report
    echo "## Export Data" >> $report
    tracking-export >> $report

    echo "✅ Report created: $report"
    glow -p $report
end
```

---

## Maintenance

### Weekly

```bash
# Check log size
tracking-status
```

### Monthly

```bash
# Export for baseline
tracking-export

# Optional: Archive old logs
cd ~/.local/share/fish
tar -czf archive-$(date +%Y%m).tar.gz command-source.jsonl.*.gz
rm command-source.jsonl.*.gz
```

### Yearly (October 2026)

```bash
# Compare with baseline
cd ~/nixos-config/docs/analysis
# Follow instructions in tool-adoption-baseline-2025-10.md
```

---

## Uninstalling

If you want to remove the tracking system:

```bash
# 1. Disable tracking
tracking-disable

# 2. Remove Fish config
rm ~/.config/fish/conf.d/command-tracking.fish
rm ~/.config/fish/functions/tracking-*.fish

# 3. (Optional) Remove logs
rm ~/.local/share/fish/command-source.jsonl*

# 4. Reload shell
exec fish
```

---

## Support & Feedback

This is a custom tool built for the tool adoption baseline study.

**Issues?**
1. Check this guide's Troubleshooting section
2. Review the code: `~/.config/fish/conf.d/command-tracking.fish`
3. Test manually: `__track_command_source "test"`

**Enhancement ideas?**
Edit the tracking function to add:
- New source detection patterns
- Additional context fields
- Custom analysis queries

---

**Last Updated**: 2025-10-07
**Next Review**: 2026-10 (with tool adoption baseline comparison)
