#!/bin/bash

usage() {
    echo "Usage: $0 [--new] --name <project_name> [-m|--manager <poetry|rye>]"
    echo "  --new: Create a new project"
    echo "  --name: Name of the project"
    echo "  -m|--manager: Package manager (poetry or rye, default: poetry)"
    exit 1
}

new=false
name=""
manager="poetry"  # Default value

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name)
            name="$2"
            shift 2
            ;;
        --new)
            new=true
            shift
            ;;
        --manager|-m)
            if [[ "$2" == "poetry" || "$2" == "rye" ]]; then
                manager="$2"
                shift 2
            else
                echo "Error: Manager must be either 'poetry' or 'rye'"
                usage
            fi
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            ;;
    esac
done

# YAML content for .pre-commit-config.yaml (unchanged)
yaml="repos:
  # Ruff: A fast linter and formatter (replaces flake8, isort, and others)
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.8
    hooks:
      - id: ruff
        types_or: [python, pyi]
        args: [--fix]  # Automatically fix linting issues

      - id: ruff-format
        types_or: [python, pyi]  # Automatically format code

  # Pre-commit Hooks: General-purpose checks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace  # Remove trailing whitespace
      - id: check-ast            # Check Python files for valid syntax
      - id: check-case-conflict  # Check for files with conflicting case
      - id: check-json           # Validate JSON files
      - id: check-toml           # Validate TOML files
      - id: check-yaml           # Validate YAML files
      - id: end-of-file-fixer    # Ensure files end with a newline

  # Bandit: Security linter
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.7
    hooks:
      - id: bandit  # Check for common security issues

  # Detect Secrets: Prevent committing sensitive information
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['.secrets.baseline']  # Use a baseline file to ignore known secrets

  # OSV Scanner: Check for vulnerable dependencies
  - repo: https://github.com/google/osv-scanner/
    rev: v1.6.2
    hooks:
      - id: osv-scanner
        args: ['-r', '.']  # Scan the project for vulnerable dependencies


  # Type Annotations Enforcer: Ensure functions have type annotations
  - repo: https://github.com/pre-commit/pygrep-hooks
    rev: v1.9.0
    hooks:
      - id: python-use-type-annotations  # Enforce type annotations in Python code"

# Check if --new is set and --name is provided
if $new; then
    if [[ -z "$name" ]]; then
        echo "Error: --name is required."
        usage
    fi
fi

# Create project and set up based on manager
if $new; then
    if [[ "$manager" == "poetry" ]]; then
        poetry new "$name"
        cd "$name" || exit 1
        git init
        git branch -M main
        poetry install
        poetry add pyproject-pre-commit -G dev
    elif [[ "$manager" == "rye" ]]; then
        rye init "$name"
        cd "$name" || exit 1
        git init
        git branch -M main
        rye sync  # Equivalent to poetry install
        rye add pyproject-pre-commit -G dev
    fi

    # Common steps after project creation
    touch .pre-commit-config.yaml
    echo "$yaml" > .pre-commit-config.yaml
    if [[ "$manager" == "poetry" ]]; then
        poetry run pre-commit install
    else
        rye run pre-commit install  # Rye uses "run" for executing commands
    fi
    touch .pylintrc
fi
