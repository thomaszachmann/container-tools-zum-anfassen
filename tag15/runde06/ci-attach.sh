#!/usr/bin/env bash
# runde06/ci-attach.sh – Runde 6 (kaputt): CI-Job kopiert notes-api, hängt die SBOM an
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=/dev/null
source "$HOME/ct-lab/setup/env.sh"
export DOCKER_CONFIG="$PWD/ci-docker"      # frischer Runner: leere Docker-Config
mkdir -p "$DOCKER_CONFIG"
echo "$REG_PASS" | regctl registry login "$REG" -u "$REG_USER" --pass-stdin
regctl tag ls "$REG/notes/notes-api"
crane copy "$REG/notes/notes-api:0.1.0" "$REG/lab/notes-api:r06"
syft -q "registry:$REG/lab/notes-api:r06" -o spdx-json=api.spdx.json
oras attach --artifact-type application/spdx+json "$REG/lab/notes-api:r06" \
  api.spdx.json:application/spdx+json
echo "✔ SBOM angehängt"
