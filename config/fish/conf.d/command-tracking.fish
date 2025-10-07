# Command Source Tracking System
# Logs every command with source attribution (human, claude-code, scripts, etc.)
# Part of tool adoption baseline study - see ~/nixos-config/docs/analysis/

function __track_command_source --on-event fish_preexec
    # CRITICAL: Fail silently - NEVER break the shell
    begin
        set -l cmd $argv[1]
        set -l timestamp (date +%s)
        set -l logfile ~/.local/share/fish/command-source.jsonl
        set -l lockfile ~/.local/share/fish/command-source.lock

        # ============================================
        # SAFETY CHECK: Kill switch
        # ============================================
        # If tracking is disabled, exit immediately
        if test -f ~/.config/fish/disable-tracking
            return 0
        end

        # ============================================
        # SECRETS REDACTION
        # ============================================
        # Sanitize passwords, tokens, API keys from logs
        set cmd (string replace -ra '(-p\s+)\S+' '$1***' -- $cmd)
        set cmd (string replace -ra '(--password[=\s]+)\S+' '$1***' -- $cmd)
        set cmd (string replace -ra '(token|key|apikey|api_key|api-key)[=:]\s*\S+' '$1=***' -i -- $cmd)
        set cmd (string replace -ra '(password|passwd|pwd)[=:]\s*\S+' '$1=***' -i -- $cmd)
        set cmd (string replace -ra '(Bearer\s+)\S+' '$1***' -i -- $cmd)
        set cmd (string replace -ra '(Authorization:\s+)\S+' '$1***' -i -- $cmd)

        # ============================================
        # SOURCE DETECTION (Multi-layered)
        # ============================================
        set -l source "human"
        set -l confidence 60
        set -l detection_method "default"

        # Layer 1: Environment variables (highest confidence)
        if set -q CLAUDE_CODE_SESSION
            set source "claude-code"
            set confidence 100
            set detection_method "env-var"
        else if set -q GEMINI_CLI_SESSION
            set source "gemini-cli"
            set confidence 100
            set detection_method "env-var"
        else if set -q AIDER_SESSION
            set source "aider"
            set confidence 100
            set detection_method "env-var"
        else
            # Layer 2: Parent process detection (high confidence)
            set -l parent_comm (ps -o comm= -p $PPID 2>/dev/null)
            set -l parent_args (ps -o args= -p $PPID 2>/dev/null)

            if string match -q "*python*" $parent_comm
                # Check if it's a known Python tool
                if string match -q "*claude*" $parent_args
                    set source "claude-code"
                    set confidence 90
                    set detection_method "parent-process"
                else if string match -q "*gemini*" $parent_args
                    set source "gemini-cli"
                    set confidence 90
                    set detection_method "parent-process"
                else if string match -q "*aider*" $parent_args
                    set source "aider"
                    set confidence 90
                    set detection_method "parent-process"
                else
                    set source "python-script"
                    set confidence 85
                    set detection_method "parent-process"
                end
            else if string match -q "*bash*" $parent_comm
                set source "bash-script"
                set confidence 80
                set detection_method "parent-process"
            else if string match -q "*node*" $parent_comm
                set source "node-script"
                set confidence 85
                set detection_method "parent-process"
            else
                # Layer 3: Heuristic pattern matching (medium confidence)

                # AI-generated command patterns
                if string match -q "*<<'EOF'*" $cmd; or string match -q '*<<EOF*' $cmd
                    set source "likely-ai"
                    set confidence 85
                    set detection_method "heredoc-pattern"
                else if string match -q '*"$(cat <<*' $cmd
                    set source "likely-ai"
                    set confidence 90
                    set detection_method "nested-heredoc"
                # Complex pipes (4+ stages) often from AI
                else if test (string split "|" -- $cmd | count) -gt 3
                    set source "likely-ai"
                    set confidence 70
                    set detection_method "complex-pipe"
                # Known script paths
                else if string match -q "*/scripts/*" $cmd; or string match -q "*/.config/fish/functions/*" $cmd
                    set source "script"
                    set confidence 90
                    set detection_method "script-path"
                # VSCode/Cursor extension calls
                else if string match -q "*/.vscode/extensions/*" $cmd; or string match -q "*/.cursor/extensions/*" $cmd
                    set source "vscode"
                    set confidence 95
                    set detection_method "vscode-path"
                # Human exploration patterns
                else if string match -q "*--help*" $cmd; or string match -q "*-h" $cmd; or string match -q "help" $cmd
                    set source "human"
                    set confidence 80
                    set detection_method "help-flag"
                # Typos are human
                else if string match -q "git statuss" $cmd; or string match -q "nix-channel --liste" $cmd
                    set source "human"
                    set confidence 95
                    set detection_method "typo"
                end
            end
        end

        # ============================================
        # ADDITIONAL CONTEXT
        # ============================================
        set -l pwd_short (string replace $HOME '~' (pwd))
        set -l shell_level $SHLVL

        # ============================================
        # BUILD JSON (safely)
        # ============================================
        # Use jq to guarantee valid JSON escaping
        set -l json (jq -n \
            --arg ts "$timestamp" \
            --arg cmd "$cmd" \
            --arg src "$source" \
            --arg conf "$confidence" \
            --arg method "$detection_method" \
            --arg pwd "$pwd_short" \
            --arg ppid "$PPID" \
            --arg shlvl "$shell_level" \
            '{
                ts: ($ts|tonumber),
                cmd: $cmd,
                src: $src,
                confidence: ($conf|tonumber),
                method: $method,
                pwd: $pwd,
                ppid: ($ppid|tonumber),
                shlvl: ($shlvl|tonumber)
            }' 2>/dev/null)

        # Fallback if jq fails (basic JSON escaping)
        if test -z "$json"
            set -l cmd_escaped (string replace -ra '"' '\\"' -- $cmd)
            set json "{\"ts\":$timestamp,\"cmd\":\"$cmd_escaped\",\"src\":\"$source\",\"confidence\":$confidence}"
        end

        # ============================================
        # ATOMIC WRITE (with timeout)
        # ============================================
        # Simplified: Direct write with flock (fast enough not to block)
        # Use timeout to prevent hanging if lockfile is stuck
        begin
            timeout 1s flock $lockfile sh -c "echo '$json' >> $logfile" 2>/dev/null
        end; or true  # Fail silently if timeout or flock fails

        # ============================================
        # LOG ROTATION (async)
        # ============================================
        # Check file size and rotate if > 10MB
        if test -f $logfile
            set -l filesize (stat -c%s $logfile 2>/dev/null; or stat -f%z $logfile 2>/dev/null; or echo 0)
            if test $filesize -gt 10485760  # 10MB
                # Rotate in background, don't block
                fish -c "
                    begin
                        set -l archive $logfile.(date +%Y%m)
                        mv '$logfile' \$archive 2>/dev/null
                        gzip \$archive 2>/dev/null
                    end
                " &
                disown
            end
        end

    end 2>/dev/null; or true  # CRITICAL: Always succeed, never break shell
