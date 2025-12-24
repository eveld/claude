---
name: linear-awareness
description: ALWAYS check before working with Linear issues. Guide for Linear-related skills for ticket management and debugging workflows.
---

# Linear Skills Guide

You have specialized Linear issue management skills. Use these for structured ticket workflows during debugging investigations.

## Decision Tree

**Fetching ticket details for debugging context?**
→ Use `query-linear-issues` skill
- Better than: Running raw `linearis issues read` commands
- Example: "Get details for ENG-1234"

**Searching for related issues?**
→ Use `query-linear-issues` skill
- Includes: search, list commands
- Example: "Find issues about api-gateway errors"

**Adding debugging findings to a ticket?**
→ Use `update-linear-issue` skill
- Better than: Running raw `linearis comments create` commands
- Example: "Add root cause analysis to ENG-1234"

**Updating issue status after investigation?**
→ Use `update-linear-issue` skill
- Includes: status, priority, labels updates
- Example: "Mark ENG-1234 as In Progress"

## Available Linear Skills

| Purpose | Skill |
|---------|-------|
| Fetch, list, search issues | query-linear-issues |
| Update issues, add comments | update-linear-issue |

## When to Use Raw linearis

Only use linearis CLI directly when:
- Running one-off commands not covered by skills
- User explicitly requests a specific linearis command
- Creating new issues (`linearis issues create`)
- Managing projects, teams, users (non-issue operations)
- Debugging the skill itself

For systematic ticket workflows (read → debug → update), use the specialized skills above.

## Common linearis Commands

**Covered by skills**:
- `linearis issues read` → Use `query-linear-issues`
- `linearis issues list` → Use `query-linear-issues`
- `linearis issues search` → Use `query-linear-issues`
- `linearis comments create` → Use `update-linear-issue`
- `linearis issues update` → Use `update-linear-issue`

**Not covered yet** (use directly):
- `linearis issues create` (issue creation)
- `linearis projects`, `linearis teams`, `linearis users` (non-issue operations)

## Authentication

Check linearis CLI is available and authenticated:
```bash
linearis --version
linearis issues list --limit 1
```

Note: Set `LINEARIS_API_TOKEN` environment variable or use `--api-token` flag.

## Integration with Debugging Workflow

Linear skills integrate with platform debugging:

**Workflow**:
1. `query-linear-issues` → Fetch ticket context
2. `debugging-awareness` → Systematic investigation (GCP + K8s + Instruqt)
3. `update-linear-issue` → Add findings to ticket
4. `update-linear-issue` → Update status to "Done"

**Example**:
```
User: "Debug issue ENG-1234"
Claude: [Checks linear-awareness] → Uses query-linear-issues
        [Checks debugging-awareness] → Uses GCP/K8s/Instruqt skills
        [Checks linear-awareness] → Uses update-linear-issue
```
