---
name: debug-kubernetes-container
description: Launch ephemeral debug container in running pod for interactive debugging. Use when you need to debug a pod without restarting it.
---

# Debug Kubernetes Container

Launch an ephemeral debug container attached to a running pod for interactive debugging.

## When to Use

- Pod is failing but you need to inspect it live
- Need debugging tools (curl, netstat, tcpdump) not available in production container
- Want to debug without modifying production container image
- Investigating network, process, or filesystem issues in running pod

## Pre-flight Checks

### Authentication and Context
```bash
# Check kubectl context
kubectl config current-context || {
  echo "No kubectl context. Run: kubectl config use-context <context>"
  exit 1
}

# Show current context
echo "K8s Context: $(kubectl config current-context)"
```

## Workflow

### 1. Launch Debug Container

**Basic debug container**:
```bash
# Attach ephemeral debug container to running pod
kubectl debug -it <pod-name> \
  --image=nicolaka/netshoot \
  --namespace=<namespace>
```

**With specific container target** (for multi-container pods):
```bash
# Target specific container in pod
kubectl debug -it <pod-name> \
  --image=nicolaka/netshoot \
  --target=<container-name> \
  --namespace=<namespace>
```

**With custom image**:
```bash
# Use custom debug image
kubectl debug -it <pod-name> \
  --image=ubuntu:latest \
  --namespace=<namespace>
```

### 2. Common Debug Commands Inside Container

Once inside the debug container, use these commands:

**Network debugging**:
```bash
# Test HTTP endpoints
curl http://localhost:8080/health
curl -v http://database-service:5432

# Check listening ports
netstat -tulpn

# Capture network traffic
tcpdump -i any port 8080

# DNS resolution
nslookup database-service
dig +short database-service.default.svc.cluster.local
```

**Process inspection**:
```bash
# List processes
ps aux

# Monitor processes
top

# Check process details
ps aux | grep api-gateway
```

**File system inspection**:
```bash
# Check application directory
ls -la /app

# View config files
cat /app/config.yaml

# Check environment variables
env | grep API

# Check mounted volumes
df -h
mount | grep /app
```

**Container metadata**:
```bash
# Check container env
printenv

# View pod labels (if tools available)
cat /etc/podinfo/labels
```

### 3. Document and Exit

After debugging:
1. Document findings in investigation notes or Linear ticket
2. Exit debug container: `exit` or Ctrl+D
3. Debug container is automatically removed

## Recommended Debug Images

**nicolaka/netshoot** (Recommended for network debugging):
- Includes: curl, dig, netstat, tcpdump, wget, nc, nslookup
- Best for: Network connectivity, DNS, HTTP debugging
- Size: ~300MB

**busybox**:
- Includes: Basic Unix utilities
- Best for: Minimal debugging, file system inspection
- Size: ~5MB

**ubuntu:latest**:
- Includes: Full package manager (apt)
- Best for: Installing custom tools on-the-fly
- Size: ~70MB

**alpine:latest**:
- Includes: Package manager (apk)
- Best for: Lightweight debugging with custom tools
- Size: ~7MB

## Tips

- Use `--target` when debugging multi-container pods
- Debug containers share process namespace with target container
- Debug containers have access to target container's filesystem
- Use `--copy-to=<new-pod-name>` to create a copy of the pod for debugging
- Debug containers are ephemeral and removed on exit
- Check pod status before debugging: `kubectl get pod <pod-name> -n <namespace>`

## Limitations

- Requires Kubernetes 1.18+ (ephemeral containers feature)
- Some clusters may have PodSecurityPolicy restricting debug containers
- Shared PID namespace may not be available in all environments
