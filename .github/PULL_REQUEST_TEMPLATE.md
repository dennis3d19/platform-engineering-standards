## Pull Request Checklist

Before requesting review, please verify the following. Check each item that applies to this PR.

---

### General

- [ ] PR title follows [Conventional Commits](https://www.conventionalcommits.org/) format (`feat:`, `fix:`, `docs:`, `chore:`, etc.)
- [ ] PR description clearly explains **what** changed and **why**
- [ ] Related issue or ticket is linked (use `Closes #<issue>` syntax)
- [ ] Changes are focused on a single concern (no mixed concerns)
- [ ] No unrelated changes are included

---

### Documentation

- [ ] `CHANGELOG.md` is updated with a clear entry under `[Unreleased]`
- [ ] Relevant documentation in `docs/` is updated in this PR
- [ ] If a new standard is added, it is referenced in `README.md`
- [ ] If a new ADR is added, it follows the [ADR template](docs/adr/template.md)
- [ ] Mermaid diagrams are included where architecture is involved

---

### Quality

- [ ] No secrets, credentials, or sensitive data included
- [ ] No real client names, domains, or IP addresses included
- [ ] No `TODO`, `FIXME`, or `HACK` comments without a linked issue

---

### Standards Compliance

- [ ] File names follow the naming conventions (lowercase-hyphenated)
- [ ] Markdown headings use ATX style (`#`, `##`, `###`)
- [ ] Examples in documentation use placeholder values, not real configuration

---

### Security

- [ ] No credentials, tokens, or private keys committed
- [ ] RBAC changes follow least-privilege principle
- [ ] Secret management follows Vault patterns (not hardcoded secrets)
- [ ] Network policies are restrictive (deny-all with explicit allows)
- [ ] `detect-secrets` scan passes

---

### Optional Technical Validation

- [ ] If this PR adds runnable examples, they include the required documentation
- [ ] If this PR changes Kubernetes manifests, they were validated appropriately
- [ ] If this PR changes Terraform, formatting and validation were run

---

### Review

- [ ] Self-reviewed the diff for obvious errors
- [ ] No debug logging or temporary code left in
- [ ] Code is production-ready and not a work-in-progress

---

### Change Type

Select the type of change:

- [ ] Documentation (new or updated standard/guide)
- [ ] New feature (new template or standard)
- [ ] Bug fix (incorrect information, broken link)
- [ ] Security fix
- [ ] Maintenance (repository housekeeping)
- [ ] Refactor (structure change without content change)

---

### Additional Notes

<!-- Add any additional context, design decisions, or trade-offs for reviewers -->
