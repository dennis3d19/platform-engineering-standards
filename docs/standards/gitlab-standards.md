# GitLab Standards

Standards for GitLab repository configuration, CI/CD pipelines, and merge request workflows.

---

## Repository Configuration

### Protected Branches

| Branch | Protection Level | Who Can Push | Who Can Merge |
|---|---|---|---|
| `main` | Fully protected | No one | Maintainers after MR |
| `release/*` | Fully protected | No one | Maintainers after MR |
| `feature/*` | Not protected | Developers | Developers |

### Merge Request Settings

| Setting | Value |
|---|---|
| Merge method | Merge commit (preserve context) |
| Require squash | Optional (per-project decision) |
| Fast-forward | Disabled |
| Delete source branch | Enabled |
| Pipelines must succeed | Enabled |
| All discussions resolved | Enabled |

---

## Pipeline Structure (.gitlab-ci.yml)

### Standard Pipeline Stages

```yaml
stages:
  - validate
  - lint
  - test
  - build
  - security
  - deploy-tst
  - test-integration
  - deploy-acc
  - deploy-prd
```

### Standard Pipeline Template

```yaml
---
# .gitlab-ci.yml

include:
  - project: "platform/ci-templates"
    ref: main
    file:
      - "/templates/lint.yml"
      - "/templates/security.yml"
      - "/templates/deploy.yml"

variables:
  TERRAFORM_VERSION: "1.9.0"
  PYTHON_VERSION: "3.12"

default:
  image: registry.example.com/platform/ci-base:latest
  interruptible: true
  tags:
    - platform

workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_PIPELINE_SOURCE == "schedule"

validate:yaml:
  stage: validate
  script:
    - yamllint .
  rules:
    - changes:
        - "**/*.yaml"
        - "**/*.yml"

lint:markdown:
  stage: lint
  script:
    - markdownlint "**/*.md"

test:unit:
  stage: test
  script:
    - pytest tests/ -v --tb=short
  artifacts:
    reports:
      junit: tests/results.xml
    expire_in: 1 week

security:secrets:
  stage: security
  script:
    - detect-secrets scan --baseline .secrets.baseline
  allow_failure: false

security:sast:
  stage: security
  include:
    - template: Security/SAST.gitlab-ci.yml

deploy:tst:
  stage: deploy-tst
  script:
    - ./scripts/deploy.sh tst
  environment:
    name: tst
    url: https://my-app.tst.example.com
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

---

## Job Standards

| Rule | Detail |
|---|---|
| One job, one concern | Do not mix lint and deploy in the same job |
| No secrets in YAML | Use CI/CD variables or Vault |
| `interruptible: true` | Allow cancellation of stale pipelines |
| Artifacts expire | Set `expire_in` on all artifacts |
| Rules over `only/except` | Use `rules:` for all conditions |

---

## Secrets Management

Never store secrets as plain-text in `.gitlab-ci.yml`. Use:

1. **CI/CD Variables** (Settings > CI/CD > Variables) — marked as protected and masked.
2. **Vault Integration** — use GitLab's Vault integration with JWT authentication.
3. **External Secrets** — sync Vault secrets to Kubernetes for deployment secrets.

```yaml
# Good - using CI/CD variable
deploy:prd:
  script:
    - deploy --token "$DEPLOY_TOKEN"

# Bad - hardcoded secret
deploy:prd:
  script:
    - deploy --token "my-secret-token"
```

---

## Merge Request Standards

### MR Title Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scope): short description
fix(scope): short description
docs(scope): short description
```

### MR Checklist

Before requesting review:

- [ ] Pipeline passes (all stages green)
- [ ] CHANGELOG.md updated
- [ ] Documentation updated in the same MR
- [ ] No secrets or credentials in code
- [ ] Self-reviewed the diff

### Reviewer Expectations

- Respond to MR review requests within 1 business day.
- Review the security impact of RBAC, network, and secret changes.
- Do not approve if tests are skipped or failing.

---

## SAST and Dependency Scanning

Enable GitLab-native SAST and Dependency Scanning templates:

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
```

Review Security Dashboard weekly. Address all Critical findings within 48 hours.

---

## Container Registry

- Use GitLab Container Registry for all project images.
- Tag images with the Git SHA for traceability: `registry.example.com/team/app:${CI_COMMIT_SHORT_SHA}`.
- Clean up old images using cleanup policies (keep last 10, older than 30 days).
- Scan images with Container Scanning before deployment.

---

## GitLab Tokens

| Token Type | Scope | Rotation |
|---|---|---|
| Project deploy token | `read_registry` only | Every 90 days |
| CI/CD job token | Scoped to project | Automatic (per-job) |
| Personal access token | Minimum required | Every 90 days |
| Group token | Minimum required | Every 90 days |

Never grant `api` scope unless the workflow explicitly requires API access.
