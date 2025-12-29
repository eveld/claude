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

### 2. Query by Kubernetes Resource Labels

Kubernetes container logs have a `resource.type="k8s_container"` with these labels:

```bash
# Filter by container name (most useful for finding service logs)
gcloud logging read \
  'resource.type="k8s_container" AND resource.labels.container_name="service-b"' \
  --limit=100 \
  --format=json

# Filter by namespace and container
gcloud logging read \
  'resource.labels.namespace_name="app-namespace" AND resource.labels.container_name="service-b"' \
  --limit=100

# Filter by pod name (specific pod instance)
gcloud logging read \
  'resource.labels.pod_name="service-b-5ddcfbd7f8-bt5j9"' \
  --limit=100

# Filter by cluster name
gcloud logging read \
  'resource.labels.cluster_name="production-cluster" AND resource.labels.container_name="service-c"' \
  --limit=100

# Available K8s resource labels (from resource.labels):
# - container_name - Container name (usually matches service name)
# - namespace_name - Kubernetes namespace
# - pod_name - Specific pod instance
# - cluster_name - GKE cluster (e.g., "core", "core-private")
# - location - GCP region (e.g., "europe-west1")
# - project_id - GCP project
```

**Example log entry structure**:
```json
{
  "resource": {
    "type": "k8s_container",
    "labels": {
      "cluster_name": "core-private",
      "container_name": "service-c",
      "namespace_name": "integrations",
      "pod_name": "integrations-service-c-85f98fc5c-7mbdq",
      "project_id": "example-dev",
      "location": "europe-west1"
    }
  },
  "jsonPayload": { "message": "..." },
  "severity": "WARNING",
  "timestamp": "2025-12-19T12:22:52.205169027Z"
}
```

**Tip**: Use `resource.labels.container_name` to find all logs for a service across all pod instances.

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
  --project=example-production
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
- `textPayload=~"pattern"` - Regex match in text payload
- `jsonPayload.field_name="value"` - Exact match in nested JSON field
- `jsonPayload.field_name=~"pattern"` - Regex match in nested JSON field

## Advanced Query Patterns

```

## Common Pitfalls and Solutions

### Escaping and Quoting Issues

```bash
# ❌ WRONG - Shell interprets special characters
gcloud logging read jsonPayload.message=~"error" --limit=10

# ✅ CORRECT - Single quotes protect the filter
gcloud logging read 'jsonPayload.message=~"error"' --limit=10

# ❌ WRONG - Complex nested conditions cause escaping issues
gcloud logging read 'field1="val1" AND (field2="val2" OR field3="val3")' --limit=10

# ✅ BETTER - Use two-stage with jq for complex logic
gcloud logging read 'field1="val1"' --limit=100 --format=json | \
  jq '.[] | select(.field2 == "val2" or .field3 == "val3")'
```

### Time Range Performance

```bash
# ❌ SLOW - Very broad time range
gcloud logging read 'jsonPayload.message="error" AND timestamp>="2025-01-01T00:00:00Z"' --limit=1000

# ✅ FASTER - Narrow time window (1-2 hours for recent data, or specific day)
gcloud logging read 'jsonPayload.message="error" AND timestamp>="2025-11-20T15:00:00Z" AND timestamp<="2025-11-20T16:00:00Z"' --limit=1000

# ✅ BEST - Start narrow, expand if needed
# 1. Check last hour
# 2. If no results, expand to last 24 hours
# 3. If still no results, check if ANY logs exist in broader range
```

### Accessing Nested JSON Fields

```bash
# Direct field access
gcloud logging read 'jsonPayload.operation_name="updateTrack"' --limit=10

# Nested object access
gcloud logging read 'jsonPayload.variables.teamSlug="kong"' --limit=10

# IMPORTANT: Deep nesting or complex conditions often fail in gcloud filters
# Use two-stage approach instead:
gcloud logging read 'jsonPayload.message="Received graphql api request"' --format=json | \
  jq '.[] | select(.jsonPayload.variables.deeply.nested.field == "value")'
```

### Regex Pattern Matching

```bash
# Case-sensitive regex match
gcloud logging read 'jsonPayload.operation_name=~"update"' --limit=10

# Multiple pattern matching - use jq post-processing
gcloud logging read 'jsonPayload.operation_name=~"update"' --format=json | \
  jq '.[] | select(.jsonPayload.operation_name | ascii_downcase | contains("update") or contains("create"))'
```

## Query Strategy Checklist

1. **Start simple**: Begin with basic filters (severity, timestamp, message)
2. **Verify data exists**: Check if logs are available in your time range
3. **Narrow time windows**: Use 1-2 hour windows for better performance
4. **Use two-stage**: For complex logic, query broad → filter with jq
5. **Save to files**: Store results for analysis and debugging
6. **Iterate**: Start broad, progressively add filters
