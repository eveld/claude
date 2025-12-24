---
name: k8s-awareness
description: ALWAYS check before using kubectl commands. Guide for Kubernetes-related skills.
---

# Kubernetes Skills Guide

You have specialized Kubernetes debugging skills. Use these instead of raw kubectl commands for consistent, well-documented workflows.

## Decision Tree

**Checking if pods are running?**
→ Use `query-kubernetes` skill
- Better than: Running raw `kubectl get pods` commands
- Example: "Check pod status in production namespace"

**Need to view pod logs or events?**
→ Use `query-kubernetes` skill
- Includes: logs, describe, events commands
- Example: "Get logs from api-gateway pod"

**Specific pod crashing or failing?**
→ Use `debug-kubernetes-container` skill
- Launches ephemeral debug container in running pod
- Example: "Debug the failing pod api-gateway-xyz"

## Available Kubernetes Skills

| Purpose | Skill |
|---------|-------|
| Query resources (pods, deployments, services) | query-kubernetes |
| Debug live pods with ephemeral containers | debug-kubernetes-container |

## When to Use Raw kubectl

Only use kubectl directly when:
- Running one-off commands not covered by skills
- User explicitly requests a specific kubectl command
- Debugging the skill itself

For systematic Kubernetes work, use the specialized skills above.

## Common kubectl Commands

**Covered by skills**:
- `kubectl get` → Use `query-kubernetes`
- `kubectl describe` → Use `query-kubernetes`
- `kubectl logs` → Use `query-kubernetes`
- `kubectl debug` → Use `debug-kubernetes-container`

**Not covered yet** (use directly):
- `kubectl apply`, `kubectl delete`, `kubectl edit` (destructive operations)
- `kubectl port-forward`, `kubectl exec` (interactive operations)

## Authentication

Check context before any kubectl operation:
```bash
kubectl config current-context
kubectl config view --minify
```
