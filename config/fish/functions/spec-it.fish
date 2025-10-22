function spec-it --description "Mark issue as needing specification"
    if test (count $argv) -lt 1
        echo "Usage: spec-it <issue-number> [owner/repo]"
        echo "If in a git repo, owner/repo is auto-detected"
        return 1
    end

    set -l issue_num $argv[1]
    set -l repo_flag ""

    if test (count $argv) -ge 2
        set repo_flag "--repo $argv[2]"
    end

    gh issue edit $issue_num $repo_flag \
        --remove-label "status:idea" \
        --add-label "status:needs-spec"

    echo "✅ Issue #$issue_num marked for specification"
    echo "Next: View with 'gh issue view $issue_num $repo_flag'"
    echo "      Then run /spec-feature in Claude Code"
end
