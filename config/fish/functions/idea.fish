function idea --description "Capture feature idea in current repo"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "❌ Not in a git repository"
        return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: idea <description>"
        echo "Example: idea add dark mode toggle to settings"
        return 1
    end

    gh issue create \
        --title "💡 $argv" \
        --label "status:idea,type:feature" \
        --body "Quick capture during product use.

**Next steps**: Review with \`review-ideas\`, then decide:
- Complex → \`spec-it <number>\` → /spec-feature
- Simple → \`build-it <number>\` → /feature-dev

_Captured from: $(git rev-parse --show-toplevel)_"

    echo "✅ Idea captured in $(basename (git rev-parse --show-toplevel))"
end
