---
name: kubernetes
description: Query Kubernetes resources (pods, deployments, services, events). Use when checking cluster state and resource status.
---

# Query Kubernetes Resources

Check status of Kubernetes pods, deployments, services, and events.

## When to Use

- Checking if pods are running
- Viewing pod/deployment status
- Investigating pod failures or restarts
- Checking resource events and logs

## Pre-flight Checks

### Authentication and Context
```bash
# Check kubectl context
kubectl config current-context || {
  echo "No kubectl context. Run: kubectl config use-context <context>"
  exit 1
}

# Show current context and namespace
CURRENT_CONTEXT=$(kubectl config current-context)
CURRENT_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}' || echo 'default')
echo "K8s Context: $CURRENT_CONTEXT"
echo "Namespace: $CURRENT_NAMESPACE"

# If context suggests different environment, prompt to switch
# Example: User mentions "production namespace" but current context is "staging-cluster"
# Detect from query context and prompt:
# echo "Query mentions 'production' but current context is '$CURRENT_CONTEXT'"
# echo "Switch to production context? Run: kubectl config use-context prod-cluster"
# read -p "Continue with current context? (y/n) " -n 1 -r
```

## Common Commands

### 1. Get Resources
```bash
# Get all pods in namespace
kubectl get pods -n <namespace>

# Get pods with labels
kubectl get pods -n production -l app=api-gateway

# Get deployments
kubectl get deployments -n <namespace>

# Get services
kubectl get services -n <namespace>

# All resources
kubectl get all -n <namespace>
```

### 2. Describe Resources (Detailed Info)
```bash
# Describe pod
kubectl describe pod <pod-name> -n <namespace>

# Describe deployment
kubectl describe deployment <deployment-name> -n <namespace>

# Describe service
kubectl describe service <service-name> -n <namespace>
```

### 3. Get Logs
```bash
# Get pod logs (current)
kubectl logs <pod-name> -n <namespace>

# Get logs with tail limit
kubectl logs <pod-name> --tail=200 -n <namespace>

# Get previous container logs (after crash)
kubectl logs <pod-name> --previous -n <namespace>

# Follow logs (stream)
kubectl logs -f <pod-name> -n <namespace>

# Logs from specific container in multi-container pod
kubectl logs <pod-name> -c <container-name> -n <namespace>
```

### 4. Get Events
```bash
# Get events in namespace
kubectl get events -n <namespace>

# Get events for specific resource
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace>

# Sort by timestamp
kubectl get events --sort-by='.lastTimestamp' -n <namespace>
```

### 5. Resource Metrics (if metrics-server installed)
```bash
# Pod resource usage
kubectl top pod -n <namespace>

# Node resource usage
kubectl top node

# Specific pod metrics
kubectl top pod <pod-name> -n <namespace>
```

## Output Formats

- `-o wide` - Additional columns (IP, node, etc.)
- `-o yaml` - Full YAML output
- `-o json` - Full JSON output
- `-o jsonpath='{.items[*].metadata.name}'` - Custom field extraction

## Output Management

**For large outputs or consecutive analysis**, pipe to tmp file:
```bash
# Save pod list to tmp file
kubectl get pods -n production -o json > /tmp/k8s-pods-$(date +%Y%m%d-%H%M%S).json

# Save logs for offline analysis
kubectl logs api-gateway-xyz -n production --tail=1000 > /tmp/api-gateway-logs-$(date +%Y%m%d-%H%M%S).log

# Save events for correlation
kubectl get events -n production --sort-by='.lastTimestamp' > /tmp/k8s-events-$(date +%Y%m%d-%H%M%S).txt

# Then analyze with grep, jq, or correlate with GCP logs
grep -i error /tmp/api-gateway-logs-*.log
```

**Benefits**:
- Correlate Kubernetes events with GCP logs using timestamps
- Share debugging context with team
- Preserve state for investigation

## Tips

- Use `-n <namespace>` for all commands or set default: `kubectl config set-context --current --namespace=<namespace>`
- Use `--all-namespaces` or `-A` to search across all namespaces
- Use `-l` for label selectors: `-l app=api,tier=frontend`
- Use `--field-selector` for field-based filtering
- Check pod events with describe before checking logs
- For debugging sessions, save logs/events to /tmp for correlation across tools
