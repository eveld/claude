---
name: linear-awareness
description: ALWAYS check before working with Linear issues. Guide for Linear-related skills for ticket management and debugging workflows.
---

# Linear Skills Guide

You have specialized Linear issue management skills. Use these for structured ticket workflows during debugging investigations.

## Decision Tree

### Skills vs Agents

**Simple issue fetch or update?**
→ Use Linear skills
- `linear-issues` - Fetch, list, search issues (single linearis command)
- `linear-update` - Update issue, add comments
- Example: "Get details for ENG-1234"
- Use when: Single issue, straightforward query/update

**Complex investigation requiring analysis?**
→ Use Task tool with Linear agents (conserves context)
- `linear-locator` - Find issues by criteria, save to /tmp
- `linear-analyzer` - Extract debugging context, parse technical details
- `linear-pattern-finder` - Find patterns across issues, detect recurring problems
- Use when: Multi-issue analysis, pattern detection, trend analysis

### When to Use Which Agent

**Just need to find issues broadly?**
→ Use `linear-locator` agent only
- Lists/searches issues by team, label, state, text
- Saves filtered results to /tmp
- Example: "Find all FileB-related issues across teams"

**Investigating single issue for debugging?**
→ Use `linear-locator` + `linear-analyzer` agents
- Locator: Find issue and related issues
- Analyzer: Extract error messages, URLs, technical details
- Example: "Analyze ENG-1234 for debugging context"

**Need to find patterns or recurring problems?**
→ Use all three: `linear-locator` + `linear-analyzer` + `linear-pattern-finder`
- Locator: Fetch issues by criteria
- Analyzer: Parse each issue for technical details
- Pattern-finder: Correlate across issues, find recurring themes, temporal trends
- Example: "Find recurring VCS permission errors across last 2 months"

**Adding debugging findings to a ticket?**
→ Use `linear-update` skill
- Better than: Running raw `linearis comments create` commands
- Example: "Add root cause analysis to ENG-1234"

**Updating issue status after investigation?**
→ Use `linear-update` skill
- Includes: status, priority, labels updates
- Example: "Mark ENG-1234 as In Progress"

## Available Linear Tools

| Type | Name | Purpose |
|------|------|---------|
| Skill | linear-issues | Simple queries (single linearis command) |
| Skill | linear-update | Update issues, add comments |
| Agent | linear-locator | Find issues by criteria across teams |
| Agent | linear-analyzer | Extract debugging context from issues |
| Agent | linear-pattern-finder | Find patterns, recurring problems, trends |

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
- `linearis issues read` → Use `linear-issues`
- `linearis issues list` → Use `linear-issues`
- `linearis issues search` → Use `linear-issues`
- `linearis comments create` → Use `linear-update`
- `linearis issues update` → Use `linear-update`

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
1. `linear-issues` → Fetch ticket context
2. Platform investigation → Use GCP and K8s skills for debugging
3. `linear-update` → Add findings to ticket
4. `linear-update` → Update status to "Done"

**Example**:
```
User: "Debug issue ENG-1234"
Claude: [Checks linear-awareness] → Uses linear-issues
        [Investigates using GCP/K8s skills]
        [Checks linear-awareness] → Uses linear-update
```
