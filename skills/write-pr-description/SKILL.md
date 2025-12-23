---
name: write-pr-description
description: Use when creating pull requests to write clear, structured PR descriptions that help reviewers understand changes.
---

# Write PR Description

Create structured pull request descriptions that provide context for reviewers.

## Structure

```markdown
## Summary
[1-2 sentence overview]

## What Changed
- [Bullet point 1]
- [Bullet point 2]
- [Bullet point 3]

## Why
[Explanation of why this change was needed]

## Testing
### Automated
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Linting passes

### Manual
- [x] [Specific manual test performed]
- [x] [Another manual verification]

## Screenshots
[If UI changes]
![Description](url)

## Related Issues
Closes #123
Refs #456
```

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

### Testing
Split into Automated and Manual:

**Automated**:
- Commands that were run
- All tests that pass
- CI/CD checks

**Manual**:
- Specific manual testing performed
- Edge cases verified
- Performance testing

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

## Testing
### Automated
- [x] Unit tests pass: `make test`
- [x] Integration tests pass: `make test-integration`
- [x] Linting passes: `make lint`
- [x] Added 8 new tests for refresh flow

### Manual
- [x] Verified token refreshes 5 minutes before expiry
- [x] Verified expired tokens redirect to login
- [x] Verified refresh fails gracefully with invalid tokens
- [x] Tested with 1-hour active session (multiple refreshes)

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
- Clear acceptance criteria
- Testing is documented
- Easy to reference later
- Better PR discussions
