#!/usr/bin/env bash
# runde02/setup.sh – Runde 2: baut mit build.sh und startet notes-api als r15-api2
set -euo pipefail
podman rm -f r15-api2 >/dev/null 2>&1 || true
./build.sh >/dev/null 2>&1
podman run -d --name r15-api2 -e NOTES_API_KEY=lab-api-key-123 \
  localhost/notes-api:r02 >/dev/null
