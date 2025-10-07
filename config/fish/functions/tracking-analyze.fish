function tracking-analyze --description "Analyze command tracking data"
    set -l logfile ~/.local/share/fish/command-source.jsonl

    if not test -f $logfile
        echo "❌ No tracking data found at: $logfile"
        echo "Run some commands first, then try again"
        return 1
    end

    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          Command Source Tracking Analysis Report               ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    # Total commands
    set -l total (wc -l < $logfile)
    echo "📊 Total Commands Tracked: $total"
    echo ""

    # Commands by source
    echo "═══ Commands by Source ═══"
    jq -r '.src' $logfile | sort | uniq -c | sort -rn | while read count source
        set -l percentage (math "scale=1; $count * 100 / $total")
        printf "  %-20s %6d commands (%5.1f%%)\n" $source $count $percentage
    end
    echo ""

    # Confidence distribution
    echo "═══ Detection Confidence ═══"
    jq -r '.confidence' $logfile | awk '
        $1 >= 90 { high++ }
        $1 >= 70 && $1 < 90 { med++ }
        $1 < 70 { low++ }
        END {
            printf "  High (90-100): %d\n", high
            printf "  Medium (70-89): %d\n", med
            printf "  Low (<70): %d\n", low
        }
    '
    echo ""

    # Detection methods
    echo "═══ Detection Methods ═══"
    jq -r '.method' $logfile | sort | uniq -c | sort -rn | while read count method
        printf "  %-25s %d\n" $method $count
    end
    echo ""

    # Most used commands by source
    echo "═══ Top Commands by Source ═══"
    for source in human claude-code likely-ai script
        set -l source_total (jq -r "select(.src==\"$source\") | .cmd" $logfile 2>/dev/null | wc -l)
        if test $source_total -gt 0
            echo ""
            echo "  $source ($source_total total):"
            jq -r "select(.src==\"$source\") | .cmd" $logfile | \
                awk '{print $1}' | \
                sort | uniq -c | sort -rn | head -5 | \
                while read count cmd
                    printf "    %-20s %d\n" $cmd $count
                end
        end
    end
    echo ""

    # Modern tool usage by source
    echo "═══ Modern Tool Usage by Source ═══"
    set -l modern_tools glow eza bat fd rg dust procs delta jless yq zoxide

    for tool in $modern_tools
        set -l human_count (jq -r "select(.src==\"human\" and (.cmd | startswith(\"$tool\"))) | .cmd" $logfile 2>/dev/null | wc -l)
        set -l ai_count (jq -r "select(.src==\"claude-code\" or .src==\"likely-ai\") and (.cmd | startswith(\"$tool\")) | .cmd" $logfile 2>/dev/null | wc -l)

        if test (math "$human_count + $ai_count") -gt 0
            printf "  %-15s Human: %3d  AI: %3d\n" $tool $human_count $ai_count
        end
    end
    echo ""

    # Time-based analysis
    echo "═══ Commands by Hour ═══"
    jq -r '.ts' $logfile | while read ts
        date -d @$ts +%H 2>/dev/null; or date -r $ts +%H 2>/dev/null
    end | sort | uniq -c | sort -k2n | while read count hour
        set -l bar (string repeat -n (math "$count / 5") "█")
        printf "  %02d:00 %s %d\n" $hour "$bar" $count
    end
    echo ""

    echo "💡 Tip: For detailed queries, use:"
    echo "   jq 'select(.src==\"human\")' $logfile | less"
    echo "   jq 'select(.confidence < 70)' $logfile  # Review low-confidence detections"
    echo ""
end
