# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the Platform Engineering Standards repository.

## What is an ADR?

An ADR documents a significant architectural decision made during the development of the platform. Each ADR captures:

- The context and problem that prompted the decision
- The decision that was made
- The consequences and trade-offs

ADRs are immutable — once accepted, they are not edited. If a decision is reversed, a new ADR is created that
supersedes the previous one.

## Index

| ADR | Title | Status | Date |
|---|---|---|---|
| [ADR-0001](0001-use-terraform-for-iac.md) | Use Terraform for Infrastructure as Code | Accepted | 2024-01-01 |

## ADR Statuses

| Status | Meaning |
|---|---|
| `Proposed` | Under discussion, not yet decided |
| `Accepted` | Decision made and in effect |
| `Deprecated` | Previously accepted, no longer recommended |
| `Superseded` | Replaced by a newer ADR |

## Creating a New ADR

1. Copy [template.md](template.md) to `NNNN-short-title.md` (zero-padded sequential number).
2. Fill in all sections.
3. Set status to `Proposed`.
4. Open a pull request for review.
5. Update status to `Accepted` once approved.
6. Add to the index table above.
