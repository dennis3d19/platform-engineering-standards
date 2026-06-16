# Engineering Standards

This document captures mandatory conventions for all code and configuration authored across the platform.
Treat it as a checklist before opening a merge request, regardless of language or tool.

---

## 1. Repository Layout

- Every repository must have a `README.md` at the root that describes purpose, structure, and how to get started.
- Separate concerns into directories by function: `docs/`, `src/` (or equivalent), `tests/`, `examples/`, `scripts/`.
- Automation files (`.pre-commit-config.yaml`, `.gitlab-ci.yml`, `.editorconfig`) live at the repository root.
- Configuration that differs per environment (`tst`, `acc`, `prd`) lives in environment-specific directories or value files — never in a single file with embedded conditionals.
- Keep generated files (manifests, results, lock files) out of feature branches; commit them only to the designated output path or via automation.

---

## 2. Naming Conventions

- Use lowercase hyphenated names (`my-resource-name`) for file names, directory names, Kubernetes resource names, and Helm release names.
- Use lowercase underscore-separated names (`my_variable_name`) for variable names, Terraform locals, and shell variables.
- Use uppercase underscore-separated names (`MY_CONSTANT`) for environment variables and shell constants.
- Use lower camel case (`myVariable`) for JavaScript/TypeScript variables and functions.
- Resource names follow the pattern `<env>-<app>-<component>` where possible (e.g. `tst-grafana-k6-operator`).
- Boolean variables and flags use a verb prefix: `enable_`, `create_`, `allow_`, `is_`.
- Abbreviations should be consistent and documented — do not mix `ns` and `namespace` in the same codebase.
- Secret names in Kubernetes follow `<namespace>-<env>-<purpose>` (e.g. `loadtesting-tst-k6-read-write-token`).

---

## 3. Documentation Rules

- Every module, chart, workflow, or application must include a README with:
  - Purpose and scope (what it does and what it does not do).
  - Quick-start or prerequisites.
  - Links to deeper documentation for operators, developers, and security.
  - Operational notes (limits, known behaviours, loop protection, etc.).
- Documentation lives next to the code it describes; do not maintain a separate wiki as the single source of truth.
- Document *why*, not *what* — code is self-descriptive; comments and docs explain intent, constraints, and non-obvious decisions.
- Do not leave `TODO`, `FIXME`, or `HACK` comments without a linked issue or ticket.
- Keep documentation up to date in the same merge request as the code change.

---

## 4. Configuration and Secrets

- Never hard-code environment-specific values (URLs, namespaces, credentials) inside application code or templates.
- Use a secrets manager (Vault) as the single source of truth for all credentials; sync to Kubernetes via ExternalSecret — never `kubectl create secret` in production.
- Mark secrets as sensitive in all tooling that supports it (`sensitive = true` in Terraform, `envFrom` with `secretKeyRef` in Kubernetes).
- Apply least-privilege: a token scoped to `read_repository` + `write_repository` must not carry `api` scope unless explicitly required.
- Set expiry on all tokens and document the rotation procedure.
- Never commit credentials, tokens, or private keys to Git — enforce this via `.gitignore` and pre-commit hooks.
- Use `null` or absent fields to represent optional values; avoid empty strings as sentinels.

---

## 5. Versioning and Releases

- Follow Semantic Versioning (SemVer): `MAJOR.MINOR.PATCH`.
  - `MAJOR`: breaking changes to inputs, outputs, API contracts, or behaviour.
  - `MINOR`: backward-compatible additions.
  - `PATCH`: bug fixes and documentation-only changes.
- Tag every release in Git (`v1.2.0`); never reuse or move tags.
- Helm chart versions and application versions are independent — increment both explicitly.
- Container images must be pinned to a digest or an immutable tag (`v1.2.0`, not `latest`) in production manifests.

---

## 6. Changelog

