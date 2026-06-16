# Kubernetes Standards

Standards for all Kubernetes manifests and configurations across the platform.

---

## Security Context

Every pod and container must include a security context. Apply at both pod and container level.

### Pod-Level Security Context

```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
```

### Container-Level Security Context

```yaml
containers:
  - name: my-app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
          - ALL
```

### Why These Settings?

| Setting | Purpose |
|---|---|
| `runAsNonRoot: true` | Prevents root container execution |
| `allowPrivilegeEscalation: false` | Blocks `setuid`/`setgid` escalation |
| `capabilities.drop: [ALL]` | Removes all Linux capabilities |
| `seccompProfile: RuntimeDefault` | Applies default syscall filtering |
| `readOnlyRootFilesystem: true` | Prevents filesystem tampering |

---

## Resource Management

Resource requests and limits are **mandatory** on all containers in production namespaces.

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

### Guidelines

- Set requests based on measured baseline consumption.
- Set limits at 3-5x requests for CPU-bound workloads.
- For memory, set limits close to requests to catch OOM issues early.
- Never use `limits.cpu` in `prd` if the workload is latency-sensitive — use requests only.
- Use VPA (Vertical Pod Autoscaler) in recommendation mode to calibrate requests.

---

## Probes

Liveness and readiness probes are **required** for all long-running workloads.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 3

startupProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 30
```

### Probe Design Principles

- Liveness probes should only fail on unrecoverable states (deadlock, panic).
- Readiness probes should fail when the pod cannot serve traffic (warming up, dependency unavailable).
- Startup probes allow slow-starting containers to avoid premature liveness failures.
- Never make liveness probes dependent on external services — only internal state.

---

## Labels

All Kubernetes resources must include these labels at minimum:

```yaml
metadata:
  labels:
    app: my-application
    environment: tst
    managed-by: helm
    version: "1.2.0"
    team: platform
```

### Standard Label Keys

| Key | Example | Required |
|---|---|---|
| `app` | `my-application` | Yes |
| `environment` | `tst` | Yes |
| `managed-by` | `helm` | Yes |
| `version` | `1.2.0` | Recommended |
| `team` | `platform` | Recommended |
| `component` | `frontend` | When applicable |

---

## RBAC

Apply least-privilege RBAC. Grant the narrowest `verbs` and `resources` that the workload requires.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
  namespace: my-namespace
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["my-app-secret"]
    verbs: ["get"]
```

### RBAC Guidelines

- Always use `Role`/`RoleBinding` over `ClusterRole`/`ClusterRoleBinding` unless cluster-wide access is required.
- Use `resourceNames` to restrict access to specific named resources where possible.
- Avoid `*` in `verbs` or `resources` — enumerate explicitly.
- Never grant `create`/`update`/`delete` on `secrets` unless required.
- ServiceAccounts should be workload-specific — do not share the default service account.

---

## Network Policies

Default deny-all with explicit allow rules. Apply to all namespaces.

```yaml
# Default deny all ingress and egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: my-namespace
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
# Allow DNS resolution
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: my-namespace
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
---
# Allow specific ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-frontend
  namespace: my-namespace
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - port: 8080
```

---

## Namespaces

Namespaces should follow the pattern `<team>-<env>` and include resource quotas and limit ranges.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: platform-tst
  labels:
    team: platform
    environment: tst
    managed-by: terraform
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: platform-tst-quota
  namespace: platform-tst
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "20"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: platform-tst-limits
  namespace: platform-tst
spec:
  limits:
    - type: Container
      default:
        cpu: "200m"
        memory: "256Mi"
      defaultRequest:
        cpu: "50m"
        memory: "64Mi"
```

---

## Production Considerations

### Pod Disruption Budgets

Always define a PDB for production workloads with more than one replica:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
  namespace: my-namespace
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: my-application
```

### Topology Spread

Spread pods across availability zones for resilience:

```yaml
spec:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchLabels:
          app: my-application
```

### Anti-Affinity

Avoid co-locating replicas on the same node:

```yaml
spec:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app: my-application
            topologyKey: kubernetes.io/hostname
```

---

## Failure Scenarios

| Scenario | Mitigation |
|---|---|
| Node failure | Multiple replicas + pod anti-affinity |
| AZ failure | Topology spread constraints across zones |
| OOM kill | Correct memory limits based on profiling |
| Slow start | Startup probes with adequate `failureThreshold` |
| Cascade failure | Network policies, circuit breakers |
| Secret rotation | ExternalSecrets with auto-refresh |

---

## Future Roadmap

- Adopt OPA/Gatekeeper policies for security context enforcement
- Implement Hierarchical Namespaces (HNC) for team isolation
- Evaluate Cilium for eBPF-based network policies
- Adopt Kyverno for policy-as-code alongside admission control
