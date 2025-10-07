function tracking-export --description "Export tracking data for baseline comparison"
    set -l logfile ~/.local/share/fish/command-source.jsonl
    set -l output_dir ~/nixos-config/docs/analysis/exports
    set -l timestamp (date +%Y-%m)

    if not test -f $logfile
        echo "❌ No tracking data found"
        return 1
    end

    mkdir -p $output_dir

    set -l export_file $output_dir/tracking-export-$timestamp.json

    echo "📤 Exporting tracking data..."
    echo ""

    # Generate summary statistics
    jq -s '{
        export_date: (now | todate),
        period: {
            start: (map(.ts) | min | todate),
            end: (map(.ts) | max | todate),
            total_commands: length
        },
        by_source: (group_by(.src) | map({
            source: .[0].src,
            count: length,
            percentage: ((length * 100 / ($total | tonumber)) | floor)
        })),
        by_confidence: {
            high_90_100: (map(select(.confidence >= 90)) | length),
            medium_70_89: (map(select(.confidence >= 70 and .confidence < 90)) | length),
            low_below_70: (map(select(.confidence < 70)) | length)
        },
        modern_tools: {
            glow: (map(select(.cmd | startswith("glow"))) | length),
            eza: (map(select(.cmd | startswith("eza"))) | length),
            bat: (map(select(.cmd | startswith("bat"))) | length),
            fd: (map(select(.cmd | startswith("fd"))) | length),
            rg: (map(select(.cmd | startswith("rg"))) | length),
            zoxide: (map(select(.cmd | startswith("z "))) | length),
            dust: (map(select(.cmd | startswith("dust"))) | length),
            procs: (map(select(.cmd | startswith("procs"))) | length),
            delta: (map(select(.cmd | contains("delta"))) | length),
            jless: (map(select(.cmd | startswith("jless"))) | length),
            yq: (map(select(.cmd | startswith("yq"))) | length)
        },
        traditional_tools: {
            ls: (map(select(.cmd | startswith("ls"))) | length),
            cat: (map(select(.cmd | startswith("cat"))) | length),
            find: (map(select(.cmd | startswith("find"))) | length),
            grep: (map(select(.cmd | contains("grep"))) | length),
            du: (map(select(.cmd | startswith("du"))) | length),
            ps: (map(select(.cmd | startswith("ps"))) | length)
        },
        human_vs_ai: {
            human_modern: (map(select(.src == "human" and (.cmd | test("^(glow|eza|bat|fd|rg|dust|procs|z )")))) | length),
            ai_modern: (map(select((.src == "claude-code" or .src == "likely-ai") and (.cmd | test("^(glow|eza|bat|fd|rg|dust|procs|z )")))) | length),
            human_traditional: (map(select(.src == "human" and (.cmd | test("^(ls|cat|find|grep|du|ps)")))) | length),
            ai_traditional: (map(select((.src == "claude-code" or .src == "likely-ai") and (.cmd | test("^(ls|cat|find|grep|du|ps)")))) | length)
        }
    }' --argjson total (wc -l < $logfile) $logfile > $export_file

    echo "✅ Export complete:"
    echo "   $export_file"
    echo ""
    echo "📊 Summary:"
    jq -r '
        "Period: \(.period.start) to \(.period.end)",
        "Total Commands: \(.period.total_commands)",
        "",
        "By Source:",
        (.by_source[] | "  \(.source): \(.count) (\(.percentage)%)"),
        "",
        "Modern Tool Usage:",
        "  glow: \(.modern_tools.glow)",
        "  eza: \(.modern_tools.eza)",
        "  bat: \(.modern_tools.bat)",
        "  zoxide: \(.modern_tools.zoxide)",
        "",
        "Human vs AI Modern Tools:",
        "  Human: \(.human_vs_ai.human_modern)",
        "  AI: \(.human_vs_ai.ai_modern)"
    ' $export_file

    echo ""
    echo "💡 Use this file for Oct 2026 comparison!"
end
