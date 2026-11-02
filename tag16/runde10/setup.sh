#!/usr/bin/env bash
# runde10/setup.sh – Runde 10: Freigabe signieren, danach „nur schnell" nachpushen
set -euo pipefail
# shellcheck source=/dev/null
source "$HOME/ct-lab/setup/env.sh"
export COSIGN_PASSWORD="${COSIGN_PASSWORD:-lab-cosign-pw-123}"
r="$REG/lab/release-api"
podman rm -f r15-api10 >/dev/null 2>&1 || true
for t in $(regctl tag ls "$r" 2>/dev/null); do regctl tag rm "$r:$t"; done
podman push -q localhost/notes-api:0.1.0 "$r:stabil"
cosign sign --key ~/ct-lab/keys/cosign.key --signing-config lab-signing-config.json \
  --yes "$r@$(crane digest "$r:stabil")" >/dev/null 2>&1
podman push -q localhost/notes-api:0.2.0 "$r:stabil"
