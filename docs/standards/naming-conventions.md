# Naming Conventions

Consistent naming reduces cognitive load, prevents collisions, and makes resources self-describing.
These conventions apply across all platform tooling and environments.

---

## General Rules

1. Names must be descriptive and self-documenting.
2. Avoid abbreviations unless they are universally understood and documented.
3. Never mix naming styles within the same resource type or codebase.
4. All names are case-sensitive where the target system is case-sensitive.

---

## Pattern Summary

| Context | Style | Example |
|---|---|---|
| File names | `lowercase-hyphenated` | `my-config-file.yaml` |
| Directory names | `lowercase-hyphenated` | `my-module/` |
| Kubernetes resources | `lowercase-hyphenated` | `my-app-deployment` |
| Helm release names | `lowercase-hyphenated` | `my-app-v2` |
| Terraform variable names | `lowercase_underscore` | `enable_monitoring` |
| Terraform local names | `lowercase_underscore` | `naming_prefix` |
| Shell variables | `lowercase_underscore` | `target_namespace` |
| Shell constants | `UPPER_UNDERSCORE` | `MAX_RETRY_COUNT` |
| Environment variables | `UPPER_UNDERSCORE` | `DATABASE_URL` |
| JavaScript/TypeScript variables | `lowerCamelCase` | `myConfigValue` |
| JavaScript/TypeScript classes | `UpperCamelCase` | `MyServiceClient` |
| Python variables/functions | `snake_case` | `get_config_value` |
| Python classes | `UpperCamelCase` | `ConfigManager` |
| Go functions/methods | `UpperCamelCase` (exported) | `GetConfig` |
| Go variables | `lowerCamelCase` | `configValue` |

---

## Resource Naming Pattern

Platform resources follow this pattern where applicable:

```
<env>-<app>-<component>
```

| Segment | Values | Notes |
|---|---|---|
| `env` | `tst`, `acc`, `prd` | Always use abbreviated form |
| `app` | Application name | Lowercase hyphenated |
| `component` | Resource type or purpose | Lowercase hyphenated |

**Examples:**

```
tst-grafana-operator
acc-platform-api
prd-vault-agent
tst-monitoring-prometheus
```

---

## Kubernetes Naming

### Namespaces

```
<team>-<env>
```

Examples: `platform-tst`, `monitoring-prd`, `security-acc`

### Deployments and Services

```
<app>-<component>
```

Examples: `frontend-api`, `backend-worker`, `cache-redis`

### ConfigMaps

```
<app>-<purpose>-config
```

Examples: `grafana-datasource-config`, `prometheus-rules-config`

### Secrets

```
<namespace>-<env>-<purpose>
```

Examples: `monitoring-tst-grafana-token`, `platform-prd-vault-token`

### ServiceAccounts

```
<app>-sa
```

Examples: `grafana-sa`, `prometheus-sa`

### ClusterRoles and ClusterRoleBindings

```
<component>:<app>-<permission>
```

Examples: `platform:grafana-view`, `monitoring:prometheus-scrape`

---

## Terraform Naming

### Variables

Use `snake_case`. Boolean variables use a verb prefix:

```hcl
variable "enable_monitoring" {
  type        = bool
  description = "Enable Prometheus monitoring stack."
}

variable "create_vpc" {
  type        = bool
  description = "Whether to create a new VPC."
}

variable "allow_public_access" {
  type        = bool
  description = "Allow public internet access to the load balancer."
}
```

### Locals

Group by concern using a prefix:

```hcl
locals {
  naming_prefix = "${var.environment}-${var.application}"
  naming_suffix = var.region

  tags_common = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Application = var.application
  }

  network_vpc_cidr = "10.0.0.0/16"
}
```

### Outputs

Sort alphabetically. Use `snake_case`:

```hcl
output "cluster_endpoint" {
  description = "Kubernetes cluster API endpoint."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.main.id
}
```

### Resources

Use `snake_case` resource names that describe purpose:

```hcl
resource "aws_vpc" "main" { }
resource "aws_subnet" "private" { }
resource "aws_security_group" "app_inbound" { }
```

---

## Helm Naming

### Charts

```
<app-name>   # e.g., my-application, platform-api
```

### Releases

```
<env>-<chart-name>   # e.g., tst-my-application
```

### Values Files

```
values.yaml            # Non-environment-specific defaults
values-tst.yaml        # Test environment overrides
values-acc.yaml        # Acceptance environment overrides
values-prd.yaml        # Production environment overrides
```

---

## Git Naming

### Branches

```
<type>/<short-description>
```

Examples:

```
feat/add-monitoring-stack
fix/broken-vault-token
chore/update-pre-commit-versions
docs/adr-gitops-strategy
```

### Tags

Follow SemVer with `v` prefix:

```
v1.0.0
v1.2.3-rc.1
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(terraform): add VPC module with private subnets
fix(kubernetes): correct security context for grafana
docs(adr): add ADR-0005 for observability strategy
chore(deps): update pre-commit hooks to latest versions
```

---

## Environment Abbreviations

Always use the canonical three-letter abbreviations:

| Full Name | Abbreviation |
|---|---|
| test / testing | `tst` |
| acceptance / staging | `acc` |
| production | `prd` |
| development | `dev` |

---

## Labels

All Kubernetes resources must include these labels at minimum:

```yaml
labels:
  app: my-application
  environment: tst
  managed-by: helm   # or argocd, terraform, etc.
  version: "1.2.0"
```

All cloud resources (AWS, GCP, Azure) must include these tags at minimum:

```yaml
Environment: tst
Application: my-application
ManagedBy: terraform
Team: platform
CostCenter: engineering
```

---

## Anti-patterns to Avoid

| Anti-pattern | Why | Alternative |
|---|---|---|
| `myApp`, `MyApp` in file names | Mixed case causes issues on case-insensitive systems | `my-app` |
| `prod` or `production` | Inconsistent with `tst`/`acc` pattern | `prd` |
| `secret-1`, `secret-2` | Not self-describing | `monitoring-prd-grafana-token` |
| `test_var`, `TestVar` in the same file | Mixed styles | Pick one and be consistent |
| `ENABLE_THING=true` as a variable name | Shadowed by environment variable style | `enable_thing` in Terraform |
| `latest` as image tag | Not pinned, not reproducible | `v1.2.0` or image digest |
