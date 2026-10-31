#!/usr/bin/env bash
# runde05/setup.sh – Runde 5: startet die Datenbank mit start-db.sh
set -euo pipefail
podman rm -f r15-db >/dev/null 2>&1 || true
./start-db.sh >/dev/null
