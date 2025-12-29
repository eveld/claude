---
name: linear-update
description: Update Linear issues with debugging findings. Add comments, change status, update labels, set priority. Use after completing investigations.
---

# Update Linear Issue

Update Linear issues with debugging findings, status changes, and investigation notes.

## When to Use

- Adding debugging findings as comments
- Updating issue status after investigation
- Adding labels for categorization
- Changing priority based on severity
- Recording root cause analysis

## Pre-flight Checks

### Authentication
```bash
# Check linearis is available and authenticated
linearis --version 2>/dev/null || {
  echo "linearis CLI not installed"
  exit 1
}

linearis issues list --limit 1 >/dev/null 2>&1 || {
  echo "Not authenticated to Linear"
  exit 1
}
```

## Common Commands

### 1. Add Comment
```bash
# Add single-line comment
linearis comments create ENG-1234 --body "Root cause identified: database connection pool exhausted"

# Add multi-line comment with heredoc
linearis comments create ENG-1234 --body "$(cat <<'EOF'
## Investigation Findings

**Root Cause**: Database connection pool exhausted

**Evidence**:
- GCP logs show "connection refused" errors starting at 10:30 UTC
- Kubernetes events show 1/3 pods in CrashLoopBackOff
- Pod describe shows max_connections reached

**Timeline**:
- 10:28 UTC: Traffic spike to 3x normal
- 10:30 UTC: First connection errors
- 10:32 UTC: Pod restarts begin

**Recommendation**: Increase database connection pool limit from 100 to 250
EOF
)"
```

### 2. Update Issue Status
```bash
# Change state to "In Progress"
linearis issues update ENG-1234 --state "In Progress"

# Change state to "Done"
linearis issues update ENG-1234 --state "Done"

# Common states: "Backlog", "Todo", "In Progress", "In Review", "Done", "Canceled"
```

### 3. Update Priority
```bash
# Set priority (1 = Urgent, 2 = High, 3 = Medium, 4 = Low)
linearis issues update ENG-1234 --priority 1

# Lower priority after resolution
linearis issues update ENG-1234 --priority 4
```

### 4. Add Labels
```bash
# Add labels (comma-separated)
linearis issues update ENG-1234 --labels "bug,production,database"

# Add labels (adding mode - default)
linearis issues update ENG-1234 --labels "investigating" --label-by adding

# Replace all labels (overwriting mode)
linearis issues update ENG-1234 --labels "resolved,production" --label-by overwriting

# Clear all labels
linearis issues update ENG-1234 --clear-labels
```

### 5. Update Multiple Fields
```bash
# Update status, priority, and add comment in sequence
linearis issues update ENG-1234 \
  --state "In Progress" \
  --priority 2 \
  --labels "investigating,production"

linearis comments create ENG-1234 --body "Started investigation - checking GCP logs and K8s events"
```

### 6. Update Title or Description
```bash
# Update title
linearis issues update ENG-1234 --title "API Gateway connection pool exhaustion in production"

# Update description
linearis issues update ENG-1234 --description "$(cat <<'EOF'
Production issue: API gateway pods crashing due to database connection pool exhaustion.

Impact: 30% of requests failing
Started: 2025-12-24 10:28 UTC
Environment: production (example-production project)
EOF
)"
```

## Output Management

**Log updates for audit trail**:
```bash
# Log comment creation
linearis comments create ENG-1234 --body "Investigation complete" | tee -a /tmp/linear-updates-$(date +%Y%m%d).log

# Log status updates
echo "[$(date)] Updated ENG-1234 to 'Done'" >> /tmp/linear-updates.log
linearis issues update ENG-1234 --state "Done"
```

## Workflow Pattern

**Complete debugging → Linear update workflow**:
```bash
# 1. Read issue for context
linearis issues read ENG-1234 > /tmp/issue-ENG-1234.json

# 2. Debug (using platform debugging skills)
# ... debugging steps ...

# 3. Add findings to issue
linearis comments create ENG-1234 --body "$(cat <<'EOF'
## Root Cause Analysis

Found database connection pool exhaustion.

See attached logs:
- GCP logs: /tmp/gcp-errors-20251224.json
- K8s events: /tmp/k8s-events-20251224.txt
EOF
)"

# 4. Update status
linearis issues update ENG-1234 \
  --state "In Progress" \
  --labels "root-cause-identified"

# 5. After fix is deployed
linearis comments create ENG-1234 --body "Fix deployed, monitoring for 24h"
linearis issues update ENG-1234 --state "Done"
```

## Tips

- Use heredoc for multi-line comments with formatting
- Include timestamps in comments for timeline clarity
- Reference log files saved to /tmp in comments
- Update status incrementally (Backlog → In Progress → Done)
- Add labels for categorization and filtering
- Priority 1 (Urgent) should be reserved for production incidents
- Use `--body` with heredoc to preserve markdown formatting in comments
- Save comment text to /tmp first if very long, then reference file
