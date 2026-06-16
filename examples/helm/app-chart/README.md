# Helm Example: Generic Application Chart

This example demonstrates a production-grade Helm chart following the
[Helm Standards](../../docs/standards/helm-standards.md).

---

## What This Chart Provides

- Deployment with security context and resource limits
- Service for internal cluster communication
- ServiceAccount with no automount
- ConfigMap for application configuration
- NetworkPolicy with deny-all default
- PodDisruptionBudget for production availability
- HPA for horizontal scaling
- ServiceMonitor for Prometheus metrics (optional)

## Usage

```bash
# Lint the chart
helm lint examples/helm/app-chart/

# Render templates (dry run)
helm template my-app examples/helm/app-chart/ \
  -f examples/helm/app-chart/values-tst.yaml

# Install to tst
helm upgrade --install my-app examples/helm/app-chart/ \
  -f examples/helm/app-chart/values-tst.yaml \
  -n my-app-tst \
  --create-namespace

# Diff before upgrade
helm diff upgrade my-app examples/helm/app-chart/ \
  -f examples/helm/app-chart/values-tst.yaml
```

## Values Reference

| Key | Default | Description |
|---|---|---|
| `replicaCount` | `1` | Number of replicas |
| `image.repository` | `registry.example.com/app` | Container image repository |
| `image.tag` | `""` (uses `appVersion`) | Image tag |
| `resources.requests.cpu` | `100m` | CPU request |
| `resources.requests.memory` | `128Mi` | Memory request |
| `autoscaling.enabled` | `false` | Enable HPA |
| `monitoring.serviceMonitor.enabled` | `false` | Enable Prometheus ServiceMonitor |
| `networkPolicy.enabled` | `true` | Enable NetworkPolicy |
