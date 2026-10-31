#!/usr/bin/env bash
# runde05/start-db.sh – Runde 5 (kaputt): Postgres als UID 70 mit Daten im Projekt
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p pgdata
podman run -d --name r15-db --user 70:70 -e POSTGRES_PASSWORD=lab-db-pw-123 \
  -v ./pgdata:/var/lib/postgresql docker.io/library/postgres:18.6-alpine
