#!/usr/bin/env bash
# runde09/gate.sh – Runde 9: Schwachstellen-Gate für notes-api (ab HIGH, mit Fix)
set -euo pipefail
cd "$(dirname "$0")"
trivy image -q --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed \
  --exit-code 1 localhost/notes-api:0.1.0
echo "✔ Gate bestanden"
