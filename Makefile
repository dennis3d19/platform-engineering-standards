# Platform Engineering Standards - Makefile
#
# Usage:
#   make help          - Show this help message
#   make install       - Install pre-commit hooks and tooling
#   make validate      - Run all validation checks
#   make lint          - Run linting checks only
#   make format        - Auto-format files (YAML, Markdown, shell)
#   make security      - Run security scans
#   make test          - Run tests
#   make clean         - Remove generated files

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

PYTHON := python3
PIP := pip3

# Colours for help output
BOLD := $(shell tput bold 2>/dev/null || echo "")
RESET := $(shell tput sgr0 2>/dev/null || echo "")
GREEN := $(shell tput setaf 2 2>/dev/null || echo "")
YELLOW := $(shell tput setaf 3 2>/dev/null || echo "")

.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

.PHONY: install
install: ## Install pre-commit hooks and required tools
	@echo "$(BOLD)Installing pre-commit hooks...$(RESET)"
	pre-commit install
	pre-commit install --hook-type commit-msg
	@echo "$(GREEN)Installation complete.$(RESET)"

.PHONY: validate
validate: lint security test ## Run all validation checks

.PHONY: lint
lint: lint-yaml lint-markdown lint-shell ## Run all linting checks

.PHONY: lint-yaml
lint-yaml: ## Lint YAML files
	@echo "$(BOLD)Linting YAML files...$(RESET)"
	yamllint .

.PHONY: lint-markdown
lint-markdown: ## Lint Markdown files
	@echo "$(BOLD)Linting Markdown files...$(RESET)"
	markdownlint '**/*.md' --ignore node_modules --ignore .git

.PHONY: lint-shell
lint-shell: ## Lint shell scripts
	@echo "$(BOLD)Linting shell scripts...$(RESET)"
	@find . -name "*.sh" -not -path "./.git/*" -not -path "./node_modules/*" \
		-exec shellcheck {} +
	@find . -name "*.sh" -not -path "./.git/*" -not -path "./node_modules/*" \
		-exec shfmt -d {} +

.PHONY: format
format: format-yaml format-shell ## Auto-format files

.PHONY: format-yaml
format-yaml: ## Format YAML files (check only)
	@echo "$(BOLD)Checking YAML formatting...$(RESET)"
	yamllint .

.PHONY: format-shell
format-shell: ## Format shell scripts in-place
	@echo "$(BOLD)Formatting shell scripts...$(RESET)"
	@find . -name "*.sh" -not -path "./.git/*" -not -path "./node_modules/*" \
		-exec shfmt -w {} +

.PHONY: security
security: security-secrets ## Run all security scans

.PHONY: security-secrets
security-secrets: ## Scan for secrets and credentials
	@echo "$(BOLD)Scanning for secrets...$(RESET)"
	detect-secrets scan --baseline .secrets.baseline \
		--exclude-files '\.git/.*' \
		--exclude-files 'node_modules/.*'

.PHONY: security-baseline
security-baseline: ## Create or update secrets baseline
	@echo "$(BOLD)Creating secrets baseline...$(RESET)"
	detect-secrets scan \
		--exclude-files '\.git/.*' \
		--exclude-files 'node_modules/.*' \
		> .secrets.baseline
	@echo "$(GREEN)Baseline created: .secrets.baseline$(RESET)"

.PHONY: pre-commit
pre-commit: ## Run all pre-commit hooks against all files
	@echo "$(BOLD)Running pre-commit hooks...$(RESET)"
	pre-commit run --all-files

.PHONY: test
test: ## Run tests
	@echo "$(BOLD)Running tests...$(RESET)"
	@if command -v pytest &>/dev/null; then \
		pytest tests/ -v; \
	else \
		echo "$(YELLOW)pytest not installed, skipping Python tests$(RESET)"; \
	fi
	@$(MAKE) --no-print-directory validate-examples

.PHONY: validate-examples
validate-examples: ## Validate example files
	@echo "$(BOLD)Validating examples...$(RESET)"
	@find examples/ -name "*.yaml" -o -name "*.yml" | \
		xargs -I{} yamllint {}
	@echo "$(GREEN)Examples validation complete.$(RESET)"

.PHONY: clean
clean: ## Remove generated files and caches
	@echo "$(BOLD)Cleaning generated files...$(RESET)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@echo "$(GREEN)Clean complete.$(RESET)"

.PHONY: check-tools
check-tools: ## Check that required tools are installed
	@echo "$(BOLD)Checking required tools...$(RESET)"
	@for tool in pre-commit yamllint markdownlint shellcheck shfmt detect-secrets; do \
		if command -v "$$tool" &>/dev/null; then \
			echo "$(GREEN)✓ $$tool$(RESET)"; \
		else \
			echo "  ✗ $$tool (not installed)"; \
		fi; \
	done

.PHONY: docs
docs: ## Generate documentation index
	@echo "$(BOLD)Generating documentation index...$(RESET)"
	@echo "# Documentation Index" > docs/INDEX.md
	@echo "" >> docs/INDEX.md
	@find docs/ -name "*.md" -not -name "INDEX.md" | sort | \
		while read -r f; do \
			title=$$(head -1 "$$f" | sed 's/^# //'); \
			echo "- [$$title]($$f)" >> docs/INDEX.md; \
		done
	@echo "$(GREEN)Documentation index generated: docs/INDEX.md$(RESET)"
