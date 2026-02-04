# jq Patterns for Linear Issues

Advanced filtering and analysis patterns using jq. See main SKILL.md for basic commands.

## Filter Issues by Criteria

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

# Filter by priority
linearis issues list --limit 200 | jq '[.[] | select(.priority >= 2)]'  # High priority or urgent

# Filter by date range (created after)
linearis issues list --limit 200 | jq '[.[] | select(.createdAt >= "2025-12-01")]'
```

## Search Description Content

```bash
# Find issues containing Slack/Unthread links (support tickets)
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | contains("example.slack.com") or contains("unthread.io")))]'

# Find issues mentioning specific error messages
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | contains("host for this script was not found")))]'

# Case-insensitive search in description
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | ascii_downcase | contains("error")))]'

# Search in title
linearis issues list --limit 200 | jq '[.[] | select(.title | ascii_downcase | contains("api"))]'

# Search in both title and description
linearis issues list --limit 200 | jq '[.[] | select(
  (.title | ascii_downcase | contains("crash")) or
  (has("description") and (.description | ascii_downcase | contains("crash")))
)]'
```

## Extract Unique Values

```bash
# Get all unique labels
linearis issues list --limit 200 | jq '[.[].labels[]? | {id, name}] | unique_by(.id) | sort_by(.name)'

# Get all unique projects
linearis issues list --limit 200 | jq '[.[] | select(has("project")) | .project] | unique_by(.id) | sort_by(.name)'

# Get all unique teams
linearis issues list --limit 200 | jq '[.[].team | {id, key, name}] | unique_by(.id) | sort_by(.name)'

# Get all unique states
linearis issues list --limit 200 | jq '[.[].state | {id, name}] | unique_by(.id) | sort_by(.name)'

# Get all unique assignees
linearis issues list --limit 200 | jq '[.[] | select(has("assignee")) | .assignee] | unique_by(.id) | sort_by(.name)'
```

## Count and Group Issues

```bash
# Count issues by label
linearis issues list --limit 200 | jq '[.[].labels[]?] | group_by(.name) | map({label: .[0].name, count: length}) | sort_by(-.count)'

# Count issues by team
linearis issues list --limit 200 | jq 'group_by(.team.key) | map({team: .[0].team.key, count: length}) | sort_by(-.count)'

# Count issues by state
linearis issues list --limit 200 | jq 'group_by(.state.name) | map({state: .[0].state.name, count: length})'

# Count issues by priority
linearis issues list --limit 200 | jq 'group_by(.priority) | map({priority: .[0].priority, count: length}) | sort_by(.priority)'

# Count issues by assignee
linearis issues list --limit 200 | jq '[.[] | select(has("assignee"))] | group_by(.assignee.name) | map({assignee: .[0].assignee.name, count: length}) | sort_by(-.count)'

# Count issues by project
linearis issues list --limit 200 | jq '[.[] | select(has("project"))] | group_by(.project.name) | map({project: .[0].project.name, count: length}) | sort_by(-.count)'
```

## Complex Multi-Field Extraction

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

# Extract with calculated fields
linearis issues list --limit 50 | jq '.[] | {
  id: .identifier,
  title: .title,
  age_days: ((now - (.createdAt | fromdateiso8601)) / 86400 | floor),
  has_assignee: (has("assignee") and .assignee != null),
  label_count: (.labels | length)
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

# Create markdown table
linearis issues list --limit 20 | jq -r '.[] | "| \(.identifier) | \(.title) | \(.state.name) | \(.assignee.name // "Unassigned") |"'
```

## Support Ticket Patterns

### Finding Support-Related Issues

