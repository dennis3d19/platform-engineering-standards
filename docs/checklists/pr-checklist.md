# Pull Request Checklist

Complete this checklist before requesting review on any pull request.
Use it alongside the [PR template](.github/PULL_REQUEST_TEMPLATE.md).

---

## Always Required

- [ ] PR title follows Conventional Commits format
- [ ] Related issue is linked (`Closes #N` or `Refs #N`)
- [ ] `CHANGELOG.md` is updated under `[Unreleased]`
- [ ] No secrets, credentials, or real data in any file
- [ ] Self-reviewed the diff for obvious errors

---

## Documentation Changes

- [ ] No broken links
- [ ] Code examples in documentation are correct
- [ ] Mermaid diagrams render correctly
- [ ] Placeholder values used (not real domains, IPs, or credentials)

---

## Code Changes

- [ ] YAML files pass `yamllint`
- [ ] Shell scripts pass `shellcheck` and `shfmt`
- [ ] Tests pass locally
- [ ] New functionality has at least one test

---

## Infrastructure Changes (Terraform)

- [ ] `terraform fmt` — clean
- [ ] `terraform validate` — clean
- [ ] `tflint` — zero warnings
- [ ] `checkov` — no unacknowledged failures
- [ ] Example `terraform plan` output reviewed
- [ ] No state files or backend configs committed

---

## Kubernetes Changes

- [ ] Manifests validated with `kubeconform`
- [ ] Security context is set on all containers
- [ ] Resource requests and limits are set
- [ ] Liveness and readiness probes are configured
- [ ] Network policies are updated if new communication paths added
- [ ] RBAC changes reviewed for least-privilege

---

## Security-Sensitive Changes

If this PR changes any of the following, a security review is required:

- [ ] RBAC rules or policies
- [ ] Network policies
- [ ] Secret handling or Vault paths
- [ ] Authentication or authorisation flows
- [ ] Public-facing endpoints

---

## Large Changes

For PRs with >300 lines changed:

- [ ] PR is split into smaller, focused changes where possible
- [ ] Architecture decision documented in ADR if significant
- [ ] Reviewers have been notified in advance