- Follow the [Keep a Changelog](https://keepachangelog.com/) format: `Added`, `Changed`, `Fixed`, `Removed`, `Security`.
- Update `CHANGELOG.md` in the same merge request as the code change.
- Reference ticket or issue IDs in changelog entries where applicable.
- Note any migration steps or manual actions required under `Changed` or `Removed`.

---

## 7. Testing Strategy

- Every change must pass linting, formatting, and schema validation locally before pushing.
- Minimum CI gate: lint + format check + static analysis + security scan.
- Write at least one test that exercises the critical path of any new feature.
- Gate destructive or expensive tests behind an explicit environment variable (e.g. `RUN_INTEGRATION_TESTS=1`).
- Test fixtures go under `tests/fixtures/` or `tests/testdata/`.
- k6 load tests must run for a minimum of `1m` (recommended `2m`) so the log stream can attach to the runner pod.

---

## 8. Kubernetes and Helm

- All pods must include a security context: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`, `seccompProfile.type: RuntimeDefault`.
- Resource requests and limits are mandatory on all containers in production namespaces.
- Liveness and readiness probes are required for long-running workloads.
- Helm values files are environment-split (`values-tst.yaml`, `values-acc.yaml`, `values-prd.yaml`); a base `values.yaml` holds non-environment-specific defaults.
- Do not use `helm template | kubectl apply` in production; use ArgoCD or an equivalent GitOps controller.
- CRD upgrades must be applied before the Helm release upgrade; document this in the release notes.
- Labels must include at minimum: `app`, `environment`, and `managed-by`.

---

## 9. Infrastructure as Code (Terraform)

- Use explicit types in all variable declarations; avoid `any` unless the shape is genuinely unbounded.
- Add `validation` blocks for enums, length constraints, and mutually exclusive inputs.
- Every variable and output requires a `description`.
- Group derived values in `locals.tf`; prefix locals by concern (`naming_`, `tags_`, `network_`).
- Expose only stable interfaces as outputs (IDs, names); keep outputs sorted alphabetically.
- Pin Terraform to the latest supported minor release and constrain every provider to a tested range.
- Never configure a backend inside a submodule; configure it only in root modules.
- Store backend configuration outside version control (`.tfvars`, `backend.hcl`); block state files via `.gitignore`.
- A `terraform fmt`, `terraform validate`, and `tflint` clean run is required before every merge request.
- Include at least one `examples/<scenario>/` with a working `terraform plan`.

---

## 10. CI/CD and GitOps

- All pipelines must be reproducible: the same inputs produce the same outputs regardless of when or where they run.
- Pipelines validate, build, and promote — they do not perform manual steps that bypass review.
- ArgoCD applications use `syncWave` annotations to enforce dependency order across applications.
- Sync policies (`automated`, `selfHeal`, `prune`) must be explicitly set and reviewed per environment — enable automated sync only where safe.
- Pipeline secrets are injected via CI secret variables or Vault; never stored as plain-text in `.gitlab-ci.yml`.
- Merge request pipelines must pass before code merges to `main`; direct pushes to `main` are blocked.
- Keep pipeline jobs atomic: one job, one concern (lint, test, build, deploy).

---

## 11. Security

- Every merge request undergoes a security review if it changes: RBAC, network policies, secret handling, authentication flows, or public-facing endpoints.
- Follow the OWASP Top 10 as a baseline; injection, broken access control, and secrets exposure are zero-tolerance issues.
- RBAC follows least-privilege: grant the narrowest `verbs` and `resources` that make the workload function.
- Webhook secrets must be random hex strings, not reused API tokens or passwords.
- `enableSSLVerification: false` is acceptable only in `tst` with an internal CA; it must never appear in `prd`.
- Log sanitisation: ensure `DEBUG_LOG` or equivalent verbose logging is disabled in production; token values must never appear in logs.
- Network policies restrict ingress/egress to declared peers only; deny-all defaults with explicit allow rules.

---

## 12. Observability and Logging

- Structured logging (JSON) is required for all platform components and recommended for application workloads.
- Log levels: use `info` in production, `debug` only in `tst` — never `debug` in `prd`.
- Expose Prometheus metrics via `/metrics` or a standard sidecar for any long-running workload.
- ServiceMonitor resources must include `additionalLabels` matching the Prometheus instance selector.
- Alerts must have `severity`, `runbook_url`, and a clear message explaining impact; avoid alert noise by setting appropriate thresholds.
- Dashboards are code (JSON/YAML) stored in git and deployed via ConfigMap or GitOps; do not save dashboards only in Grafana UI.

---

## 13. Code Style

- Formatting is non-negotiable and enforced by tooling, not by review comments:
  - Terraform: `terraform fmt`
  - JavaScript/TypeScript: Prettier
  - YAML: `yamllint` with project-level config
  - Shell: `shfmt`
- Pre-commit hooks enforce formatting, linting, and secret detection for every engineer.
- Run `pre-commit install` as part of repository setup; CI mirrors the same hooks.
- Inline comments explain *why*, not *what*. Reference ADR numbers or ticket IDs for non-obvious decisions.
- Keep functions and steps short and single-purpose; extract named helpers over repeating logic.
- Trailing whitespace, mixed indentation, and Windows line endings (`CRLF`) are blocked by `.editorconfig`.

---

By adhering to these standards, every component of the platform remains predictable, secure, and easy to operate at scale.
