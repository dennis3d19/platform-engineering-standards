# Tests

This directory contains tests for the platform engineering standards repository.

---

## Test Structure

```
tests/
├── fixtures/          # Static test fixtures and sample data
└── README.md          # This file
```

## Running Tests

```bash
# Run all tests
make test

# Run with pytest directly
pytest tests/ -v

# Run specific test file
pytest tests/test_yaml_standards.py -v
```

## Test Categories

### YAML Validation

Validates that all YAML files in the repository pass `yamllint`.

### Markdown Validation

Validates that all Markdown files follow the project's markdownlint configuration.

### Example Validation

Validates that example files are well-formed and include required sections.

## Fixtures

Test fixtures in `tests/fixtures/` are static data files used by tests.
Fixtures must use placeholder values — never real credentials, domains, or IP addresses.
