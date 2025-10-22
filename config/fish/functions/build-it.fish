function build-it --description "Mark issue as ready to build"
    if test (count $argv) -lt 1
        echo "Usage: build-it <issue-number> [owner/repo]"
        return 1
    end

    set -l issue_num $argv[1]
    set -l repo_flag ""

    if test (count $argv) -ge 2
        set repo_flag "--repo $argv[2]"
    end

    gh issue edit $issue_num $repo_flag \
        --remove-label "status:idea" \
        --add-label "status:ready"

    echo "✅ Issue #$issue_num ready to build"
    echo "Next: View with 'gh issue view $issue_num $repo_flag'"
    echo "      Then run /feature-dev:feature-dev in Claude Code"
end
