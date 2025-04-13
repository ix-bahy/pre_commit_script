usage() {
    echo "Usage: $0 [--new] --name <project_name>"
    exit 1
}
new=false
name=""

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
        --help)
            usage
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            ;;
    esac
done

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


if $new; then
  if  [[ -z "$name" ]]; then
      echo "Error: --name is required."
      usage
  fi
fi

if $new; then
  poetry new $name
  cd $name
  git init
  git branch -M main
  poetry install
fi

touch .pre-commit-config.yaml
echo "$yaml" > .pre-commit-config.yaml
poetry add pyproject-pre-commit -G dev
poetry run pre-commit install
touch .pylintrc
