---
name: query-gcp-logs
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
# echo "Switch to production project? Run: gcloud config set project instruqt-production"
# read -p "Continue with current project? (y/n) " -n 1 -r
```

## Common Query Patterns

### 1. Query by Severity
```bash
# Get ERROR and higher severity logs
gcloud logging read \
  'severity>=ERROR' \
  --limit=100 \
  --format=json \
  --project=<project-name>

# Get CRITICAL logs only
gcloud logging read \
  'severity=CRITICAL' \
  --limit=50 \
  --format=json
```

### 2. Query by Resource
```bash
# Filter by container name
gcloud logging read \
  'resource.labels.container_name="api-gateway"' \
  --limit=100 \
  --format=json

# Filter by namespace and container
gcloud logging read \
  'resource.labels.namespace_name="production" AND resource.labels.container_name="api-gateway"' \
  --limit=100
```

### 3. Query by Time Range
```bash
# Last hour
gcloud logging read \
  'timestamp>="2025-12-24T10:00:00Z"' \
  --limit=200 \
  --format=json

# Time range
gcloud logging read \
  'timestamp>="2025-12-24T10:00:00Z" AND timestamp<="2025-12-24T11:00:00Z"' \
  --limit=500
```

### 4. Combined Filters
```bash
# Errors from specific service in time range
gcloud logging read \
  'resource.labels.container_name="api-gateway" AND severity>=ERROR AND timestamp>="2025-12-24T10:00:00Z"' \
  --limit=100 \
  --format=json \
  --project=instruqt-production
```

## Output Format

- `--format=json` - Machine-readable JSON output
- `--format=table` - Human-readable table
- Default: Log entries with timestamps

## Output Management

**For large outputs or consecutive analysis**, pipe to tmp file:
```bash
# Save logs to tmp file for analysis
gcloud logging read 'severity>=ERROR' \
  --limit=1000 \
  --format=json > /tmp/gcp-errors-$(date +%Y%m%d-%H%M%S).json

# Then analyze with jq, grep, or other tools
cat /tmp/gcp-errors-*.json | jq '.[] | select(.severity=="CRITICAL")'
```

**Benefits**:
- Preserve output for multiple consecutive operations
- Easier to analyze large result sets
- Share logs with team or attach to tickets

## Tips

- Use `--limit` to control result count (default: 10, max varies)
- Use `--project` to override current project
- Combine filters with `AND`, `OR`, `NOT`
- Quote filter strings to prevent shell interpretation
- Use timestamps in ISO 8601 format with timezone
- For large result sets (>100 entries), pipe to tmp file for analysis

## Common Filters

- `severity>=ERROR` - Errors and critical logs
- `resource.type="k8s_container"` - Kubernetes container logs
- `labels.service="api-gateway"` - Custom label filtering
- `jsonPayload.message=~"database connection"` - Text search in message field
