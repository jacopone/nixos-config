function fix-it --description "Start fixing a bug"
    if test (count $argv) -lt 1
        echo "Usage: fix-it <issue-number> [owner/repo]"
        return 1
    end

    set -l issue_num $argv[1]
    set -l repo_flag ""

    if test (count $argv) -ge 2
        set repo_flag "--repo $argv[2]"
    end

    # Create branch and start work (only works in current repo)
    if test -n "$repo_flag"
        echo "⚠️  Multi-repo bug fixing requires manual clone/checkout"
        echo "Run: gh issue view $issue_num $repo_flag"
    else
        gh issue develop $issue_num
    end

    echo "🔧 Ready to fix bug #$issue_num"
    echo "Claude Code can help with the implementation"
end
