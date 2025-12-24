---
name: investigate-platform-issue
description: Systematic platform issue investigation workflow. Orchestrates Linear, GCP, Kubernetes, and Instruqt debugging across six phases.
---

# Investigate Platform Issue

Systematic workflow for investigating platform issues across Linear tickets, GCP logs, Kubernetes clusters, and Instruqt platform. Follows a six-phase process from ticket analysis through documentation.

## When to Use

- Investigating production/staging incidents reported in Linear
- Debugging complex issues requiring multiple platform tools
- Need systematic approach across GCP, Kubernetes, Instruqt
- Want structured documentation of investigation process

## Prerequisites

Check awareness skills before starting:
- `linear-awareness` - For ticket operations
- `debugging-awareness` - For platform debugging workflow
- `gcp-awareness` - For GCP logging
- `k8s-awareness` - For Kubernetes diagnostics

## Six-Phase Investigation Process

### 1. Gather Context
**Goal**: Collect all available context from Linear ticket and environment

- Fetch Linear ticket details using `query-linear-issues` skill
- Extract key information: title, description, labels, environment
- Identify affected services/components from ticket
- Determine GCP project and K8s context from ticket labels

**Example**:
```bash
# Fetch ticket
linearis issues read ENG-1234 > /tmp/ticket-ENG-1234-$(date +%Y%m%d).json

# Extract context
TICKET_ENV=$(cat /tmp/ticket-ENG-1234-*.json | jq -r '.labels[].name' | grep -E 'production|staging')
AFFECTED_SERVICE=$(cat /tmp/ticket-ENG-1234-*.json | jq -r '.title' | grep -oE '\b[a-z-]+\b' | head -1)
```

**Track Progress**:
- Use TodoWrite to create investigation task list
- Mark "Gather Context" as in_progress

### 2. Check Platform Health
**Goal**: Assess current state of affected platform components

**Parallel Checks** (spawn simultaneously):
- Check Kubernetes pods using `query-kubernetes` skill
- Query GCP logs for errors using `query-gcp-logs` skill
- Check Instruqt status using `query-instruqt-tracks` or `query-instruqt-labs` (if applicable)

**Example**:
```bash
# Kubernetes check (save to tmp)
kubectl get pods -n production -l app=$AFFECTED_SERVICE > /tmp/k8s-pods-$(date +%Y%m%d-%H%M%S).txt
kubectl get events -n production --sort-by='.lastTimestamp' > /tmp/k8s-events-$(date +%Y%m%d-%H%M%S).txt

# GCP logs check (save to tmp)
gcloud logging read \
  "resource.labels.container_name=\"$AFFECTED_SERVICE\" AND severity>=ERROR" \
  --limit=100 \
  --format=json \
  --project=instruqt-production > /tmp/gcp-errors-$(date +%Y%m%d-%H%M%S).json

# Instruqt check (if applicable)
instruqt track logs instruqt/$AFFECTED_SERVICE --since 1h --severity ERROR > /tmp/instruqt-logs-$(date +%Y%m%d-%H%M%S).log
```

**Track Progress**:
- Mark "Check Platform Health" phase complete after all checks done

### 3. Correlate Findings
**Goal**: Match errors across tools by timestamp and identify patterns

- Extract timestamps from GCP logs, K8s events, Instruqt logs
- Match events within 1-2 minute windows
- Identify error patterns (same error repeated, cascading failures)
- Note which service started failing first

**Example**:
```bash
# Extract error timestamps from GCP logs
cat /tmp/gcp-errors-*.json | jq -r '.[] | .timestamp + " " + .jsonPayload.message' | sort

# Extract K8s event timestamps
cat /tmp/k8s-events-*.txt | grep -E 'Warning|Error' | awk '{print $1, $NF}'

# Cross-reference by timestamp (manual analysis)
# Look for events within 1-2 minutes of each other
```

**Track Progress**:
- Document correlation findings
- Mark "Correlate Findings" phase complete

### 4. Deep Dive (if needed)
**Goal**: Use interactive debugging for unresolved issues

If logs don't reveal root cause:
- Launch debug container using `debug-kubernetes-container` skill
- Check network connectivity, process state, file system
- Test API endpoints from inside container
- Inspect environment variables and configuration

**Example**:
```bash
# Launch debug container
kubectl debug -it $POD_NAME \
  --image=nicolaka/netshoot \
  --namespace=production

# Inside container:
curl http://localhost:8080/health
netstat -tulpn
env | grep -E 'DATABASE|API'
```

