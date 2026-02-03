---
name: write-commit-message
description: Use when creating git commits to ensure consistent, clear commit messages following conventional commits format.
---

# Write Commit Message

Create git commit messages following the Conventional Commits format.

## Template

See `templates/commit-message.md` for the full template structure, format rules, and examples.

## Quick Reference

**Format**:
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Common Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

**Key Rules**:
- Subject < 72 characters
- Use imperative mood ("add" not "added")
- No period at end of subject
- Body explains what and why, not how

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
