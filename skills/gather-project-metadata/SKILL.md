---
name: gather-project-metadata
description: Use when creating research or plan documents to gather git commit, branch, repository info.
---

# Gather Project Metadata

Collect metadata for documentation frontmatter.

## What to Gather

- Current timestamp (ISO format with timezone)
- Git commit hash
- Git branch name
- Repository name
- Project name (from directory or package.json)
- Feature slug (if in feature directory context)

## How to Gather

Run the metadata collection script:

```bash
~/.claude/scripts/collect-metadata.sh
```

Or gather manually:

```bash
# Timestamp
date -u +"%Y-%m-%dT%H:%M:%SZ"

# Git info
git rev-parse HEAD
git rev-parse --abbrev-ref HEAD
git remote get-url origin | sed 's/.*[:/]\(.*\)\.git/\1/'

# Project name
basename $(pwd)

# Feature slug (if applicable)
FEATURE_DIR=$(pwd | grep -oE 'thoughts/[0-9]{4}-[^/]+' || echo "")
if [ -n "$FEATURE_DIR" ]; then
    basename "$FEATURE_DIR"
fi
```

## Usage in Documents

Insert gathered metadata into frontmatter:

```yaml
---
date: 2025-12-23T10:30:00Z
git_commit: abc123...
branch: main
repository: github.com/eveld/claude
---
```

## Template Variables

When using templates, replace these placeholders:
- `{ISO_TIMESTAMP}` - ISO 8601 timestamp
- `{GIT_COMMIT}` - Full commit hash
- `{BRANCH_NAME}` - Current branch
- `{REPOSITORY}` - Repository path
- `{PROJECT_NAME}` - Project name
- `{DATE}` - Simple date (YYYY-MM-DD)
- `{FEATURE_SLUG}` - Feature slug (e.g., "0005-authentication")
