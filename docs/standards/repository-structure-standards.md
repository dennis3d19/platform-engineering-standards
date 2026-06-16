# Repository Structure Standards

Standards for repository organisation, layout, and configuration across all platform repositories.

---

## Standard Repository Layout

Every repository must follow this layout:

```text
my-repository/
├── .github/                      # GitHub-specific configuration
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       └── validate.yml
├── docs/                         # Documentation
│   ├── adr/                      # Architecture Decision Records
│   ├── runbooks/                 # Operational runbooks
│   └── standards/                # Standards documents
├── examples/                     # Working examples
├── scripts/                      # Utility scripts
├── src/                          # Source code (or equivalent)
├── tests/                        # Tests
│   └── fixtures/                 # Test data and fixtures
├── .editorconfig                 # Editor settings
├── .gitignore                    # Git ignore rules
├── .markdownlint.yaml            # Markdown linting config
├── .pre-commit-config.yaml       # Pre-commit hook config
├── .yamllint.yaml                # YAML linting config
├── CHANGELOG.md                  # Version history
├── CODEOWNERS                    # Code ownership
├── CONTRIBUTING.md               # Contribution guide
├── LICENSE                       # License
├── Makefile                      # Automation targets
└── README.md                     # Repository overview
```

---

## Directory Conventions

### `docs/`

Documentation organised by type:

```
docs/
├── adr/               # Architecture Decision Records
├── checklists/        # Operational checklists
├── design/            # Design documents and proposals
├── onboarding/        # Onboarding guides
├── runbooks/          # Incident response runbooks
└── standards/         # Standards and conventions
```

### `examples/`

Working examples for every major feature or technology:

```
examples/
├── terraform/
│   ├── basic/          # Minimal working example
│   └── advanced/       # Full-featured example
├── kubernetes/
│   └── namespace-setup/
└── helm/
    └── app-chart/
```

**Rules:**

- Every example directory must have a `README.md`.
- Examples must work as-is with only placeholder values replaced.
- Never include real credentials, domains, or IP addresses.

### `scripts/`

Utility and automation scripts:

```
scripts/
├── bootstrap.sh       # Initial setup script
├── deploy.sh          # Deployment script
└── rotate-secrets.sh  # Secret rotation helper
```

**Rules:**

- All scripts must have a shebang line: `#!/usr/bin/env bash`.
- All scripts must use `set -euo pipefail`.
- All scripts must pass `shellcheck` and `shfmt`.
- Include usage documentation at the top of each script.

### `tests/`

Tests organised by type:

```
tests/
├── fixtures/          # Test data and static fixtures
├── integration/       # Integration tests (gated by env var)
├── unit/              # Unit tests
└── README.md          # Testing guide
```

**Rules:**

- Fixtures go in `tests/fixtures/` or `tests/testdata/`.
- Gate integration tests behind `RUN_INTEGRATION_TESTS=1`.
- Do not commit real credentials in fixtures — use placeholder values.

---

## File Naming

| Type | Convention | Example |
|---|---|---|
| Markdown documents | `lowercase-hyphenated.md` | `naming-conventions.md` |
| YAML configuration | `lowercase-hyphenated.yaml` | `values-prd.yaml` |
| Shell scripts | `lowercase-hyphenated.sh` | `rotate-secrets.sh` |
| Python modules | `lowercase_underscore.py` | `config_parser.py` |
| Terraform files | `snake_case.tf` | `variables.tf` |

---

## Generated Files

Keep generated files out of feature branches. Rules:

- Add generated directories (`dist/`, `build/`, `.terraform/`) to `.gitignore`.
- Commit generated lock files (`package-lock.json`, `poetry.lock`) to the default branch only.
- Never commit `.terraform.lock.hcl` changes in feature branches.

---

## Environment Separation

Configuration that differs per environment must be in separate files:

```
# Good
values-tst.yaml
values-acc.yaml
values-prd.yaml

# Bad
values.yaml  # with embedded if/else for environment
```

Never use a single file with conditionals like:

```yaml
# Bad pattern - avoid
replicas: {{ if eq .Values.environment "prd" }}3{{ else }}1{{ end }}
```

Use environment-specific value files and override at deploy time instead.

---

## Pre-commit Configuration

Every repository must include `.pre-commit-config.yaml` with at minimum:

- `trailing-whitespace`
- `end-of-file-fixer`
- `check-yaml`
- `check-json`
- `detect-private-key`
- `yamllint`
- `markdownlint`
- `detect-secrets`

Engineers must run `pre-commit install` as part of repository setup.
CI must run the same pre-commit hooks to mirror the local enforcement.

---

## Makefile Targets

Standard Makefile targets that every repository should provide:

| Target | Purpose |
|---|---|
| `make help` | Show available targets |
| `make install` | Install pre-commit hooks and dependencies |
| `make validate` | Run all validation (lint + security + test) |
| `make lint` | Run linting only |
| `make security` | Run security scans |
| `make test` | Run tests |
| `make clean` | Remove generated files |

---

## Sensitive Data Rules

Never commit:

- Credentials, passwords, tokens, or API keys
- Private keys or certificates
- Real production IP addresses
- Real customer or internal domain names
- Real company names (in clean-room repositories)
- Proprietary algorithms or configurations

Use `.gitignore` and `detect-secrets` to enforce this automatically.
