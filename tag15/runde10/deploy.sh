#!/usr/bin/env bash
# runde10/deploy.sh – Runde 10 (kaputt): nur signierte Images starten
set -euo pipefail
# shellcheck source=/dev/null
source "$HOME/ct-lab/setup/env.sh"
img="$REG/lab/release-api:stabil"
cosign verify --key ~/ct-lab/keys/cosign.pub --insecure-ignore-tlog=true \
  "$img" >/dev/null
podman run -d --name r15-api10 -p 127.0.0.1:8090:8080 \
  -e NOTES_API_KEY=lab-api-key-123 "$img"
echo "✔ $img gestartet"
