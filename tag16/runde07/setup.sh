#!/usr/bin/env bash
# runde07/setup.sh – Runde 7: Test-Registry des Kollegen auf Port REG_PORT+1 (5001)
set -euo pipefail
# shellcheck source=/dev/null
source "$HOME/ct-lab/setup/env.sh"
port=$((REG_PORT + 1))
ca="$LAB/registry/certs"
mkdir -p certs
openssl req -newkey rsa:3072 -nodes -subj "/CN=$REG_HOST" \
  -keyout certs/test.key -out certs/test.csr 2>/dev/null
openssl x509 -req -in certs/test.csr -CA "$ca/ca.crt" -CAkey "$ca/ca.key" \
  -CAcreateserial -days 30 -out certs/test.crt 2>/dev/null
podman rm -f -v r15-registry >/dev/null 2>&1 || true
podman run -d --name r15-registry -p "127.0.0.1:$port:5000" \
  -v "$PWD/certs:/certs:ro" -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/test.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/test.key docker.io/library/registry:3.1.2 >/dev/null