```bash
# Issues with Unthread/Slack links (likely support tickets)
linearis issues list --limit 200 | jq '[.[] | select(has("description") and (.description | contains("unthread.io") or contains("slack.com")))]' > /tmp/support-tickets.json

# Issues from specific team (e.g., support team)
linearis issues list --limit 200 | jq '[.[] | select(.team.key == "SUPPORT")]'

# Issues with specific labels indicating support work
linearis issues list --limit 200 | jq '[.[] | select(.labels[]?.name == "Support" or .labels[]?.name == "Bug")]'

# Combine: Support team + Slack links + In Progress
linearis issues list --limit 200 | jq '[.[] | select(
  .team.key == "SUPPORT" and
  .state.name == "In Progress" and
  (has("description") and (.description | contains("slack.com")))
)]'

# High priority support issues
linearis issues list --limit 200 | jq '[.[] | select(
  (.labels[]?.name == "Support") and
  .priority >= 2 and
  (.state.name == "In Progress" or .state.name == "Todo")
)]'
```

## Handling Null/Missing Fields

```bash
# Check if field exists before accessing
linearis issues list --limit 200 | jq '[.[] | select(has("project"))]'
linearis issues list --limit 200 | jq '[.[] | select(has("assignee"))]'

# Use // operator for default values
linearis issues list --limit 200 | jq '.[] | {
  id: .identifier,
  project: .project.name // "No project",
  assignee: .assignee.name // "Unassigned",
  priority_label: (if .priority == 0 then "None" elif .priority == 1 then "Low" elif .priority == 2 then "Medium" elif .priority == 3 then "High" else "Urgent" end)
}'

# Safe navigation with ? operator for arrays
linearis issues list --limit 200 | jq '.[] | .labels[]?.name'  # Won't error if labels is null

# Check for empty arrays
linearis issues list --limit 200 | jq '[.[] | select(.labels | length > 0)]'

# Combine multiple null checks
linearis issues list --limit 200 | jq '.[] | {
  id: .identifier,
  has_project: (has("project") and .project != null),
  has_assignee: (has("assignee") and .assignee != null),
  has_labels: (.labels | length > 0),
  has_description: (has("description") and .description != null and (.description | length > 0))
}'
```

## Time-based Analysis

```bash
# Issues created in last 7 days
linearis issues list --limit 200 | jq --arg date "$(date -v-7d -u +"%Y-%m-%dT%H:%M:%SZ")" '[.[] | select(.createdAt >= $date)]'

# Issues updated recently
linearis issues list --limit 200 | jq --arg date "$(date -v-3d -u +"%Y-%m-%dT%H:%M:%SZ")" '[.[] | select(.updatedAt >= $date)]'

# Calculate age in days
linearis issues list --limit 200 | jq '.[] | {
  id: .identifier,
  age_days: ((now - (.createdAt | fromdateiso8601)) / 86400 | floor),
  days_since_update: ((now - (.updatedAt | fromdateiso8601)) / 86400 | floor)
}'

# Find stale issues (not updated in 30+ days)
linearis issues list --limit 200 | jq '[.[] | select(((now - (.updatedAt | fromdateiso8601)) / 86400 | floor) > 30)]'
```

## Chaining Filters

```bash
# Multi-stage pipeline
linearis issues list --limit 200 | \
  jq '[.[] | select(.team.key == "ENG")]' | \           # Filter team
  jq '[.[] | select(.state.name == "In Progress")]' | \ # Filter state
  jq '[.[] | select(.priority >= 2)]' | \                # Filter priority
  jq 'sort_by(.priority) | reverse'                     # Sort

# Single complex filter (more efficient)
linearis issues list --limit 200 | jq '[.[] | select(
  .team.key == "ENG" and
  .state.name == "In Progress" and
  .priority >= 2
)] | sort_by(.priority) | reverse'
```

## Tips

- Use `has("field")` to check field existence before accessing
- Use `//` operator for default values when fields might be null
- Use `?` operator for safe array/object navigation (e.g., `.labels[]?`)
- Combine filters in single jq expression for better performance
- Use `ascii_downcase` for case-insensitive string matching
- Use `length` to check if arrays are empty
- Save filtered results to files for further analysis
- For date comparisons, use ISO 8601 format
