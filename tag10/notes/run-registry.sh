#!/usr/bin/env bash
# run-registry.sh – Stand Ende Tag 7
# Startet die Registry rootless (neu); die Daten bleiben im Volume registry-data.
# Aufruf: ./run-registry.sh [netz]   (Tag 10: ./run-registry.sh kind)
set -euo pipefail
# shellcheck source=/dev/null
source "$HOME/ct-lab/setup/env.sh"
dir="$LAB/registry"
net=()
if [ -n "${1:-}" ]; then net=(--network "$1" --network-alias "$REG_HOST"); fi
podman rm -f registry >/dev/null 2>&1 || true
podman run -d --name registry "${net[@]}" -p "127.0.0.1:$REG_PORT:5000" \
  -v "$dir/certs:/certs:ro" -v "$dir/auth:/auth:ro" \
  -v registry-data:/var/lib/registry \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM=ct-lab \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  docker.io/library/registry:3.1.2
