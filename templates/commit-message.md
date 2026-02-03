# Commit Message Template

## Format

```
{TYPE}({SCOPE}): {SUBJECT}

{OPTIONAL_BODY}

{OPTIONAL_FOOTER}
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

## Scope

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

- `Closes #123` - Closes issue
- `BREAKING CHANGE:` - Breaking changes
- `Refs #456` - References related issue

## Example Templates

### Feature
```
feat({SCOPE}): {SUBJECT}

{EXPLANATION_OF_WHAT_AND_WHY}

Closes #{ISSUE}
```

### Bug Fix
```
fix({SCOPE}): {SUBJECT}

{WHAT_WAS_BROKEN}
{HOW_IT_WAS_FIXED}
```

### Refactoring
```
refactor({SCOPE}): {SUBJECT}

{WHY_REFACTORING_WAS_NEEDED}
{BENEFITS_OF_NEW_APPROACH}
```

### Tests
```
test({SCOPE}): {SUBJECT}

{WHAT_SCENARIOS_ARE_COVERED}
```
