---
name: linear-issues
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

## Advanced Filtering with jq

### 4. Filter Issues by Criteria

```bash
# Filter by team key
linearis issues list --limit 200 | jq '[.[] | select(.team.key == "ENG")]'

# Filter by label name
linearis issues list --limit 200 | jq '[.[] | select(.labels[]?.name == "FileB")]'

# Filter by state
linearis issues list --limit 200 | jq '[.[] | select(.state.name == "In Progress")]'

# Filter by assignee
linearis issues list --limit 200 | jq '[.[] | select(.assignee.name == "John Doe")]'

# Filter by project
linearis issues list --limit 200 | jq '[.[] | select(.project.name == "Platform Pain 🤯")]'

# Multiple conditions (issues with FileB label in ENG team)
linearis issues list --limit 200 | jq '[.[] | select(.team.key == "ENG" and (.labels[]?.name == "FileB"))]'
```

### 5. Search Description Content

```bash
# Find issues containing Slack/Unthread links (support tickets)
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | contains("instruqt.slack.com") or contains("unthread.io")))]'

# Find issues mentioning specific error messages
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | contains("host for this script was not found")))]'

# Case-insensitive search in description
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | ascii_downcase | contains("error")))]'
```

### 6. Extract Unique Values

```bash
# Get all unique labels
linearis issues list --limit 200 | jq '[.[].labels[]? | {id, name}] | unique_by(.id) | sort_by(.name)'

# Get all unique projects
linearis issues list --limit 200 | jq '[.[] | select(has("project")) | .project] | unique_by(.id) | sort_by(.name)'

# Get all unique teams
linearis issues list --limit 200 | jq '[.[].team | {id, key, name}] | unique_by(.id) | sort_by(.name)'

# Get all unique states
linearis issues list --limit 200 | jq '[.[].state | {id, name}] | unique_by(.id) | sort_by(.name)'
```

### 7. Count and Group Issues

```bash
# Count issues by label
linearis issues list --limit 200 | jq '[.[].labels[]?] | group_by(.name) | map({label: .[0].name, count: length}) | sort_by(-.count)'

# Count issues by team
linearis issues list --limit 200 | jq 'group_by(.team.key) | map({team: .[0].team.key, count: length}) | sort_by(-.count)'

# Count issues by state
linearis issues list --limit 200 | jq 'group_by(.state.name) | map({state: .[0].state.name, count: length})'

# Count issues by priority
linearis issues list --limit 200 | jq 'group_by(.priority) | map({priority: .[0].priority, count: length}) | sort_by(.priority)'
```

### 8. Complex Multi-Field Extraction

```bash
# Extract issue summary with multiple fields
linearis issues list --limit 50 | jq '.[] | {
  id: .identifier,
  title: .title,
  team: .team.key,
  state: .state.name,
  priority: .priority,
  labels: [.labels[]?.name],
  project: .project.name // "No project",
  assignee: .assignee.name // "Unassigned",
  created: .createdAt,
  updated: .updatedAt
}'

# Save to CSV-like format
linearis issues list --limit 50 | jq -r '.[] | [
  .identifier,
  .title,
  .team.key,
  .state.name,
  .priority,
  (.labels[]?.name // "" | join(",")),
  .project.name // "No project"
] | @csv' > /tmp/linear-issues.csv
```

## Common Patterns for Support Tickets

### Finding Support-Related Issues

```bash
# Issues with Unthread/Slack links (likely support tickets)
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | contains("unthread.io") or contains("slack.com")))]' > /tmp/support-tickets.json

# Issues from specific team (e.g., INS = Instruqt support team)
linearis issues list --limit 200 | jq '[.[] | select(.team.key == "INS")]'

# Issues with specific labels indicating support work
linearis issues list --limit 200 | jq '[.[] | select(.labels[]?.name == "Support" or .labels[]?.name == "Bug")]'

# Combine: Support team + Slack links + In Progress
linearis issues list --limit 200 | jq '[.[] | select(
  .team.key == "INS" and
  .state.name == "In Progress" and
  (has("description") and (.description | contains("slack.com")))
)]'
```

## Handling Null/Missing Fields

```bash
# Check if field exists before accessing
linearis issues list --limit 200 | jq '[.[] | select(has("project"))]'

# Use // operator for default values
linearis issues list --limit 200 | jq '.[] | {
  id: .identifier,
  project: .project.name // "No project",
  assignee: .assignee.name // "Unassigned"
}'

# Safe navigation with ? operator for arrays
linearis issues list --limit 200 | jq '.[] | .labels[]?.name'  # Won't error if labels is null
```

## Tips

- Use identifiers like `ENG-1234` instead of UUIDs for readability
- Pipe output to `jq` for parsing JSON
- Save issue details before debugging to preserve context
- Search results are limited - use specific queries
- Issue descriptions often contain error messages, stack traces, or reproduction steps
- Check issue labels for environment info (production, staging, etc.)
- Use `has("field")` to check field existence before accessing
- Use `//` operator in jq for default values when fields might be null
- Use `?` operator for safe array/object navigation (e.g., `.labels[]?`)
- Save filtered results to files for further analysis
- Increase `--limit` (max usually 200) for comprehensive searches
