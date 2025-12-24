---
name: enrich-linear-from-logs
description: Add GCP/Kubernetes log findings to Linear tickets. Queries logs, formats findings, updates ticket with structured comment.
---

# Enrich Linear From Logs

Specific workflow for adding log analysis findings to Linear tickets. Queries GCP Cloud Logging and/or Kubernetes logs, formats results, and updates Linear ticket with structured comment.

## When to Use

- Need to add recent error logs to existing Linear ticket
- Want to document specific log entries in ticket for team visibility
- Enriching ticket with evidence before escalation
- Updating ticket after finding relevant log patterns

## Prerequisites

- Linear ticket ID (e.g., ENG-1234)
- Know which logs to query (GCP, K8s, or both)
- Time range for log query (default: last 1 hour)

## Workflow

### Step 1: Determine Log Sources
Ask user or infer from ticket:
- GCP Cloud Logging only
- Kubernetes logs only
- Both GCP and Kubernetes

### Step 2: Query Logs (Parallel if Both)

**GCP Logs**:
```bash
# Query using query-gcp-logs skill
gcloud logging read \
  'severity>=ERROR AND timestamp>="2025-12-24T09:00:00Z"' \
  --limit=100 \
  --format=json \
  --project=instruqt-production > /tmp/gcp-logs-for-ENG-1234-$(date +%Y%m%d).json
```

**Kubernetes Logs**:
```bash
# Query using query-kubernetes skill
kubectl logs -n production -l app=api-gateway --tail=200 > /tmp/k8s-logs-for-ENG-1234-$(date +%Y%m%d).log
kubectl get events -n production --sort-by='.lastTimestamp' > /tmp/k8s-events-for-ENG-1234-$(date +%Y%m%d).txt
```

### Step 3: Format Findings
Extract key information:
- Error messages and counts
- Timestamps of first/last occurrence
- Affected components/services
- Error patterns (same error repeated)

**Example Analysis**:
```bash
# Count error occurrences
cat /tmp/gcp-logs-*.json | jq -r '.[] | .jsonPayload.message' | sort | uniq -c | sort -rn

# Extract unique error messages
cat /tmp/gcp-logs-*.json | jq -r '.[] | .jsonPayload.message' | sort -u
```

### Step 4: Update Linear Ticket
Use `update-linear-issue` skill to add formatted comment:

```bash
linearis comments create ENG-1234 --body "$(cat <<'EOF'
## Log Analysis Results

**Time Range**: 2025-12-24 09:00 - 10:00 UTC
**Sources**: GCP Cloud Logging, Kubernetes events

### GCP Cloud Logging
**Error Count**: 47 errors in 1 hour
**Most Common**: "connection refused" (32 occurrences)
**First Occurrence**: 09:15:23 UTC
**Last Occurrence**: 09:58:41 UTC

**Unique Errors**:
1. "dial tcp 10.0.1.5:5432: connection refused" (32x)
2. "context deadline exceeded" (15x)

### Kubernetes Events
**Pod Restarts**: 3 pods restarted in last hour
**Key Event**: "Back-off restarting failed container" (api-gateway-abc123)

**Log Files**:
- GCP: `/tmp/gcp-logs-for-ENG-1234-20251224.json`
- K8s: `/tmp/k8s-logs-for-ENG-1234-20251224.log`
EOF
)"
```

### Step 5: Optionally Update Labels
Add labels based on findings:
```bash
linearis issues update ENG-1234 --labels "gcp-errors,kubernetes,database-connection"
```

## Example Usage

**User request**: "Add the last hour of GCP errors to ENG-1234"

**Claude workflow**:
1. Use `query-gcp-logs` to fetch errors from last hour
2. Analyze and format findings
3. Use `update-linear-issue` to add comment
4. Confirm ticket updated

## Output Format

The Linear comment should include:
- Time range queried
- Log sources (GCP, K8s, both)
- Error counts and patterns
- Timestamps (first/last occurrence)
- Unique error messages
- References to saved log files

## Tips

- **Default to 1 hour**: If no time range specified, query last hour
- **Save logs**: Always save raw logs to `/tmp/` for later analysis
- **Format for readability**: Use markdown headers and lists in Linear comment
- **Include file references**: Add log file paths so team can access raw data
- **Update labels**: Add relevant labels for filtering (gcp-errors, k8s-restarts, etc.)
