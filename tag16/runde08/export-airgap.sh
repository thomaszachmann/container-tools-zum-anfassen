#!/usr/bin/env bash
# runde08/export-airgap.sh – Runde 8 (kaputt): notes-api als Archiv fürs Air-Gap
set -euo pipefail
cd "$(dirname "$0")"
skopeo copy containers-storage:localhost/notes-api:0.1.0 \
  docker-archive:notes-api-0.1.0.tar:localhost/notes-api:0.1.0
sha256sum notes-api-0.1.0.tar > notes-api-0.1.0.tar.sha256
echo "✔ notes-api-0.1.0.tar fertig"