end

# Helper function: Disable tracking temporarily
function tracking-disable --description "Disable command tracking (creates kill switch)"
    touch ~/.config/fish/disable-tracking
    echo "✅ Command tracking disabled"
    echo "   Re-enable with: tracking-enable"
end

# Helper function: Enable tracking
function tracking-enable --description "Enable command tracking (removes kill switch)"
    rm -f ~/.config/fish/disable-tracking
    echo "✅ Command tracking enabled"
    echo "   Logs to: ~/.local/share/fish/command-source.jsonl"
end

# Helper function: View tracking status
function tracking-status --description "Show command tracking status and stats"
    echo "=== Command Tracking Status ==="

    if test -f ~/.config/fish/disable-tracking
        echo "Status: ❌ DISABLED"
        echo "Enable with: tracking-enable"
        return
    else
        echo "Status: ✅ ENABLED"
    end

    set -l logfile ~/.local/share/fish/command-source.jsonl

    if test -f $logfile
        set -l size (stat -c%s $logfile 2>/dev/null; or stat -f%z $logfile 2>/dev/null; or echo 0)
        set -l count (wc -l < $logfile)
        set -l size_mb (math "$size / 1048576")

        echo ""
        echo "Log file: $logfile"
        echo "Commands tracked: $count"
        echo "File size: $size_mb MB"

        echo ""
        echo "Recent sources (last 100 commands):"
        tail -100 $logfile | jq -r '.src' | sort | uniq -c | sort -rn
    else
        echo ""
        echo "No tracking data yet"
        echo "Log will be created at: $logfile"
    end
end
