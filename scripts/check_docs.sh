#!/usr/bin/env bash
# Check the documentation site and the generated agent files.
#
# Runs a strict MkDocs build with the pinned dependencies from
# docs/requirements.txt. The build fails on broken internal links, broken
# anchors, and pages that exist under docs/ but are missing from the nav in
# mkdocs.yml. The site is built into a temporary directory, so nothing in the
# repository changes. It also checks that the generated agent rules
# (scripts/sync_agent_rules.sh) and agent skills (scripts/sync_agent_skills.sh)
# match their sources in .agents/.
#
# Usage:
#   bash ./scripts/check_docs.sh
#
# Preview the site while writing (http://127.0.0.1:8000):
#   uv run --no-project --with-requirements docs/requirements.txt mkdocs serve

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQUIREMENTS_FILE="$ROOT_DIR/docs/requirements.txt"

if [[ $# -gt 0 ]]; then
  echo "Usage: bash ./scripts/check_docs.sh (takes no arguments)" >&2
  exit 2
fi

if ! command -v uv > /dev/null 2>&1; then
  echo "uv is required but was not found on PATH." >&2
  exit 1
fi

if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
  echo "Docs requirements not found: $REQUIREMENTS_FILE" >&2
  exit 1
fi

site_dir="$(mktemp -d)"
trap 'rm -rf "$site_dir"' EXIT

echo "Building docs (strict)..."
(
  cd "$ROOT_DIR"
  NO_MKDOCS_2_WARNING=1 uv run --no-project --quiet \
    --with-requirements "$REQUIREMENTS_FILE" \
    mkdocs build --strict --site-dir "$site_dir"
)
echo "Docs build passed."

echo "Checking agent rules..."
bash "$ROOT_DIR/scripts/sync_agent_rules.sh" --check

echo "Checking agent skills..."
bash "$ROOT_DIR/scripts/sync_agent_skills.sh" --check

echo "All documentation checks passed."
