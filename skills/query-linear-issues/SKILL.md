---
name: query-linear-issues
description: Fetch and view Linear issues/tickets. List, search, read issue details, status, comments. Use when investigating tickets or gathering debugging context.
---

# Query Linear Issues

Fetch and view Linear issues to gather context for debugging investigations.

## When to Use

- Viewing issue details for debugging context
- Searching for related issues
- Checking issue status and priority
- Reading issue descriptions and comments
- Finding issues by ID or search query

## Pre-flight Checks

### Authentication
```bash
# linearis uses API token from environment or config
# Check if linearis is available
linearis --version 2>/dev/null || {
  echo "linearis CLI not installed"
  echo "Install: npm install -g linearis"
  exit 1
}

# Test authentication (list with limit 1)
linearis issues list --limit 1 >/dev/null 2>&1 || {
  echo "Not authenticated to Linear"
  echo "Set LINEARIS_API_TOKEN environment variable or use --api-token flag"
  exit 1
}
```

## Common Commands

### 1. Read Issue Details
```bash
# Get issue by ID or identifier
linearis issues read ENG-1234

# Output is JSON - use jq to parse
linearis issues read ENG-1234 | jq '.title'
linearis issues read ENG-1234 | jq '.description'
linearis issues read ENG-1234 | jq '.state.name'

# Full issue details
linearis issues read ENG-1234 | jq '.'
```

### 2. List Issues
```bash
# List recent issues (default limit: 25)
linearis issues list

# Limit results
linearis issues list --limit 10
linearis issues list --limit 100

# Save to file for analysis
linearis issues list --limit 50 > /tmp/linear-issues-$(date +%Y%m%d).json
```

### 3. Search Issues
```bash
# Search by text query
linearis issues search "api-gateway error"
linearis issues search "production crash"
linearis issues search "kubernetes pod"

# Save search results
linearis issues search "database connection" > /tmp/linear-search-$(date +%Y%m%d).json
```

## Output Format

All linearis commands output JSON. Use `jq` to parse and extract fields.

**Common jq patterns**:
```bash
# Extract issue title
linearis issues read ENG-1234 | jq -r '.title'

# Extract state
linearis issues read ENG-1234 | jq -r '.state.name'

# Extract assignee
linearis issues read ENG-1234 | jq -r '.assignee.name'

# Extract labels
linearis issues read ENG-1234 | jq -r '.labels[].name'

# Extract comments (if included)
linearis issues read ENG-1234 | jq -r '.comments[]'
```

## Output Management

**Save issue details for debugging context**:
```bash
# Save issue to tmp file
linearis issues read ENG-1234 > /tmp/linear-issue-ENG-1234-$(date +%Y%m%d).json

# Extract key info for quick reference
linearis issues read ENG-1234 | jq -r '{
  id: .identifier,
  title: .title,
  state: .state.name,
  priority: .priority,
  description: .description
}' > /tmp/issue-summary-ENG-1234.json

# Use issue context for debugging
ISSUE_DESC=$(linearis issues read ENG-1234 | jq -r '.description')
echo "Debugging: $ISSUE_DESC"
```

**Benefits**:
- Issue context informs debugging strategy
- Share investigation files with team
- Correlate issue reports with logs/events

## Tips

- Use identifiers like `ENG-1234` instead of UUIDs for readability
- Pipe output to `jq` for parsing JSON
- Save issue details before debugging to preserve context
- Search results are limited - use specific queries
- Issue descriptions often contain error messages, stack traces, or reproduction steps
- Check issue labels for environment info (production, staging, etc.)
