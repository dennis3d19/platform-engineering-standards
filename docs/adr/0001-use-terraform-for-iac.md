# ADR-0001: Use Terraform for Infrastructure as Code

| Field | Value |
|---|---|
| **Date** | 2024-01-01 |
| **Status** | Accepted |
| **Deciders** | @platform-lead, @cloud-architect |
| **Consulted** | @security-engineer, @sre-lead |
| **Informed** | Platform Engineering team, DevOps Engineers |

---

## Context

The platform team needs a consistent, reviewable, and auditable way to provision and manage cloud infrastructure
across multiple environments (tst, acc, prd) and potentially multiple cloud providers.

Previously, infrastructure was provisioned through a combination of manual console actions and shell scripts.
This approach has several problems:

- Changes are not reproducible or version-controlled.
- There is no review process before infrastructure changes are applied.
- Drift between environments is difficult to detect.
- Onboarding engineers to infrastructure management is slow.

---

## Decision Drivers

- **Reproducibility**: Infrastructure definitions must be version-controlled and reproducible.
- **Review process**: All infrastructure changes must go through pull request review before apply.
- **Multi-cloud**: The platform may need to span AWS and GCP; tooling should support this.
- **Team capability**: The team has existing Terraform experience.
- **Ecosystem**: Rich provider ecosystem and community modules available.
- **State management**: Reliable state management is critical for tracking infrastructure.
- **Security scanning**: Tool must support static analysis and policy enforcement.

---

## Considered Options

1. **Terraform (HashiCorp)** — declarative HCL, strong provider ecosystem, mature tooling
2. **Pulumi** — imperative IaC using familiar programming languages
3. **CloudFormation / Deployment Manager** — cloud-native, provider-locked
4. **Ansible** — configuration management, not purpose-built for IaC

---

## Decision

We chose **Terraform** as the standard Infrastructure as Code tool across the platform.

Terraform is chosen because:

- The team already has Terraform experience, reducing onboarding time.
- The HCL syntax is declarative and readable in pull request diffs.
- The provider ecosystem covers all required cloud providers and services.
- Mature tooling exists for testing (`tflint`, `checkov`), formatting (`terraform fmt`), and state management.
- GitOps workflows integrate naturally with Terraform plan/apply automation.

---

## Consequences

### Positive

- Infrastructure changes are version-controlled and reviewable.
- Consistent module structure enables reuse across teams.
- `terraform plan` output makes changes explicit before apply.
- Static analysis with `tflint` and `checkov` enforces security standards.
- Remote state enables team collaboration.

### Negative / Trade-offs

- HCL is a purpose-built language, not a general-purpose language (unlike Pulumi).
- Terraform state can become a single point of failure if not managed properly.
- Complex dependency graphs can make large configurations difficult to reason about.
- Provider upgrades can introduce breaking changes requiring careful version pinning.

### Risks

- **State corruption**: Mitigated by remote state with locking (S3 + DynamoDB or Terraform Cloud).
- **Provider drift**: Mitigated by pinning provider versions in `versions.tf`.
- **Secrets in state**: Mitigated by using `sensitive = true` and encrypting state at rest.

---

## Options Analysis

### Option 1 — Terraform (Chosen)

**Pros:**

- Declarative, reviewable diffs
- Largest provider ecosystem
- Team has existing experience
- Rich testing and security tooling
- Cloud-agnostic

**Cons:**

- HCL not a general-purpose language
- State management complexity

### Option 2 — Pulumi

**Pros:**

- Uses familiar languages (Python, Go, TypeScript)
- Better for complex conditional logic

**Cons:**

- Team would need to learn a new paradigm
- Smaller community and fewer community modules
- Less mature security tooling

### Option 3 — CloudFormation / Deployment Manager

**Pros:**

- Native to cloud provider
- No state management needed

**Cons:**

- Vendor lock-in
- Does not support multi-cloud
- Verbose YAML syntax

### Option 4 — Ansible

**Pros:**

- Familiar to operations team
- Good for configuration management

**Cons:**

- Not designed for declarative infrastructure state
- No plan/preview step
- Poor drift detection

---

## Implementation Notes

- All Terraform code must follow the [Terraform Standards](../standards/terraform-standards.md).
- Remote state is stored in encrypted S3 with DynamoDB locking.
- `tflint` and `checkov` are run in CI and as pre-commit hooks.
- Module versions are pinned and updated through pull requests.

---

## Links

- [Terraform Standards](../standards/terraform-standards.md)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [tflint](https://github.com/terraform-linters/tflint)
- [Checkov](https://www.checkov.io/)
