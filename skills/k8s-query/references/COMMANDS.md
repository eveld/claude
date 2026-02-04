# Common Kubernetes Query Commands

Reference guide for kubectl queries. See main SKILL.md for usage workflow.

## Get Resources

### Pods
```bash
# Get all pods in namespace
kubectl get pods -n <namespace>

# Get pods with labels
kubectl get pods -n production -l app=api-gateway

# Get pods across all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A

# Get pods with more info (IP, node, etc.)
kubectl get pods -n <namespace> -o wide

# Get pod in JSON/YAML
kubectl get pod <pod-name> -n <namespace> -o json
kubectl get pod <pod-name> -n <namespace> -o yaml
```

### Deployments
```bash
# Get all deployments in namespace
kubectl get deployments -n <namespace>

# Get deployment with labels
kubectl get deployments -n production -l app=api-gateway

# Get deployment details
kubectl get deployment <deployment-name> -n <namespace> -o wide
```

### Services
```bash
# Get all services in namespace
kubectl get services -n <namespace>

# Get service with labels
kubectl get services -n production -l app=api-gateway

# Get service endpoints
kubectl get endpoints <service-name> -n <namespace>
```

### All Resources
```bash
# Get all resources in namespace
kubectl get all -n <namespace>

# Get specific resource types
kubectl get pods,deployments,services -n <namespace>
```

## Describe Resources (Detailed Info)

```bash
# Describe pod (includes events)
kubectl describe pod <pod-name> -n <namespace>

# Describe deployment
kubectl describe deployment <deployment-name> -n <namespace>

# Describe service
kubectl describe service <service-name> -n <namespace>

# Describe node
kubectl describe node <node-name>
```

**When to use describe:**
- Investigating pod failures (see events at bottom)
- Checking resource limits and requests
- Viewing volume mounts
- Seeing recent events for resource

## Get Logs

### Basic Logs
```bash
# Get pod logs (current container)
kubectl logs <pod-name> -n <namespace>

# Get logs with tail limit (last N lines)
kubectl logs <pod-name> --tail=200 -n <namespace>

# Get logs from all containers in pod
kubectl logs <pod-name> --all-containers=true -n <namespace>

# Get logs from specific container in multi-container pod
kubectl logs <pod-name> -c <container-name> -n <namespace>
```

### Crash Debugging
```bash
# Get previous container logs (after crash/restart)
kubectl logs <pod-name> --previous -n <namespace>

# Get previous logs from specific container
kubectl logs <pod-name> -c <container-name> --previous -n <namespace>
```

### Streaming Logs
```bash
# Follow logs (stream live)
kubectl logs -f <pod-name> -n <namespace>

# Follow with tail
kubectl logs -f <pod-name> --tail=100 -n <namespace>
```

### Logs by Label
```bash
# Get logs from all pods matching label
kubectl logs -l app=api-gateway -n <namespace>

# Follow logs from all matching pods
kubectl logs -f -l app=api-gateway -n <namespace>
```

## Get Events

```bash
# Get all events in namespace
kubectl get events -n <namespace>

# Get events sorted by timestamp (most recent last)
kubectl get events --sort-by='.lastTimestamp' -n <namespace>

# Get events for specific resource
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace>

# Get events for specific type
kubectl get events --field-selector type=Warning -n <namespace>

# Get events across all namespaces
kubectl get events --all-namespaces
kubectl get events -A
```

**Event types:**
- `Normal` - Normal operations (scheduled, created, started)
- `Warning` - Issues (failed health checks, image pull errors, OOM killed)

## Resource Metrics

Requires metrics-server to be installed in cluster.

```bash
# Pod resource usage (CPU, memory)
kubectl top pod -n <namespace>

# Specific pod metrics
kubectl top pod <pod-name> -n <namespace>

# Pods sorted by CPU
kubectl top pod -n <namespace> --sort-by=cpu

# Pods sorted by memory
kubectl top pod -n <namespace> --sort-by=memory

# Node resource usage
kubectl top node

# Nodes sorted by CPU
kubectl top node --sort-by=cpu
```

## Output Formats

### Common Formats
```bash
# Wide format (additional columns: IP, node, etc.)
kubectl get pods -n <namespace> -o wide

# YAML format (full resource definition)
kubectl get pod <pod-name> -n <namespace> -o yaml

# JSON format (full resource definition)
kubectl get pod <pod-name> -n <namespace> -o json
```

### JSONPath (Custom Field Extraction)
```bash
# Get all pod names
kubectl get pods -n <namespace> -o jsonpath='{.items[*].metadata.name}'

# Get pod IPs
kubectl get pods -n <namespace> -o jsonpath='{.items[*].status.podIP}'

# Get image names
kubectl get pods -n <namespace> -o jsonpath='{.items[*].spec.containers[*].image}'

# Complex extraction with range
kubectl get pods -n <namespace> -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```

### Go Template (Custom Formatting)
```bash
# Custom columns
kubectl get pods -n <namespace> -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

# With go-template
kubectl get pods -n <namespace> -o go-template='{{range .items}}{{.metadata.name}} {{.status.phase}}{{"\n"}}{{end}}'
```

## Label Selectors

```bash
# Single label
kubectl get pods -l app=api-gateway -n <namespace>

# Multiple labels (AND)
kubectl get pods -l app=api,tier=frontend -n <namespace>

# Label negation
kubectl get pods -l app!=api-gateway -n <namespace>

# Set-based selectors
kubectl get pods -l 'environment in (production, staging)' -n <namespace>
kubectl get pods -l 'app notin (api, web)' -n <namespace>
```

## Field Selectors

```bash
# By status
kubectl get pods --field-selector status.phase=Running -n <namespace>
kubectl get pods --field-selector status.phase=Failed -n <namespace>

# By metadata
kubectl get pods --field-selector metadata.namespace=production

# Combined
kubectl get pods --field-selector status.phase=Running,metadata.namespace=production
```
