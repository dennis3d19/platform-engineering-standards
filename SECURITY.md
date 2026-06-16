# Security Policy

## Supported Versions

This repository contains standards, templates, and documentation. The following versions receive security updates:

| Version | Supported |
| ------- | --------- |
| main    | Yes    |
| < main  | No     |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in this repository, please follow the responsible disclosure process below.

### Do NOT open a public GitHub issue for security vulnerabilities

### How to Report

1. **Repository maintainers**: Contact the repository maintainers through the private channels configured for this repository.
2. **GitHub Private Reporting**: Use [GitHub's private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability)
   if enabled for this repository.

### What to Include

Please include as much of the following information as possible:

- Type of vulnerability (e.g., secret exposure, insecure configuration, injection)
- Location of the affected code (file path, line number)
- Step-by-step instructions to reproduce the issue
- Potential impact and severity assessment
- Any suggested remediation

### Response Timeline

| Action | Target Timeline |
|---|---|
| Initial acknowledgement | Within 48 hours |
| Severity assessment | Within 5 business days |
| Fix or mitigation | Within 30 days for critical/high severity |
| Public disclosure | After fix is deployed and verified |

## Security Standards

This repository enforces the following security controls:

### Documentation Controls

All repository changes must:

- Avoid committing credentials, tokens, API keys, or private keys
- Keep security guidance aligned with the standards documents
- Remove broken or stale references that could mislead operators

### Secrets Management

- No credentials, tokens, API keys, or private keys are committed to this repository
- Vault patterns are documented without real paths or credentials
- Any sample identifiers must stay generic and non-sensitive

### Dependency Management

- All tool versions are pinned in configuration files
- Dependencies are reviewed before addition
- Automated scanning identifies known vulnerabilities

## Known Security Considerations

When using the templates and standards in this repository in your own environment:

1. **Review RBAC permissions** — apply least-privilege appropriate for your context
2. **Enable SSL verification** — sample guidance may describe exceptions for test environments only; never use them in production
3. **Audit Vault policies** — documented Vault patterns are illustrative and must be reviewed before production use
4. **Pin image digests** — production workloads should pin container images to immutable digests

## Compliance

This repository follows these security frameworks as design guidance:

- OWASP Top 10
- CIS Benchmarks (Kubernetes, Terraform)
- NIST SP 800-190 (Application Container Security)
- SOC 2 Type II control patterns

## Contact

For non-security issues, please open a [GitHub Issue](https://github.com/dennis3d19/platform-engineering-standards/issues).

For security vulnerabilities, use the private reporting process described above.
