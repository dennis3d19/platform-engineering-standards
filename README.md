# Platform Engineering Standards

> Enterprise standards, templates, governance, and best practices for Platform Engineering teams.

---

## Background

This repository is a clean-room documentation set built to capture platform engineering standards, governance, templates, and operating guidance.

The original work was performed for employers and clients and cannot be published due to confidentiality and intellectual property restrictions.

No client code, client data, internal documentation, or proprietary configurations are included.

All standards and supporting documents published here are generic, technology-appropriate, and safe for public publication.

---

## What This Demonstrates

This repository demonstrates the following professional Platform Engineering skills:

| Skill Area | Details |
|---|---|
| **Infrastructure as Code** | Terraform module structure, standards, validation, and best practices |
| **Container Orchestration** | Kubernetes manifests, security contexts, resource management, and RBAC |
| **Helm Charting** | Chart structure, values management, environment splitting, and linting |
| **Secrets Management** | Vault integration patterns, ExternalSecrets, rotation procedures |
| **GitOps** | ArgoCD application patterns, sync policies, syncWave ordering |
| **CI/CD Design** | Merge request gates, reproducible pipelines, and promotion controls |
| **Security Engineering** | RBAC, network policies, supply-chain controls, secret handling |
| **Observability** | Prometheus metrics, alerting rules, Grafana dashboards as code, structured logging |
| **Developer Experience** | Onboarding guides, documentation workflows, and contribution guidance |
| **Documentation** | ADR templates, runbooks, production readiness checklists |
| **Governance** | Naming conventions, repository standards, and review templates |
| **Technical Writing** | Mermaid architecture diagrams, design decisions, trade-offs, failure scenarios |

---

## Repository Structure

```text
platform-engineering-standards/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── incident.md
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── adr/                          # Architecture Decision Records
│   │   ├── README.md
│   │   ├── template.md
│   │   └── 0001-use-terraform-for-iac.md
│   ├── checklists/
│   │   ├── pr-checklist.md
│   │   └── production-readiness-checklist.md
│   ├── onboarding/
│   │   └── platform-onboarding-guide.md
│   ├── runbooks/
│   │   └── incident-response.md
│   └── standards/
│       ├── argocd-standards.md
│       ├── documentation-standards.md
│       ├── engineering-standards.md
│       ├── github-standards.md
│       ├── gitlab-standards.md
│       ├── helm-standards.md
│       ├── kubernetes-standards.md
│       ├── naming-conventions.md
│       ├── observability-standards.md
│       ├── repository-structure-standards.md
│       ├── terraform-standards.md
│       └── vault-standards.md
├── CHANGELOG.md
├── CONTRIBUTING.md
└── SECURITY.md
```

---

## Quick Start

1. Start with [docs/standards/engineering-standards.md](docs/standards/engineering-standards.md) for the baseline rules.
2. Review the technology-specific standards under [docs/standards/](docs/standards/).
3. Use the templates and operational guides in `docs/adr/`, `docs/checklists/`, `docs/onboarding/`, and `docs/runbooks/`.

---

## Standards Index

| Standard | Description | Document |
|---|---|---|
| Engineering Standards | Core engineering rules and conventions | [docs/standards/engineering-standards.md](docs/standards/engineering-standards.md) |
| Naming Conventions | Resource, file, and variable naming rules | [docs/standards/naming-conventions.md](docs/standards/naming-conventions.md) |
| Repository Structure | Repository layout and organisation rules | [docs/standards/repository-structure-standards.md](docs/standards/repository-structure-standards.md) |
| Terraform Standards | IaC module structure and validation rules | [docs/standards/terraform-standards.md](docs/standards/terraform-standards.md) |
| Kubernetes Standards | Manifest security, resource, and RBAC standards | [docs/standards/kubernetes-standards.md](docs/standards/kubernetes-standards.md) |
| Helm Standards | Chart structure, values, and linting standards | [docs/standards/helm-standards.md](docs/standards/helm-standards.md) |
| Vault Standards | Secrets management and rotation standards | [docs/standards/vault-standards.md](docs/standards/vault-standards.md) |
| ArgoCD Standards | GitOps, sync policies, and wave ordering | [docs/standards/argocd-standards.md](docs/standards/argocd-standards.md) |
| Observability Standards | Metrics, alerting, logging, and dashboards | [docs/standards/observability-standards.md](docs/standards/observability-standards.md) |
| GitHub Standards | Repository settings, branch protection, Actions | [docs/standards/github-standards.md](docs/standards/github-standards.md) |
| GitLab Standards | Pipeline structure, SAST, and merge rules | [docs/standards/gitlab-standards.md](docs/standards/gitlab-standards.md) |
| Documentation Standards | Writing style, diagrams, and review rules | [docs/standards/documentation-standards.md](docs/standards/documentation-standards.md) |

---

## Templates and Checklists

| Template | Description | Link |
|---|---|---|
| ADR Template | Architecture Decision Record template | [docs/adr/template.md](docs/adr/template.md) |
| PR Checklist | Pre-merge pull request checklist | [docs/checklists/pr-checklist.md](docs/checklists/pr-checklist.md) |
| Production Readiness | Production readiness review checklist | [docs/checklists/production-readiness-checklist.md](docs/checklists/production-readiness-checklist.md) |
| Incident Response | Incident response runbook template | [docs/runbooks/incident-response.md](docs/runbooks/incident-response.md) |
| Platform Onboarding | New engineer onboarding guide | [docs/onboarding/platform-onboarding-guide.md](docs/onboarding/platform-onboarding-guide.md) |

---

## Usage

Use this repository as the source of truth for standards content. Copy, adapt, and apply the documented requirements in your own repositories and delivery workflows.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Security

See [SECURITY.md](SECURITY.md) for security policy and vulnerability reporting.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
