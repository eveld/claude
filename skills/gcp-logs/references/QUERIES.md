# Common GCP Logging Query Patterns

Reference guide for gcloud logging queries. See main SKILL.md for usage workflow.

## By Severity

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

## By Kubernetes Resource Labels

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
```

### Available K8s Resource Labels

From `resource.labels`:
- `container_name` - Container name (usually matches service name)
- `namespace_name` - Kubernetes namespace
- `pod_name` - Specific pod instance
- `cluster_name` - GKE cluster (e.g., "core", "core-private")
- `location` - GCP region (e.g., "europe-west1")
- `project_id` - GCP project

**Tip**: Use `resource.labels.container_name` to find all logs for a service across all pod instances.

## By Time Range

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

## Combined Filters

```bash
# Errors from specific service in time range
gcloud logging read \
  'resource.labels.container_name="api-gateway" AND severity>=ERROR AND timestamp>="2025-12-24T10:00:00Z"' \
  --limit=100 \
  --format=json \
  --project=example-production
```

## Common Filter Expressions

- `severity>=ERROR` - Errors and critical logs
- `resource.type="k8s_container"` - Kubernetes container logs
- `labels.service="api-gateway"` - Custom label filtering
- `jsonPayload.message=~"database connection"` - Text search in message field
- `textPayload=~"pattern"` - Regex match in text payload
- `jsonPayload.field_name="value"` - Exact match in nested JSON field
- `jsonPayload.field_name=~"pattern"` - Regex match in nested JSON field

## Nested JSON Field Access

```bash
# Direct field access
gcloud logging read 'jsonPayload.operation_name="updateTrack"' --limit=10

# Nested object access
gcloud logging read 'jsonPayload.variables.teamSlug="kong"' --limit=10

# Deep nesting - use two-stage with jq
gcloud logging read 'jsonPayload.message="Received graphql api request"' --format=json | \
  jq '.[] | select(.jsonPayload.variables.deeply.nested.field == "value")'
```

## Regex Pattern Matching

```bash
# Case-sensitive regex match
gcloud logging read 'jsonPayload.operation_name=~"update"' --limit=10

# Multiple patterns - use jq post-processing
gcloud logging read 'jsonPayload.operation_name=~"update"' --format=json | \
  jq '.[] | select(.jsonPayload.operation_name | ascii_downcase | contains("update") or contains("create"))'
```
