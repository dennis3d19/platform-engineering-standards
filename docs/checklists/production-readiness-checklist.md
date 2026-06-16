# Production Readiness Checklist

Use this checklist before promoting a workload to production. All items marked **Required** must be completed.
Items marked **Recommended** should be completed where applicable.

---

## Application Readiness

### Code Quality

- [ ] **Required** — All CI checks pass (lint, test, security scan)
- [ ] **Required** — No known high or critical CVEs in dependencies
- [ ] **Required** — No secrets committed to the repository
- [ ] **Required** — Code has been reviewed by at least one team member
- [ ] **Recommended** — Code coverage meets the project minimum

### Configuration

- [ ] **Required** — All environment-specific values are in environment-specific config files
- [ ] **Required** — No hardcoded credentials, URLs, or environment-specific values in code
- [ ] **Required** — All secrets are sourced from Vault via ExternalSecrets
- [ ] **Required** — Configuration is validated on startup (fail fast on missing required config)
- [ ] **Recommended** — Configuration schema is documented

---

## Kubernetes / Infrastructure

### Container

- [ ] **Required** — Image is pinned to an immutable tag or digest (not `latest`)
- [ ] **Required** — Image has been scanned for vulnerabilities
- [ ] **Required** — Container does not run as root (`runAsNonRoot: true`)
- [ ] **Required** — `allowPrivilegeEscalation: false` is set
- [ ] **Required** — `capabilities.drop: [ALL]` is set
- [ ] **Required** — `seccompProfile.type: RuntimeDefault` is set
- [ ] **Recommended** — `readOnlyRootFilesystem: true` is set

### Resources

- [ ] **Required** — CPU and memory requests are set
- [ ] **Required** — CPU and memory limits are set
- [ ] **Required** — Requests are calibrated against observed usage (not guessed)

### Probes

- [ ] **Required** — Liveness probe is configured
- [ ] **Required** — Readiness probe is configured
- [ ] **Recommended** — Startup probe is configured for slow-starting workloads

### Availability

- [ ] **Required** — At least 2 replicas are running in production
- [ ] **Required** — Pod Disruption Budget is configured
- [ ] **Required** — Pod anti-affinity is configured to avoid co-location on the same node
- [ ] **Recommended** — Topology spread constraints are set across availability zones
- [ ] **Recommended** — HPA is configured for variable workloads

### Networking

- [ ] **Required** — NetworkPolicy with deny-all default is in place
- [ ] **Required** — Explicit ingress and egress allow rules are defined
- [ ] **Recommended** — Service mesh (if in use) policies are configured

---

## Security

### Authentication and Authorisation

- [ ] **Required** — RBAC follows least-privilege
- [ ] **Required** — ServiceAccount is workload-specific (not the default SA)
- [ ] **Required** — ServiceAccount token automounting is disabled if not needed
- [ ] **Recommended** — Workload identity or IRSA is used for cloud API access

### Secrets

- [ ] **Required** — All secrets are managed via Vault + ExternalSecrets
- [ ] **Required** — Secret rotation procedure is documented
- [ ] **Required** — All tokens have an expiry date
- [ ] **Required** — `kubectl create secret` has not been used in production setup

### Data

- [ ] **Required** — No sensitive data is logged
- [ ] **Required** — Data at rest is encrypted
- [ ] **Recommended** — Data in transit uses TLS 1.2+

---

## Observability

### Metrics

- [ ] **Required** — Prometheus metrics are exposed via `/metrics`
- [ ] **Required** — ServiceMonitor is configured
- [ ] **Recommended** — Custom business metrics are exposed (request counts, error rates, latency)

### Alerting

- [ ] **Required** — At least one alert for service-down or high error rate
- [ ] **Required** — All alerts have `severity`, `runbook_url`, and a clear message
- [ ] **Required** — Alerts have been tested and fire correctly
- [ ] **Recommended** — SLO-based alerts are configured

### Logging

- [ ] **Required** — Logs are structured (JSON)
- [ ] **Required** — Log level is `info` (not `debug`) in production
- [ ] **Required** — No credentials, tokens, or PII appear in logs
- [ ] **Recommended** — Logs are centralised in a log aggregation system

### Dashboards

- [ ] **Required** — Grafana dashboard is available and stored in Git
- [ ] **Required** — Dashboard includes error rate, latency, and resource utilisation panels
- [ ] **Recommended** — Dashboard includes SLO / error budget panel

---

## Runbooks and Documentation

- [ ] **Required** — Runbook exists for common failure scenarios
- [ ] **Required** — Runbook URL is included in all alerts
- [ ] **Required** — Deployment and rollback procedure is documented
- [ ] **Required** — On-call contact is documented
- [ ] **Recommended** — Architecture diagram is up to date

---

## Deployment and Rollback

- [ ] **Required** — Deployment is managed via GitOps (ArgoCD) — no direct `kubectl apply`
- [ ] **Required** — Rollback procedure is tested and documented
- [ ] **Required** — Canary or blue/green strategy is used for high-risk changes
- [ ] **Required** — Database migrations (if any) are backward compatible with previous version

---

## Sign-off

| Role | Name | Date | Signature |
|---|---|---|---|
| Engineer | | | |
| Tech Lead | | | |
| Security Review | | | |

---

*Complete this checklist for every production promotion. Attach to the deployment pull request or change record.*
