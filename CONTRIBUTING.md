# Contributing to Platform Engineering Standards

Thank you for contributing to Platform Engineering Standards. This document outlines the process and expectations for contributions.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Standards for Contributions](#standards-for-contributions)
- [Pull Request Process](#pull-request-process)
- [Commit Message Format](#commit-message-format)
- [Reporting Issues](#reporting-issues)

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
By participating, you are expected to uphold this standard.

---

## How to Contribute

### Types of Contributions

- **Standards updates**: Propose changes to existing standards documents
- **New standards**: Add standards for technologies not yet covered
- **Templates**: Add or improve templates (ADR, PR, runbooks)
- **Examples**: Add working examples for technologies or patterns
- **Bug fixes**: Fix errors, broken links, or inaccurate information
- **Documentation**: Improve clarity, add diagrams, fix typos

### What We Are NOT Looking For

- Client-specific code or configurations
- Proprietary implementations
- Real credentials, domains, or IP addresses
- Code that cannot be safely published publicly

---

## Development Setup

### Prerequisites

Install all required tools:

```bash
# Python tools
pip install pre-commit yamllint detect-secrets

# Node.js tools
npm install -g markdownlint-cli

# System tools (Ubuntu/Debian)
apt-get install shellcheck

# Go tools
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/dennis3d19/platform-engineering-standards.git
cd platform-engineering-standards

# Install pre-commit hooks
make install

# Verify setup
make validate
```

---

## Standards for Contributions

### Documentation Standards

- Use clear, professional language
- Write in the imperative mood for standards and requirements
- Include Mermaid diagrams for architecture concepts
- Follow the [documentation standards](docs/standards/documentation-standards.md)
- Document *why*, not just *what*

### File Naming

- Use lowercase hyphenated names for all files (`my-standard.md`)
- Follow the naming conventions in [docs/standards/naming-conventions.md](docs/standards/naming-conventions.md)

### YAML Files

- Pass `yamllint` with the project configuration
- Use 2-space indentation
- Include a trailing newline

### Markdown Files

- Pass `markdownlint` with the project configuration
- Use ATX-style headings (`#`, `##`, `###`)
- Include blank lines around headings and lists
- Limit line length where practical

### Shell Scripts

- Pass `shellcheck`
- Pass `shfmt` formatting
- Use `#!/usr/bin/env bash` shebang
- Use `set -euo pipefail`

### Examples

- All examples must work as-is with only environment-specific values replaced
- Use placeholder values (`REPLACE_ME`, `<your-value>`, `example.com`)
- Include a `README.md` in each example directory

---

## Pull Request Process

### Before Opening a PR

1. Run `make validate` and ensure all checks pass
2. Update relevant documentation in the same PR
3. Update `CHANGELOG.md` with your changes
4. Complete the [PR checklist](docs/checklists/pr-checklist.md)

### PR Title Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>
```

**Types:**

| Type | Use |
|---|---|
| `feat` | New standard, template, or example |
| `fix` | Fix error, broken link, or incorrect standard |
| `docs` | Documentation improvements |
| `chore` | Maintenance, dependency updates |
| `refactor` | Restructure without changing content |
| `security` | Security-related fixes or improvements |

**Examples:**

```
feat(terraform): add module structure standards
fix(kubernetes): correct security context example
docs(adr): add ADR for secrets management approach
chore(pre-commit): update hook versions
```

### PR Size

- Keep PRs focused on a single concern
- Large PRs will be asked to be split
- Each PR should be reviewable in under 30 minutes

### Review Requirements

- At least one approval from a CODEOWNER is required
- All CI checks must pass
- All review comments must be resolved

---

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

**Example:**

```
feat(helm): add environment-split values file standards

Add standards for splitting Helm values across environments:
- values.yaml for non-environment-specific defaults
- values-tst.yaml, values-acc.yaml, values-prd.yaml for overrides

Closes #42
```

---

## Reporting Issues

### Bug Reports

Use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) template.

Include:

- Which standard or document is affected
- What is incorrect or misleading
- What the correct information should be

### Feature Requests

Use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) template.

Include:

- What standard or template you want added
- Why it is needed
- Any reference implementations or sources

---

## Architecture Decision Records

When proposing significant changes to the standards themselves, create an ADR using the
[template](docs/adr/template.md). This ensures decisions are documented with context, trade-offs, and rationale.

---

## Questions

If you have questions about contributing, open a [Discussion](https://github.com/dennis3d19/platform-engineering-standards/discussions)
rather than an issue.
