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
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.8
    hooks:

      - id: ruff
        types_or: [ python, pyi ]
        args: [ --fix ]

      - id: ruff-format
        types_or: [ python, pyi ]

  - repo: https://github.com/PyCQA/pylint
    rev: v3.1.0
    hooks:
      - id: pylint
        args: ["--rcfile=.pylintrc"]

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: check-ast
      - id: check-builtin-literals
      - id: check-case-conflict
      - id: check-executables-have-shebangs
      - id: check-json
      - id: check-docstring-first
      - id: check-toml
      - id: check-yaml
      - id: end-of-file-fixer

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.7
    hooks:
      - id: bandit

  - repo: https://github.com/RobertCraigie/pyright-python
    rev: v1.1.383
    hooks:
    - id: pyright

  - repo: https://github.com/PyCQA/flake8
    rev: 7.0.0
    hooks:
      - id: flake8

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: [".secrets.baseline"]

  - repo: https://github.com/google/osv-scanner/
    rev: v1.6.2
    hooks:
      - id: osv-scanner
        args: ["-r", "."]"


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