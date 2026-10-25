#!/usr/bin/env bash
# Sync agent skills from the canonical .agents/skills/ directory into the
# tool-specific skill directories (currently .claude/skills/ for Claude Code).
#
# .agents/skills/ is the source of truth: edit skills there, then run this script.
# Skills that exist only in a target directory are left untouched.
#
# Usage:
#   bash ./scripts/sync_agent_skills.sh           # copy skills into each target
#   bash ./scripts/sync_agent_skills.sh --check   # report drift only; exit 1 if any

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/.agents/skills"
TARGET_DIRS=("$ROOT_DIR/.claude/skills")

CHECK_ONLY=false
if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
elif [[ -n "${1:-}" ]]; then
  echo "Unknown option: $1 (expected --check or nothing)" >&2
  exit 2
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

drift=0
for skill_path in "$SOURCE_DIR"/*/; do
  [[ -f "$skill_path/SKILL.md" ]] || continue
  skill_name="$(basename "$skill_path")"

  for target_dir in "${TARGET_DIRS[@]}"; do
    target_path="$target_dir/$skill_name"
    relative_target="${target_path#"$ROOT_DIR"/}"

    if $CHECK_ONLY; then
      if ! diff -rq "$skill_path" "$target_path" > /dev/null 2>&1; then
        echo "Out of sync: $relative_target"
        drift=1
      fi
    else
      mkdir -p "$target_dir"
      rm -rf "$target_path"
      cp -r "$skill_path" "$target_path"
      echo "Synced: $skill_name -> $relative_target"
    fi
  done
done

if $CHECK_ONLY && [[ $drift -eq 0 ]]; then
  echo "All skills in sync."
fi
exit $drift
