#!/usr/bin/env bash
# Export the OpenAPI document of every HTTP backend service into
# docs/reference/api/<service>.openapi.json, where the docs site renders it.
#
# Each service's FastAPI app is imported with `uv run` from
# backend/services/<service>. No server is started, and Postgres and
# RabbitMQ are not needed: connections are only opened on startup, which
# never runs here.
#
# Settings come from the service's .sample.env (committed, local-development
# values only). The service's real .env is never read: the script disables
# pydantic-settings' env file for the import.
#
# Output is sorted, indented JSON, so running the script twice produces no
# diff. The only edit to FastAPI's document is info.title, which names the
# service. Commit the generated files together with the change that caused them.
#
# Usage:
#   bash ./scripts/export_openapi.sh              # export every HTTP service
#   bash ./scripts/export_openapi.sh booking      # export one service

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="$ROOT_DIR/backend/services"
OUTPUT_DIR="$ROOT_DIR/docs/reference/api"

# Services that expose an HTTP API. notification only consumes messages.
HTTP_SERVICES=(auth booking dashboard payment)

if [[ $# -gt 1 ]]; then
  echo "Usage: bash ./scripts/export_openapi.sh [service]" >&2
  exit 2
fi

if [[ $# -eq 1 ]]; then
  if [[ ! " ${HTTP_SERVICES[*]} " == *" $1 "* ]]; then
    echo "Unknown HTTP service: $1 (expected one of: ${HTTP_SERVICES[*]})" >&2
    exit 2
  fi
  SELECTED_SERVICES=("$1")
else
  SELECTED_SERVICES=("${HTTP_SERVICES[@]}")
fi

if [[ ! -d "$SERVICES_DIR" ]]; then
  echo "Backend services not found at: $SERVICES_DIR" >&2
  echo "Clone hospitia-backend into backend/ (or run scripts/cloud_bootstrap.sh in a cloud session)." >&2
  exit 1
fi

if ! command -v uv > /dev/null 2>&1; then
  echo "uv is required but was not found on PATH." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

failed=()
for service in "${SELECTED_SERVICES[@]}"; do
  service_dir="$SERVICES_DIR/$service"
  output_file="$OUTPUT_DIR/$service.openapi.json"

  if [[ ! -f "$service_dir/.sample.env" ]]; then
    echo "Missing $service_dir/.sample.env" >&2
    failed+=("$service")
    continue
  fi

  echo "Exporting: $service -> ${output_file#"$ROOT_DIR"/}"
  if ! (
    cd "$service_dir"
    uv run --quiet python - "$service" "$output_file" <<'PYTHON'
import json
import os
import sys

from dotenv import dotenv_values
import pydantic_settings

service, output_file = sys.argv[1], sys.argv[2]

# Settings come only from the committed sample, never from a real .env file.
for key, value in dotenv_values(".sample.env").items():
    os.environ[key] = value or ""
# Production logging writes JSON to stdout only, so the import creates no log files.
os.environ["ENVIRONMENT"] = "production"
os.environ["LOG_FORMAT"] = "json"

_original_init = pydantic_settings.BaseSettings.__init__


def _init_without_env_file(self, *args, **kwargs):
    kwargs.setdefault("_env_file", None)
    _original_init(self, *args, **kwargs)


pydantic_settings.BaseSettings.__init__ = _init_without_env_file

module = __import__(f"{service}.main", fromlist=["app"])
document = module.app.openapi()
# The apps keep FastAPI's default title ("FastAPI"). Name the service so the
# rendered reference page has a meaningful heading. Nothing else is changed.
document["info"]["title"] = f"Hospitia {service} service API"

with open(output_file, "w", encoding="utf-8") as handle:
    json.dump(document, handle, indent=2, sort_keys=True, ensure_ascii=False)
    handle.write("\n")
PYTHON
  ); then
    echo "Failed to export: $service" >&2
    failed+=("$service")
  fi
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "OpenAPI export failed for: ${failed[*]}" >&2
  exit 1
fi

echo "OpenAPI export complete."
