function review-bugs --description "Review bugs across all repositories"
    echo "🐛 Bugs Across All Repositories"
    echo ""

    set -l repos (gh repo list --limit 100 --json nameWithOwner -q '.[].nameWithOwner')
    set -l found_any 0

    for repo in $repos
        set -l issues (gh issue list --repo $repo --label "type:bug" --state open --json number,title,labels,createdAt 2>/dev/null)

        if test -n "$issues"
            set count (echo $issues | jq '. | length')
            if test $count -gt 0
                set found_any 1
                echo "📦 $repo ($count bugs)"
                echo $issues | jq -r '.[] |
                    "  #\(.number): \(.title) " +
                    (if (.labels | map(.name) | contains(["priority:critical"])) then "🔴"
                     elif (.labels | map(.name) | contains(["priority:high"])) then "🟠"
                     else "🟡" end) +
                    " (\(.createdAt | split("T")[0]))"'
                echo ""
            end
        end
    end

    if test $found_any -eq 0
        echo "No bugs found. Report one with: bug <description>"
        return
    end

    echo "Next steps:"
    echo "  • View: gh issue view <number> --repo <owner/repo>"
    echo "  • Fix: fix-it <number> [owner/repo]"
end
