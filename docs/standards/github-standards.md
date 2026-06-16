# GitHub Standards

Standards for GitHub repository configuration, Actions workflows, and branch management.

---

## Repository Configuration

### Required Settings

Every repository must have these settings configured:

| Setting | Value | Rationale |
|---|---|---|
| Default branch | `main` | Consistent convention |
| Branch protection on `main` | Enabled | Prevent direct pushes |
| Require pull request reviews | Min. 1 | Code review gate |
| Dismiss stale reviews | Enabled | Re-review after new commits |
| Require status checks | Enabled | CI must pass |
| Require branches up to date | Enabled | Prevent stale merges |
| Restrict who can push | Enabled | Only maintainers |
| Delete head branch on merge | Enabled | Keep branch list clean |
| Squash merging | Allowed | Clean history |
| Merge commits | Allowed | Preserve context where needed |
| Rebase merging | Disallowed | Avoid history rewriting |

### Required Files

Every repository must include these files at the root:

```
README.md
LICENSE
SECURITY.md
CONTRIBUTING.md
CHANGELOG.md
CODEOWNERS
Makefile
.editorconfig
.gitignore
.pre-commit-config.yaml
```

---

## CODEOWNERS

Define CODEOWNERS to require review from appropriate teams:

```
# Default owner for all files
* @org/platform-team

# Sensitive security files require security team review
SECURITY.md @org/security-team
/.github/workflows/ @org/security-team @org/platform-team

# Terraform requires platform team review
/terraform/ @org/platform-team
/examples/terraform/ @org/platform-team

# Documentation requires docs review
/docs/ @org/platform-team
```

---

## GitHub Actions

### Workflow Standards

| Standard | Detail |
|---|---|
| Pin action versions | Use SHA or exact version tag, not `@main` |
| Set permissions | Always set `permissions:` at job or workflow level |
| Use concurrency | Cancel stale runs with `concurrency:` |
| Minimal secrets | Only request the secrets each job requires |
| Reusable workflows | Extract shared logic into `.github/workflows/` reusable workflows |

### Required Permissions

Always set minimum required permissions:

```yaml
permissions:
  contents: read
  pull-requests: write
  security-events: write
```

Never use `permissions: write-all` in workflows that handle untrusted code (e.g., `pull_request_target`).

### Action Version Pinning

```yaml
# Good - pinned to specific version
uses: actions/checkout@v4

# Better - pinned to SHA for supply chain security
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

# Bad - unpinned, vulnerable to supply chain attacks
uses: actions/checkout@main
```

### Secrets Handling

```yaml
# Good - use secrets as environment variables
env:
  API_TOKEN: ${{ secrets.API_TOKEN }}

# Good - use in run steps with masking
- name: Deploy
  run: |
    deploy --token "$API_TOKEN"
  env:
    API_TOKEN: ${{ secrets.API_TOKEN }}

# Bad - secrets in step name or annotation (visible in logs)
- name: Deploy with ${{ secrets.API_TOKEN }}
  run: echo ${{ secrets.API_TOKEN }}
```

---

## Standard Workflow Triggers

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  schedule:
    - cron: "0 6 * * 1"  # Weekly Monday 6am UTC
  workflow_dispatch:      # Manual trigger
```

---

## Branch Protection Rules

Configure via `gh` CLI or Terraform:

```bash
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Validate / Summary"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":true,"required_approving_review_count":1}' \
  --field restrictions=null
```

---

## Security Best Practices

### Dependabot

Enable Dependabot for automated dependency updates:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly

  - package-ecosystem: pip
    directory: /
    schedule:
      interval: weekly

  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
```

### Secret Scanning

- Enable GitHub Secret Scanning in repository settings.
- Enable push protection to block secret commits before they land.
- Configure custom patterns for organisation-specific tokens.

### Code Scanning

- Enable CodeQL for supported languages.
- Review and address all high and critical findings within 30 days.
- Configure `dismiss_stale_reviews` to require re-review after new pushes.

---

## Issue and PR Templates

Store templates in `.github/`:

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   ├── feature_request.md
│   └── incident.md
└── PULL_REQUEST_TEMPLATE.md
```

---

## Repository Topics

Add meaningful topics to every repository for discoverability:

```
platform-engineering
terraform
kubernetes
helm
argocd
observability
devops
infrastructure
```
