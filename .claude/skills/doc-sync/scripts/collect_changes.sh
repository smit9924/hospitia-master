#!/usr/bin/env bash
# Summarize what changed in the Hospitia repositories since the docs were last
# synced, grouped by documentation area. Read-only: it never writes to any
# repository (it may only fetch missing history with --deepen-missing).
#
# Baselines come from docs/.sync-state.json in hospitia-master. Each range is
# <stored sha>..HEAD of the repository's current checkout.
#
# Usage (from anywhere):
#   bash collect_changes.sh [--repo master|frontend|backend] [--since <repo>=<sha>]... [--deepen-missing]
#
# Output, per repository:
#   - status: branch, HEAD, baseline, whether the baseline is an ancestor of
#     HEAD, uncommitted changes;
#   - commits in the range (subject, with PR numbers when present);
#   - changed files (status and path) grouped by area. Area names match
#     references/doc-map.md.
#
# Exit codes: 0 ok; 1 a repository or baseline problem that needs the user
# (the output says which); 2 bad arguments.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The skill lives in .agents/skills/doc-sync/scripts or .claude/skills/doc-sync/scripts.
MASTER_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
STATE_FILE="$MASTER_DIR/docs/.sync-state.json"

ONLY_REPO=""
DEEPEN=false
declare -A SINCE=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      ONLY_REPO="${2:-}"; shift 2 ;;
    --since)
      pair="${2:-}"; SINCE["${pair%%=*}"]="${pair#*=}"; shift 2 ;;
    --deepen-missing)
      DEEPEN=true; shift ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: bash collect_changes.sh [--repo master|frontend|backend] [--since <repo>=<sha>]... [--deepen-missing]" >&2
      exit 2 ;;
  esac
done

if [[ -n "$ONLY_REPO" && ! "$ONLY_REPO" =~ ^(master|frontend|backend)$ ]]; then
  echo "--repo must be master, frontend or backend" >&2
  exit 2
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "Sync state not found: $STATE_FILE" >&2
  exit 1
fi

repo_path() {
  case "$1" in
    master) echo "$MASTER_DIR" ;;
    frontend) echo "$MASTER_DIR/frontend" ;;
    backend) echo "$MASTER_DIR/backend" ;;
  esac
}

stored_sha() {
  python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["repos"][sys.argv[2]])' "$STATE_FILE" "$1"
}

# Map a changed path to a documentation area (see references/doc-map.md).
# Patterns are anchored regular expressions; [^/]+ matches one path segment.
AREA_RULES=(
  'backend|^services/[^/]+/[^/]+/(api/routes/|schemas/|api/dependencies\.py$|doc/)|backend-api'
  'backend|^services/[^/]+/[^/]+/database/|backend-data'
  'backend|^services/[^/]+/[^/]+/types/error_codes\.py$|backend-error-codes'
  'backend|^services/[^/]+/[^/]+/(messaging/|handlers/|outbox/|exceptions/handlers/consumer)|backend-messaging'
  'backend|^services/[^/]+/(\.sample\.env|\.sample\.cloud-dev\.env|[^/]+/core/config\.py)$|backend-config'
  'backend|^services/notification/notification/templates/|backend-email-templates'
  'backend|^services/[^/]+/jenkins/|ci-cd'
  'backend|^(services/[^/]+/README\.md|README\.md|CONTRIBUTING\.md|SECURITY\.md|\.github/)|repo-meta'
  'backend|^services/[^/]+/(pyproject\.toml|uv\.lock)$|backend-dependencies'
  'backend|^scripts/|scripts'
  'backend|^services/[^/]+/[^/]+/(api/services/|api/repositories/|exceptions/|core/|middleware/|logging/|types/|main\.py$)|backend-logic'
  'backend|^services/[^/]+/[^/]+/[^/]+$|backend-logic'
  'backend|^services/|backend-other'
  'frontend|^clients/[^/]+/src/app/(app\.routes\.ts$|guards/|data/app-routes\.ts$|data/sidebar-navigation\.ts$)|frontend-routing'
  'frontend|^clients/[^/]+/src/app/(data/api-routes\.ts$|services/|interceptors/)|frontend-services'
  'frontend|^clients/[^/]+/src/(styles/|assets/fonts/)|frontend-styles'
  'frontend|^clients/[^/]+/src/environments/|frontend-config'
  'frontend|^clients/[^/]+/src/locale/|frontend-i18n'
  'frontend|^clients/[^/]+/src/app/components/|frontend-components'
  'frontend|^clients/[^/]+/jenkins/|ci-cd'
  'frontend|^(clients/[^/]+/README\.md|README\.md|CONTRIBUTING\.md|SECURITY\.md|\.github/)|repo-meta'
  'frontend|^clients/[^/]+/(package\.json|package-lock\.json|angular\.json|eslint\.config\.js|tsconfig[^/]*)$|frontend-tooling'
  'frontend|^clients/[^/]+/src/(app/(data|types|pipes|directives|error)/|assets/)|frontend-shared'
  'frontend|^clients/|frontend-other'
  'master|^(docs/|mkdocs\.yml$|CHANGELOG\.md$)|docs-itself'
  'master|^(\.agents/rules/|\.claude/rules/|\.cursor/rules/|CLAUDE\.md$)|agent-rules'
  'master|^(\.agents/skills/|\.claude/skills/)|agent-skills'
  'master|^(\.devcontainer/|\.vscode/)|dev-environment'
  'master|^scripts/|scripts'
  'master|^jenkins/|ci-cd'
  'master|^server-setup/|deployment'
  'master|^(README\.md|CONTRIBUTING\.md|CODE_OF_CONDUCT\.md|SECURITY\.md|\.github/)|repo-meta'
)

