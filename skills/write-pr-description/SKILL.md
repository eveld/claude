---
name: write-pr-description
description: Use when creating pull requests to write clear, structured PR descriptions that help reviewers understand changes.
---

# Write PR Description

Create structured pull request descriptions that provide context for reviewers.

## Template

See `templates/pr-description.md` for the full template structure.

## Sections

### Summary
- 1-2 sentences explaining the PR at a high level
- What is being added/fixed/changed
- Why it matters

### What Changed
- Bullet list of specific changes
- Focus on "what" not "how"
- Group related changes together

### Why
- Business context or technical motivation
- Problem being solved
- Why this approach was chosen

### Screenshots (if applicable)
- Before/after comparisons for UI changes
- Error states
- Different screen sizes/browsers

### Related Issues
- Link to tickets: `Closes #123`
- Link to related PRs: `Refs #456`
- Link to documentation

## Example

```markdown
## Summary
Adds JWT token refresh mechanism to prevent unexpected session expiration. Tokens are automatically refreshed 5 minutes before expiry.

## What Changed
- Added token refresh endpoint `/api/auth/refresh`
- Implemented automatic refresh timer in auth middleware
- Added token expiry checking logic
- Updated auth context to handle refresh flow
- Added tests for refresh scenarios

## Why
Users were experiencing unexpected logouts when their sessions expired during active use. This caused data loss and poor UX. Automatic token refresh keeps sessions alive as long as users are active.

## Related Issues
Closes #123
```

## Integration with Git Workflow

When user asks to create PR or you're following git workflow:

1. Review all commits in the branch
2. Read git diff to understand full scope of changes
3. Draft PR description following structure
4. Use `gh pr create` with body in heredoc:

```bash
gh pr create --title "feat(auth): add JWT token refresh" --body "$(cat <<'EOF'
## Summary
...

## What Changed
...
EOF
)"
```

## Benefits

- Reviewers understand context quickly
- Clear explanation of what and why
- Focused on changes and motivation
- No duplicate test/verification information
- Easy to reference later
- Better PR discussions
