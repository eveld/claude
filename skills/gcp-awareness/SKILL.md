---
name: gcp-awareness
description: ALWAYS check before using gcloud commands. Guide for GCP-related skills and tools.
---

# GCP Skills Guide

You have specialized GCP debugging skills. Use these instead of raw gcloud commands for consistent, well-documented workflows.

## Decision Tree

### Skills vs Agents

**Simple, single gcloud command query?**
→ Use `gcp-logs` skill
- Better than: Running raw `gcloud logging read` commands
- Example: "Find ERROR logs for api-gateway service"
- Use when: Quick log fetch, single service, no correlation needed

**Complex investigation requiring multiple steps?**
→ Use Task tool with GCP agents (conserves context)
- `gcp-locator` - Fetch logs from multiple services, save to /tmp
- `gcp-analyzer` - Filter logs, diagnose service issues, check IAM
- `gcp-pattern-finder` - Correlate logs across services, build timelines
- Use when: Multi-service investigation, correlation, pattern detection

### When to Use Which Agent

**Just need to fetch logs broadly?**
→ Use `gcp-locator` agent only
- Fetches logs from multiple services/time ranges
- Saves to /tmp for later analysis
- Example: "Get all ERROR logs from vcs-storage, vcs-service, backend for last hour"

**Investigating single service issue?**
→ Use `gcp-locator` + `gcp-analyzer` agents
- Locator: Fetch relevant logs
- Analyzer: Filter, diagnose root cause, check IAM/roles
- Example: "Debug vcs-storage permission errors"

**Need to correlate across services or find patterns?**
→ Use all three: `gcp-locator` + `gcp-analyzer` + `gcp-pattern-finder`
- Locator: Fetch from all relevant services
- Analyzer: Filter each service's logs
- Pattern-finder: Correlate by trace_id, build timelines, find patterns
- Example: "Trace request flow across vcs-service → vcs-storage → backend"

**Need to understand GCP IAP authentication?**
→ Check documentation or use WebFetch
- GCP IAP tokens: `gcloud auth print-identity-token`
- Use for Grafana, ArgoCD, Temporal access

## Available GCP Tools

| Type | Name | Purpose |
|------|------|---------|
| Skill | gcp-logs | Simple log queries (single gcloud command) |
| Agent | gcp-locator | Fetch logs from multiple services/ranges |
| Agent | gcp-analyzer | Analyze service logs, diagnose issues |
| Agent | gcp-pattern-finder | Correlate logs, find patterns, build timelines |

## When to Use Raw gcloud

Only use gcloud directly when:
- Running one-off commands not covered by skills
- User explicitly requests a specific gcloud command
- Debugging the skill itself

For systematic GCP work, use the specialized skills above.

## Common GCP Tools

- `gcloud` - Primary CLI tool
- `gcloud logging read` - Cloud Logging queries (use `gcp-logs` skill)
- `gcloud auth print-identity-token` - Get IAP tokens for service access

## Authentication

Check authentication before any GCP operation:
```bash
gcloud auth list
gcloud config get-value project
```
