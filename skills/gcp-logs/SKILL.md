---
name: gcp-logs
description: Query GCP Cloud Logging for errors, service logs, and request traces. Use when investigating GCP-hosted services.
---

# Query GCP Logs

Search GCP Cloud Logging for application errors, service logs, and traces.

## When to Use

- Investigating errors in GCP-hosted services
- Finding request traces for debugging
- Analyzing service behavior over time
- Correlating events across services

## Pre-flight Checks

### Authentication and Context
```bash
# Check gcloud auth
gcloud auth list 2>/dev/null | grep -q ACTIVE || {
  echo "Not authenticated. Run: gcloud auth login"
  exit 1
}

# Show current project
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
echo "Current GCP Project: $CURRENT_PROJECT"

# If context suggests different project, prompt to switch
# Example: User mentions "production" but current project is "staging"
# Detect from query context and prompt:
# echo "Query mentions 'production' but current project is '$CURRENT_PROJECT'"
# echo "Switch to production project? Run: gcloud config set project example-production"
# read -p "Continue with current project? (y/n) " -n 1 -r
```

## Query Strategy

Follow this approach for effective log queries:

1. **Start simple**: Begin with basic filters (severity, service, timestamp)
2. **Verify data exists**: Check if logs are available in your time range
3. **Narrow time windows**: Use 1-2 hour windows for better performance
4. **Use two-stage filtering**: For complex logic, query broad → filter with jq
5. **Save to files**: Store large result sets for analysis
6. **Iterate**: Start broad, progressively add filters

### Example Workflow

```bash
# Step 1: Check if ANY logs exist in time range
gcloud logging read 'timestamp>="2025-12-24T10:00:00Z"' --limit=10

# Step 2: Filter to specific service
gcloud logging read 'resource.labels.container_name="api-gateway"' --limit=50

# Step 3: Add severity filter
gcloud logging read 'resource.labels.container_name="api-gateway" AND severity>=ERROR' --limit=100

# Step 4: Narrow time window
gcloud logging read \
  'resource.labels.container_name="api-gateway" AND severity>=ERROR AND timestamp>="2025-12-24T10:00:00Z" AND timestamp<="2025-12-24T11:00:00Z"' \
  --limit=100 \
  --format=json
```

## Output Management

For large outputs (>100 entries), save to tmp file:

```bash
# Save logs to tmp file
gcloud logging read 'severity>=ERROR' \
  --limit=1000 \
  --format=json > /tmp/gcp-errors-$(date +%Y%m%d-%H%M%S).json

# Then analyze with jq, grep, or other tools
cat /tmp/gcp-errors-*.json | jq '.[] | select(.severity=="CRITICAL")'
cat /tmp/gcp-errors-*.json | jq '.[] | .jsonPayload.message' | sort | uniq -c
```

**Benefits**:
- Preserve output for multiple operations
- Easier to analyze large result sets
- Share logs with team or attach to tickets

## Common Patterns

For detailed query examples, see:
- [Query patterns by severity, resource, time](references/QUERIES.md)
- [Log entry structure and fields](references/LOG-STRUCTURE.md)
- [Common pitfalls and solutions](references/PITFALLS.md)

### Quick Reference

```bash
# Errors from specific service
gcloud logging read 'resource.labels.container_name="service-name" AND severity>=ERROR' --limit=100

# Logs in time range
gcloud logging read 'timestamp>="2025-12-24T10:00:00Z" AND timestamp<="2025-12-24T11:00:00Z"' --limit=200

# Combined filters
gcloud logging read 'resource.labels.container_name="api" AND severity>=ERROR AND timestamp>="2025-12-24T10:00:00Z"' --format=json
```

## Output Format

- `--format=json` - Machine-readable JSON (recommended for piping to jq)
- `--format=table` - Human-readable table
- Default: Log entries with timestamps

## Tips

- Always single-quote filter strings to prevent shell interpretation
- Use `--limit` to control result count (default: 10)
- Use `--project` to override current project
- Combine filters with `AND`, `OR`, `NOT`
- Use ISO 8601 timestamps with timezone (e.g., "2025-12-24T10:00:00Z")
- For deep nesting or complex conditions, use two-stage filtering with jq
- Start with narrow time windows (1-2 hours) for better performance