area_of() {
  local repo="$1" path="$2" rule rule_repo rest pattern area
  for rule in "${AREA_RULES[@]}"; do
    rule_repo="${rule%%|*}"
    rest="${rule#*|}"
    pattern="${rest%|*}"
    area="${rest##*|}"
    if [[ "$rule_repo" == "$repo" && "$path" =~ $pattern ]]; then
      echo "$area"
      return
    fi
  done
  echo "unmapped"
}

problems=0
for repo in master frontend backend; do
  [[ -n "$ONLY_REPO" && "$repo" != "$ONLY_REPO" ]] && continue
  dir="$(repo_path "$repo")"
  echo "================================================================"
  echo "REPO $repo ($dir)"

  if ! git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
    echo "STATUS missing: no Git repository at $dir"
    problems=1
    continue
  fi

  base="${SINCE[$repo]:-$(stored_sha "$repo")}"
  head="$(git -C "$dir" rev-parse HEAD)"
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
  dirty="$(git -C "$dir" status --porcelain | wc -l | tr -d ' ')"
  echo "BRANCH $branch"
  echo "HEAD $head"
  echo "BASELINE $base"
  echo "UNCOMMITTED_CHANGES $dirty"

  if ! git -C "$dir" cat-file -e "${base}^{commit}" 2> /dev/null; then
    if $DEEPEN; then
      git -C "$dir" fetch --quiet --deepen=200 origin > /dev/null 2>&1 || true
    fi
    if ! git -C "$dir" cat-file -e "${base}^{commit}" 2> /dev/null; then
      echo "STATUS baseline-unknown: $base is not in the local history (shallow clone?). Rerun with --deepen-missing or ask the user."
      problems=1
      continue
    fi
  fi

  if ! git -C "$dir" merge-base --is-ancestor "$base" "$head"; then
    echo "STATUS baseline-not-ancestor: merge-base is $(git -C "$dir" merge-base "$base" "$head" || echo none). Ask the user which baseline to use."
    problems=1
    continue
  fi

  count="$(git -C "$dir" rev-list --count "$base..$head")"
  echo "COMMITS $count"
  if [[ "$count" -eq 0 ]]; then
    echo "STATUS in-sync"
    continue
  fi
  echo "STATUS changes"

  echo "--- commits (oldest first)"
  git -C "$dir" log --reverse --no-merges --format='%h %ad %s' --date=short "$base..$head"
  echo "--- merges"
  git -C "$dir" log --reverse --merges --format='%h %ad %s' --date=short "$base..$head"

  # New or removed services (backend) and client apps (frontend) need new
  # pages, nav entries, stubs and rules; report them explicitly.
  case "$repo" in
    backend) units_dir="services" ;;
    frontend) units_dir="clients" ;;
    *) units_dir="" ;;
  esac
  if [[ -n "$units_dir" ]]; then
    before_units="$(git -C "$dir" ls-tree -d --name-only "$base" "$units_dir/" 2> /dev/null | sort)"
    after_units="$(git -C "$dir" ls-tree -d --name-only "$head" "$units_dir/" 2> /dev/null | sort)"
    echo "--- structure"
    comm -13 <(echo "$before_units") <(echo "$after_units") | sed '/^$/d; s/^/ADDED_UNIT /'
    comm -23 <(echo "$before_units") <(echo "$after_units") | sed '/^$/d; s/^/REMOVED_UNIT /'
  fi

  echo "--- files by area"
  git -C "$dir" diff --name-status --find-renames "$base" "$head" \
    | while IFS=$'\t' read -r status path new_path; do
        shown="$path"
        [[ -n "${new_path:-}" ]] && shown="$path -> $new_path" && path="$new_path"
        printf '%s\t%s\t%s\n' "$(area_of "$repo" "$path")" "${status:0:1}" "$shown"
      done | sort
done

exit $problems
