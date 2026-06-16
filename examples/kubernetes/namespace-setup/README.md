# Kubernetes Example: Namespace Setup

This example demonstrates a production-grade Kubernetes namespace configuration following the
[Kubernetes Standards](../../docs/standards/kubernetes-standards.md).

---

## What This Creates

- Namespace with standard labels
- ResourceQuota for CPU/memory limits
- LimitRange for container defaults
- Default deny-all NetworkPolicy
- Allow-DNS NetworkPolicy
- ServiceAccount for workloads
- RBAC Role and RoleBinding

## Usage

```bash
# Apply the namespace setup
kubectl apply -f examples/kubernetes/namespace-setup/

# Verify
kubectl get all -n platform-tst
kubectl get networkpolicies -n platform-tst
kubectl get resourcequota -n platform-tst
kubectl get limitrange -n platform-tst
```

## Security Notes

- Default deny-all NetworkPolicy blocks all ingress and egress
- Add explicit allow policies as needed for your workloads
- ResourceQuota prevents runaway resource consumption
- LimitRange provides defaults for containers without explicit requests/limits
