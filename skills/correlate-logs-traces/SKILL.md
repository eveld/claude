---
name: correlate-logs-traces
description: Cross-reference GCP Cloud Logging and Cloud Trace to find relationships between request traces and log entries. Use for distributed tracing investigations.
---

# Correlate Logs and Traces

Cross-reference GCP Cloud Logging and Cloud Trace to find relationships between request traces and log entries. Useful for debugging distributed system issues where a trace ID is known.

## When to Use

- Have a trace ID from Cloud Trace and want related logs
- Investigating request flow across multiple services
- Need to find which log entries belong to specific trace
- Debugging distributed transaction failures

## Prerequisites

- Trace ID or trace filter criteria
- GCP project with Cloud Trace and Cloud Logging enabled
- Time range for correlation (default: ±5 minutes from trace)

## Workflow

### Step 1: Fetch Trace Details

```bash
# Get trace details (requires gcloud alpha)
gcloud alpha trace traces describe TRACE_ID \
  --project=instruqt-production \
  --format=json > /tmp/trace-TRACE_ID-$(date +%Y%m%d).json

# Extract trace timestamp
TRACE_TIME=$(cat /tmp/trace-*.json | jq -r '.startTime')
```

### Step 2: Query Related Logs

Use trace ID or timestamp to find related log entries:

**By Trace ID**:
```bash
gcloud logging read \
  'trace="projects/instruqt-production/traces/TRACE_ID"' \
  --limit=500 \
  --format=json \
  --project=instruqt-production > /tmp/logs-for-trace-TRACE_ID-$(date +%Y%m%d).json
```

**By Timestamp Window** (if trace ID not in logs):
```bash
# Query ±5 minutes around trace time
gcloud logging read \
  "timestamp>=\"$START_TIME\" AND timestamp<=\"$END_TIME\"" \
  --limit=500 \
  --format=json \
  --project=instruqt-production > /tmp/logs-near-trace-$(date +%Y%m%d).json
```

### Step 3: Correlate by Timestamp

Match log entries to trace spans by timestamp:

```bash
# Extract trace span timestamps
cat /tmp/trace-*.json | jq -r '.spans[] | .startTime + " " + .name'

# Extract log timestamps
cat /tmp/logs-*.json | jq -r '.[] | .timestamp + " " + .jsonPayload.message'

# Cross-reference (manual correlation)
# Look for log entries within same millisecond as trace spans
```

### Step 4: Identify Trace Path

Reconstruct request flow:
- Order trace spans by timestamp
- Match spans to services (resource labels)
- Identify which service failed or took too long
- Find error logs from failing service

**Example Analysis**:
```bash
# Show trace span timeline
cat /tmp/trace-*.json | jq -r '.spans[] | "\(.startTime) \(.name) \(.status.code)"' | sort

# Find errors in logs during trace
cat /tmp/logs-*.json | jq -r 'select(.severity=="ERROR") | .timestamp + " " + .resource.labels.container_name + " " + .jsonPayload.message'
```

### Step 5: Document Correlation

Create summary showing:
- Trace ID and duration
- Request path through services
- Which service failed
- Related error log entries
- Root cause (if identified)

**Example Output**:
```markdown
## Trace Correlation: TRACE_ID

**Trace Duration**: 2.5 seconds (expected: 200ms)
**Status**: ERROR - deadline exceeded

### Request Path
1. `api-gateway` → Started at 10:30:15.123
2. `auth-service` → 10:30:15.234 (OK, 50ms)
3. `database-proxy` → 10:30:15.284 (TIMEOUT, 2.2s)
4. Error returned to client

### Related Logs
- `database-proxy` ERROR at 10:30:17.484: "connection pool exhausted"
- `database-proxy` WARN at 10:30:17.490: "max wait time exceeded"

### Root Cause
Database connection pool exhausted, causing timeout in database-proxy service.

**Trace File**: `/tmp/trace-abc123-20251224.json`
**Log File**: `/tmp/logs-for-trace-abc123-20251224.json`
```

## Tips

- **Use trace ID when available**: Most accurate correlation method
- **Fallback to timestamp**: If logs don't include trace ID, match by timestamp ±1 second
- **Check span status**: Trace spans include status codes (OK, ERROR, DEADLINE_EXCEEDED)
- **Identify bottlenecks**: Look for spans with long duration
- **Cross-reference services**: Match trace span names to K8s pod names
