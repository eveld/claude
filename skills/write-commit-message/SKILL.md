---
name: write-commit-message
description: Use when creating git commits to ensure consistent, clear commit messages following conventional commits format.
---

# Write Commit Message

Create git commit messages following the Conventional Commits format.

## Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

## Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, no logic change)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

## Rules

1. Subject line < 72 characters
2. Use imperative mood ("add feature" not "added feature")
3. Don't capitalize first letter of subject
4. No period at end of subject
5. Separate subject from body with blank line
6. Wrap body at 72 characters
7. Use body to explain what and why, not how

## Examples

**Feature**:
```
feat(auth): add JWT token refresh mechanism

Implements automatic token refresh to prevent user sessions from
expiring unexpectedly. Tokens are refreshed 5 minutes before expiry.

Closes #123
```

**Bug fix**:
```
fix(api): handle null values in user response

Previously crashed when user profile was incomplete. Now returns
default values for missing fields.
```

**Refactoring**:
```
refactor(auth): extract token validation into separate function

Improves testability and reduces duplication across middleware
and handlers.
```

**Tests**:
```
test(auth): add tests for token refresh flow

Covers successful refresh, expired token, and invalid token cases.
```

## Scope

Scope is optional but recommended:
- Use component/module name: `(auth)`, `(api)`, `(ui)`
- Use file/package name for small changes: `(user-handler)`
- Omit if change spans multiple areas

## Body

Include body when:
- Change is non-obvious
- Explains why, not what
- References issues or tickets
- Breaking changes need explanation

## Footer

Use footer for:
- `Closes #123` - Closes issue
- `BREAKING CHANGE:` - Breaking changes
- `Refs #456` - References related issue

## Integration with Git Workflow

When user asks to commit or you're following git workflow:

1. Run `git status` and `git diff` to see changes
2. Analyze the nature of changes
3. Draft commit message following format
4. Use heredoc for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT token refresh

Implements automatic token refresh mechanism.
EOF
)"
```

## Benefits

- Clear, scannable git history
- Semantic versioning compatibility
- Automatic changelog generation
- Easy to search and filter commits
