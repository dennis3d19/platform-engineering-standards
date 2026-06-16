"""Tests for platform engineering standards repository structure and conventions."""

import os
import pathlib
import yaml
import pytest


REPO_ROOT = pathlib.Path(__file__).parent.parent


class TestRequiredFiles:
    """Verify required files are present at the repository root."""

    REQUIRED_FILES = [
        "README.md",
        "LICENSE",
        "SECURITY.md",
        "CONTRIBUTING.md",
        "CHANGELOG.md",
        "CODEOWNERS",
        "Makefile",
        ".editorconfig",
        ".gitignore",
        ".pre-commit-config.yaml",
        ".yamllint.yaml",
        ".markdownlint.yaml",
    ]

    @pytest.mark.parametrize("filename", REQUIRED_FILES)
    def test_required_file_exists(self, filename):
        """Each required file must exist at the repository root."""
        filepath = REPO_ROOT / filename
        assert filepath.exists(), f"Required file missing: {filename}"
        assert filepath.stat().st_size > 0, f"Required file is empty: {filename}"


class TestRequiredDirectories:
    """Verify required directories are present."""

    REQUIRED_DIRS = [
        "docs",
        "docs/standards",
        "docs/adr",
        "docs/checklists",
        "docs/onboarding",
        "docs/runbooks",
        "examples",
        "tests",
        ".github",
        ".github/workflows",
        ".github/ISSUE_TEMPLATE",
    ]

    @pytest.mark.parametrize("dirname", REQUIRED_DIRS)
    def test_required_directory_exists(self, dirname):
        """Each required directory must exist."""
        dirpath = REPO_ROOT / dirname
        assert dirpath.is_dir(), f"Required directory missing: {dirname}"


class TestStandardsDocuments:
    """Verify standards documents are present."""

    STANDARDS_DOCS = [
        "engineering-standards.md",
        "terraform-standards.md",
        "kubernetes-standards.md",
        "helm-standards.md",
        "vault-standards.md",
        "argocd-standards.md",
        "observability-standards.md",
        "github-standards.md",
        "gitlab-standards.md",
        "documentation-standards.md",
        "naming-conventions.md",
        "repository-structure-standards.md",
    ]

    @pytest.mark.parametrize("doc", STANDARDS_DOCS)
    def test_standards_document_exists(self, doc):
        """Each standards document must exist in docs/standards/."""
        filepath = REPO_ROOT / "docs" / "standards" / doc
        assert filepath.exists(), f"Standards document missing: docs/standards/{doc}"
        assert filepath.stat().st_size > 0, f"Standards document is empty: {doc}"


class TestYAMLFiles:
    """Verify YAML files are parseable."""

    def get_yaml_files(self):
        """Find all YAML files in the repository, excluding Helm templates and hidden dirs."""
        yaml_files = []
        for pattern in ["**/*.yaml", "**/*.yml"]:
            for f in REPO_ROOT.glob(pattern):
                # Skip hidden directories and node_modules
                parts = f.parts
                relative_parts = parts[len(REPO_ROOT.parts):]
                if any(p.startswith(".") for p in relative_parts):
                    continue
                if "node_modules" in parts:
                    continue
                # Skip Helm templates — they contain Go template syntax, not pure YAML
                if "templates" in relative_parts:
                    continue
                yaml_files.append(f)
        return yaml_files

    def test_yaml_files_are_parseable(self):
        """All YAML files must be parseable."""
        yaml_files = self.get_yaml_files()
        assert len(yaml_files) > 0, "No YAML files found"

        errors = []
        for yaml_file in yaml_files:
            try:
                with open(yaml_file) as f:
                    content = f.read()
                # Handle multi-document YAML files
                list(yaml.safe_load_all(content))
            except yaml.YAMLError as e:
                errors.append(f"{yaml_file.relative_to(REPO_ROOT)}: {e}")

        assert not errors, f"YAML parse errors:\n" + "\n".join(errors)


class TestGitHubWorkflow:
    """Verify GitHub Actions workflow is present and parseable."""

    def test_validate_workflow_exists(self):
        """The validate.yml workflow must exist."""
        workflow = REPO_ROOT / ".github" / "workflows" / "validate.yml"
        assert workflow.exists(), "validate.yml workflow is missing"

    def test_validate_workflow_parseable(self):
        """The validate.yml workflow must be valid YAML with required sections."""
        workflow = REPO_ROOT / ".github" / "workflows" / "validate.yml"
        with open(workflow) as f:
            content = yaml.safe_load(f)
        assert content is not None
        assert "jobs" in content, "workflow must have jobs"
        # GitHub Actions 'on:' is parsed as boolean True by PyYAML safe_load.
        # We check for the boolean True key (from 'on:') explicitly.
        has_trigger = True in content  # PyYAML parses 'on' keyword as boolean True
        assert has_trigger, (
            "workflow must have an 'on:' trigger (PyYAML parses 'on' as boolean True)"
        )


class TestReadme:
    """Verify README.md meets minimum requirements."""

    def test_readme_has_background_section(self):
        """README must include a Background section."""
        readme = REPO_ROOT / "README.md"
        content = readme.read_text()
        assert "## Background" in content, "README must have a ## Background section"

    def test_readme_has_what_this_demonstrates(self):
        """README must include a What This Demonstrates section."""
        readme = REPO_ROOT / "README.md"
        content = readme.read_text()
        assert "## What This Demonstrates" in content, (
            "README must have a ## What This Demonstrates section"
        )

    def test_readme_no_real_credentials(self):
        """README must not contain common credential patterns."""
        readme = REPO_ROOT / "README.md"
        content = readme.read_text().lower()
        # Check for patterns that indicate real credentials are embedded
        forbidden_patterns = [
            "******api_key=",
            "api-key:",
            "token:",
            "secret_key=",
            "access_key=",
            "private_key",
        ]
        violations = [p for p in forbidden_patterns if p in content]
        assert not violations, (
            f"README may contain credential patterns: {violations}"
        )


class TestExamples:
    """Verify examples include required README files."""

    def test_terraform_example_has_readme(self):
        """Terraform example must have a README."""
        readme = REPO_ROOT / "examples" / "terraform" / "aws-vpc" / "README.md"
        assert readme.exists(), "Terraform example missing README.md"

    def test_kubernetes_example_has_readme(self):
        """Kubernetes example must have a README."""
        readme = REPO_ROOT / "examples" / "kubernetes" / "namespace-setup" / "README.md"
        assert readme.exists(), "Kubernetes example missing README.md"

    def test_helm_example_has_readme(self):
        """Helm example must have a README."""
        readme = REPO_ROOT / "examples" / "helm" / "app-chart" / "README.md"
        assert readme.exists(), "Helm example missing README.md"
