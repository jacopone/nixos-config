function review-ideas --description "Review ideas across all repositories"
    echo "💡 Ideas Across All Repositories"
    echo ""

    # Get all repos you have access to
    set -l repos (gh repo list --limit 100 --json nameWithOwner -q '.[].nameWithOwner')

    set -l found_any 0

    for repo in $repos
        set -l issues (gh issue list --repo $repo --label "status:idea" --json number,title,createdAt 2>/dev/null)

        if test -n "$issues"
            set count (echo $issues | jq '. | length')
            if test $count -gt 0
                set found_any 1
                echo "📦 $repo ($count ideas)"
                echo $issues | jq -r '.[] | "  #\(.number): \(.title) (\(.createdAt | split("T")[0]))"'
                echo ""
            end
        end
    end

    if test $found_any -eq 0
        echo "No ideas found. Capture one with: idea <description>"
        return
    end

    echo "Next steps:"
    echo "  • View details: gh issue view <number> --repo <owner/repo>"
    echo "  • Spec it: spec-it <number> [owner/repo]"
    echo "  • Build it: build-it <number> [owner/repo]"
    echo "  • Defer it: defer-it <number> [owner/repo]"
end
