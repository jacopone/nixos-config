function bug --description "Log bug in current repo"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "❌ Not in a git repository"
        return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: bug <description>"
        echo "Example: bug settings page crashes on mobile"
        return 1
    end

    gh issue create \
        --title "🐛 $argv" \
        --label "type:bug,priority:medium" \
        --body "Bug discovered during use.

**To reproduce**: (add steps here)

**Expected**: (what should happen)
**Actual**: (what actually happens)

**Next steps**: Review with \`review-bugs\`, prioritize, then fix.

_Captured from: $(git rev-parse --show-toplevel)_"

    echo "✅ Bug logged in $(basename (git rev-parse --show-toplevel))"
end
