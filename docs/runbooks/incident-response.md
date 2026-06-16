# Incident Response Runbook

Use this runbook as the starting point for any platform incident. Adapt steps based on the specific incident.

---

## Incident Classification

| Severity | Impact | Response Time | Examples |
|---|---|---|---|
| **SEV1** | Total service outage, data loss | Immediate (< 15 min) | Production cluster down, database unavailable |
| **SEV2** | Major degradation, partial outage | < 30 minutes | High error rates, critical feature unavailable |
| **SEV3** | Minor degradation, workaround available | < 2 hours | Elevated latency, non-critical feature down |
| **SEV4** | Minimal impact, planned work | Next business day | Minor alert noise, cosmetic issues |

---

## Phase 1: Declaration

1. **Detect**: Identify the incident from an alert, user report, or monitoring dashboard.
2. **Assess severity**: Classify using the table above. When in doubt, escalate to a higher severity.
3. **Declare**: Post in the incident Slack channel:
   ```
   INCIDENT DECLARED: [SEV1/2/3] - <brief description>
   IC: @your-name
   Status: Investigating
   Bridge: <call link>
   ```
4. **Assign Incident Commander (IC)**: The person who declares is initially the IC.
5. **Open incident issue**: Use the [Incident template](.github/ISSUE_TEMPLATE/incident.md).

---

## Phase 2: Communication

Update the incident channel every **15 minutes** for SEV1, **30 minutes** for SEV2:

```
[UPDATE - HH:MM UTC]
Status: Investigating / Identified / Mitigating / Resolved
Impact: <current impact description>
Next update: HH:MM UTC
```

---

## Phase 3: Investigation

### Initial Checks

1. **Check monitoring dashboards** — Grafana overview, error rates, latency.
2. **Check alerts** — Alertmanager active alerts; which fired first?
3. **Check recent changes** — What was deployed in the last hour? Last day?
4. **Check cluster health**:

   ```bash
   kubectl get nodes
   kubectl get pods --all-namespaces | grep -v Running
   kubectl top nodes
   kubectl top pods --all-namespaces
   ```

5. **Check application logs**:

   ```bash
   kubectl logs -n <namespace> deployment/<app> --tail=100 --since=30m
   ```

6. **Check events**:

   ```bash
   kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -20
   ```

### Common Failure Patterns

| Symptom | Likely Cause | Investigation |
|---|---|---|
| Pods in `CrashLoopBackOff` | Application error, bad config, OOM | Check pod logs and events |
| Pods in `Pending` | Insufficient resources, node issues | `kubectl describe pod <pod>` |
| High error rate | Dependency failure, bad deployment | Check upstream deps, recent deploys |
| High latency | Resource contention, slow query | Check CPU/memory, database metrics |
| Alert firing but service ok | Stale alert, wrong threshold | Review alert query in Grafana |

---

## Phase 4: Mitigation

Apply the fastest available mitigation first, even if it is not the root cause fix.

### Rollback Deployment

```bash
# ArgoCD rollback
argocd app history <app-name>
argocd app rollback <app-name> <revision>

# Kubernetes rollback (if not using ArgoCD)
kubectl rollout undo deployment/<app> -n <namespace>
kubectl rollout status deployment/<app> -n <namespace>
```

### Scale Up

```bash
kubectl scale deployment/<app> --replicas=5 -n <namespace>
```

### Restart Pods

```bash
kubectl rollout restart deployment/<app> -n <namespace>
```

### Isolate Traffic

```bash
# Remove pod from service selector to isolate a bad pod
kubectl label pod <pod-name> app=<app>-isolated --overwrite -n <namespace>
```

---

## Phase 5: Resolution

1. **Confirm resolution**: Verify error rates, latency, and alerts return to normal.
2. **Announce resolution**:
   ```
   INCIDENT RESOLVED: [SEV] - <brief description>
   Duration: <start> to <end> (<duration>)
   Root cause: <brief description>
   Post-mortem: <link to issue>
   ```
3. **Close the incident issue** with resolution details.
4. **Schedule post-mortem** within 5 business days for SEV1/SEV2.

---

## Phase 6: Post-Mortem

Complete the incident issue with:

- Timeline of events
- Root cause analysis
- Contributing factors
- Action items with owners and due dates
- Lessons learned

Post-mortems are blameless. The goal is to improve the system, not assign blame.

---

## Escalation

| Situation | Action |
|---|---|
| SEV1 not resolving in 30 min | Page platform lead |
| SEV1 involving data loss | Notify engineering manager immediately |
| Security incident suspected | Contact security team immediately |
| External vendor issue | Open vendor support ticket and note ticket number |

---

## Useful Commands Reference

```bash
# Check all pods in a namespace
kubectl get pods -n <namespace> -o wide

# Describe a failing pod
kubectl describe pod <pod-name> -n <namespace>

# Get pod logs
kubectl logs <pod-name> -n <namespace> --previous --tail=100

# Check resource usage
kubectl top pods -n <namespace>

# Check HPA status
kubectl get hpa -n <namespace>

# Check PVC status
kubectl get pvc -n <namespace>

# Check endpoints (is service routing to pods?)
kubectl get endpoints <service-name> -n <namespace>

# Check recent events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```
