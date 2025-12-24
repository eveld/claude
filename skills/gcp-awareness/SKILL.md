---
name: gcp-awareness
description: ALWAYS check before using gcloud commands. Guide for GCP-related skills and tools.
---

# GCP Skills Guide

You have specialized GCP debugging skills. Use these instead of raw gcloud commands for consistent, well-documented workflows.

## Decision Tree

**Searching Cloud Logging for errors or traces?**
→ Use `query-gcp-logs` skill
- Better than: Running raw `gcloud logging read` commands
- Example: "Find ERROR logs for api-gateway service"

**Need to understand GCP IAP authentication?**
→ Check documentation or use WebFetch
- GCP IAP tokens: `gcloud auth print-identity-token`
- Use for Grafana, ArgoCD, Temporal access

## Available GCP Skills

| Purpose | Skill |
|---------|-------|
| Query Cloud Logging | query-gcp-logs |

## When to Use Raw gcloud

Only use gcloud directly when:
- Running one-off commands not covered by skills
- User explicitly requests a specific gcloud command
- Debugging the skill itself

For systematic GCP work, use the specialized skills above.

## Common GCP Tools

- `gcloud` - Primary CLI tool
- `gcloud logging read` - Cloud Logging queries (use `query-gcp-logs` skill)
- `gcloud auth print-identity-token` - Get IAP tokens for service access

## Authentication

Check authentication before any GCP operation:
```bash
gcloud auth list
gcloud config get-value project
```