**Track Progress**:
- Document deep dive findings
- Mark "Deep Dive" phase complete

### 5. Document Investigation
**Goal**: Create structured investigation document with all findings

- Create investigation document in `thoughts/shared/debugging/`
- Include frontmatter with ticket ID, timestamps, git commit
- Document timeline of events with timestamps
- List evidence from each platform (GCP, K8s, Instruqt)
- Reference saved log files in `/tmp/`
- State root cause (if identified) or open questions

**Document Template**:
```markdown
---
date: 2025-12-24T10:00:00Z
ticket: ENG-1234
git_commit: abc123...
branch: main
investigator: Claude
status: root-cause-identified | needs-follow-up | resolved
---

# Investigation: ENG-1234 - API Gateway Errors

## Summary
[Brief 2-3 sentence summary]

## Timeline
- 10:28 UTC: Traffic spike to 3x normal
- 10:30 UTC: First connection errors in GCP logs
- 10:32 UTC: Kubernetes pods enter CrashLoopBackOff

## Evidence

### GCP Cloud Logging
- File: `/tmp/gcp-errors-20251224-103000.json`
- Key finding: "connection refused" errors starting 10:30 UTC

### Kubernetes
- Pods: `/tmp/k8s-pods-20251224-103000.txt`
- Events: `/tmp/k8s-events-20251224-103000.txt`
- Key finding: 1/3 pods restarting, max connections reached

### Instruqt (if applicable)
- Logs: `/tmp/instruqt-logs-20251224-103000.log`
- Key finding: Track tests failing with same errors

## Root Cause
Database connection pool exhausted under traffic spike.

## Recommendation
Increase database connection pool limit from 100 to 250.

## References
- Linear ticket: ENG-1234
- GCP project: instruqt-production
- K8s namespace: production
- Affected service: api-gateway
```

**Track Progress**:
- Mark "Document Investigation" phase complete

### 6. Update Linear Ticket
**Goal**: Add investigation findings to Linear ticket for stakeholders

- Use `update-linear-issue` skill to add comment
- Include summary of findings
- Reference investigation document
- Update status to "In Progress" or "Root Cause Identified"
- Add labels for categorization

**Example**:
```bash
linearis comments create ENG-1234 --body "$(cat <<'EOF'
## Investigation Complete

**Root Cause**: Database connection pool exhausted

**Evidence**:
- GCP logs show "connection refused" starting at 10:30 UTC
- Kubernetes events show 1/3 pods in CrashLoopBackOff
- Database reached max_connections limit

**Timeline**:
- 10:28 UTC: Traffic spike (3x normal)
- 10:30 UTC: First connection errors
- 10:32 UTC: Pod restarts begin

**Recommendation**: Increase connection pool from 100 to 250

**Full investigation**: `thoughts/shared/debugging/2025-12-24-01-ENG-1234-api-gateway-errors.md`

**Log files**:
- `/tmp/gcp-errors-20251224-103000.json`
- `/tmp/k8s-events-20251224-103000.txt`
EOF
)"

# Update status
linearis issues update ENG-1234 --state "In Progress" --labels "root-cause-identified,database"
```

**Track Progress**:
- Mark "Update Linear Ticket" phase complete
- Mark entire investigation complete in TodoWrite

## Investigation Workflow Summary

1. **Gather Context** → Fetch Linear ticket, identify environment
2. **Check Platform Health** → Parallel GCP + K8s + Instruqt queries
3. **Correlate Findings** → Match timestamps, identify patterns
4. **Deep Dive** → Debug containers if logs insufficient
5. **Document Investigation** → Create structured markdown document
6. **Update Linear Ticket** → Add findings to ticket

## When NOT to Use

Don't use this full workflow when:
- Simple one-off query needed (use specific Phase 1 skill directly)
- Already know the root cause (skip to fix)
- User explicitly requests specific tool only

For systematic investigations requiring multiple platforms, always use this workflow.

## Tips

- **Save intermediate state**: Use `/tmp/` files for all queries to enable offline analysis
- **Correlate by timestamp**: Look for events within 1-2 minute windows
- **Parallel queries**: Check GCP and K8s simultaneously to save time
- **Document as you go**: Add findings to investigation doc during each phase
- **Reference saved logs**: Include file paths in Linear comments for team access
