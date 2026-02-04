# GCP Log Entry Structure

Understanding the structure of GCP log entries for effective querying.

## Kubernetes Container Log Entry

Example log entry structure for `resource.type="k8s_container"`:

```json
{
  "resource": {
    "type": "k8s_container",
    "labels": {
      "cluster_name": "core-private",
      "container_name": "service-c",
      "namespace_name": "integrations",
      "pod_name": "integrations-service-c-85f98fc5c-7mbdq",
      "project_id": "example-dev",
      "location": "europe-west1"
    }
  },
  "jsonPayload": {
    "message": "Processing request",
    "user_id": "123",
    "operation": "updateTrack",
    "duration_ms": 145
  },
  "severity": "WARNING",
  "timestamp": "2025-12-19T12:22:52.205169027Z",
  "labels": {
    "service": "api-gateway",
    "version": "v2.1.0"
  }
}
```

## Key Fields

### resource.type
Identifies the resource type:
- `k8s_container` - Kubernetes container
- `k8s_pod` - Kubernetes pod
- `cloud_run_revision` - Cloud Run
- `gce_instance` - Compute Engine

### resource.labels
Resource-specific labels. For K8s containers:
- `cluster_name` - GKE cluster name
- `container_name` - Container (usually service name)
- `namespace_name` - K8s namespace
- `pod_name` - Specific pod instance
- `location` - GCP region
- `project_id` - GCP project

### Payload Types

**jsonPayload**: Structured JSON logs
```json
"jsonPayload": {
  "message": "User action",
  "user_id": "123",
  "nested": {
    "field": "value"
  }
}
```

**textPayload**: Plain text logs
```json
"textPayload": "2025-12-19 12:22:52 ERROR: Connection failed"
```

### severity
Log level:
- `DEFAULT` - Default/INFO level
- `DEBUG` - Debug information
- `INFO` - Informational
- `NOTICE` - Normal but significant
- `WARNING` - Warning conditions
- `ERROR` - Error conditions
- `CRITICAL` - Critical conditions
- `ALERT` - Action must be taken immediately
- `EMERGENCY` - System is unusable

### timestamp
ISO 8601 format with timezone:
```
"timestamp": "2025-12-19T12:22:52.205169027Z"
```

### labels
Custom key-value labels added to logs:
```json
"labels": {
  "service": "api-gateway",
  "version": "v2.1.0",
  "environment": "production"
}
```

## Querying by Field

```bash
# Query resource labels
gcloud logging read 'resource.labels.container_name="service-b"'

# Query jsonPayload fields
gcloud logging read 'jsonPayload.user_id="123"'

# Query custom labels
gcloud logging read 'labels.service="api-gateway"'

# Query severity
gcloud logging read 'severity>=ERROR'

# Query timestamp
gcloud logging read 'timestamp>="2025-12-19T12:00:00Z"'
```
