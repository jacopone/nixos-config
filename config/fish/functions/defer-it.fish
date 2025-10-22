function defer-it --description "Defer issue for later"
    if test (count $argv) -lt 1
        echo "Usage: defer-it <issue-number> [owner/repo]"
        return 1
    end

    set -l issue_num $argv[1]
    set -l repo_flag ""

    if test (count $argv) -ge 2
        set repo_flag "--repo $argv[2]"
    end

    gh issue edit $issue_num $repo_flag --add-label "status:deferred"
    gh issue close $issue_num $repo_flag --reason "not planned"

    echo "💤 Issue #$issue_num deferred"
    echo "Reopen anytime: gh issue reopen $issue_num $repo_flag"
end
