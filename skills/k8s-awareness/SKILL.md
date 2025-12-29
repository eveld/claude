---
name: k8s-awareness
description: ALWAYS check before using kubectl commands. Guide for Kubernetes-related skills.
---

# Kubernetes Skills Guide

You have specialized Kubernetes debugging skills. Use these instead of raw kubectl commands for consistent, well-documented workflows.

## Decision Tree

### Skills vs Agents

**Simple, single kubectl command query?**
→ Use `kubernetes` skill
- Better than: Running raw `kubectl get pods` commands
- Example: "Check pod status in production namespace"
- Use when: Quick resource check, single namespace, no correlation needed

**Complex investigation requiring multiple steps?**
→ Use Task tool with K8s agents (conserves context)
- `k8s-locator` - Find and list resources across namespaces
- `k8s-analyzer` - Diagnose pod/deployment issues, check logs/events
- `k8s-pattern-finder` - Find patterns across resources, detect infrastructure issues
- Use when: Multi-namespace investigation, pattern detection, cluster-wide issues

**Specific pod crashing or failing?**
→ Use `k8s-debug` skill
- Launches ephemeral debug container in running pod
- Example: "Debug the failing pod api-gateway-xyz"

### When to Use Which Agent

**Just need to find resources broadly?**
→ Use `k8s-locator` agent only
- Lists pods, deployments, services across namespaces
- Saves to /tmp for later analysis
- Example: "Get all pods in production, staging, development namespaces"

**Investigating single pod/service issue?**
→ Use `k8s-locator` + `k8s-analyzer` agents
- Locator: Find relevant pods/resources
- Analyzer: Diagnose health, check events, analyze logs
- Example: "Debug service-b CrashLoopBackOff"

**Need to find patterns or cluster-wide issues?**
→ Use all three: `k8s-locator` + `k8s-analyzer` + `k8s-pattern-finder`
- Locator: Fetch resources from all namespaces
- Analyzer: Diagnose specific pod failures
- Pattern-finder: Correlate across resources, detect node issues, cascade failures
- Example: "Find why multiple pods are ImagePullBackOff across namespaces"

## Available Kubernetes Tools

| Type | Name | Purpose |
|------|------|---------|
| Skill | kubernetes | Simple queries (single kubectl command) |
| Skill | k8s-debug | Launch ephemeral debug container |
| Agent | k8s-locator | Find and list resources across namespaces |
| Agent | k8s-analyzer | Diagnose pod/deployment issues |
| Agent | k8s-pattern-finder | Find patterns, cluster-wide issues |

## When to Use Raw kubectl

Only use kubectl directly when:
- Running one-off commands not covered by skills
- User explicitly requests a specific kubectl command
- Debugging the skill itself

For systematic Kubernetes work, use the specialized skills above.

## Common kubectl Commands

**Covered by skills**:
- `kubectl get` → Use `kubernetes`
- `kubectl describe` → Use `kubernetes`
- `kubectl logs` → Use `kubernetes`
- `kubectl debug` → Use `k8s-debug`

**Not covered yet** (use directly):
- `kubectl apply`, `kubectl delete`, `kubectl edit` (destructive operations)
- `kubectl port-forward`, `kubectl exec` (interactive operations)

## Authentication

Check context before any kubectl operation:
```bash
kubectl config current-context
kubectl config view --minify
```
