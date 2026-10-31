#!/usr/bin/env bash
# registry.sh – eigene Registry wie an Tag 7: CA, TLS, Login, rootless mit Podman
# Idempotent. Braucht sudo für /etc/hosts und den CA-Speicher des Systems.
set -euo pipefail
source "$(dirname "$0")/env.sh"
dir="$LAB/registry"
mkdir -p "$dir/certs" "$dir/auth"
cd "$dir/certs"
if [ ! -f ca.crt ]; then
  openssl req -x509 -newkey rsa:3072 -nodes -days 365 -subj "/CN=ct-lab CA ($USER)" \
    -keyout ca.key -out ca.crt 2>/dev/null
  openssl req -newkey rsa:3072 -nodes -subj "/CN=$REG_HOST" \
    -keyout registry.key -out registry.csr 2>/dev/null
  printf 'subjectAltName=DNS:%s\nextendedKeyUsage=serverAuth\n' "$REG_HOST" > ext.cnf
  openssl x509 -req -in registry.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -days 90 -extfile ext.cnf -out registry.crt 2>/dev/null
fi
sudo install -m 0644 ca.crt "/usr/local/share/ca-certificates/ct-lab-$USER.crt"
sudo update-ca-certificates >/dev/null
grep -q " $REG_HOST\$" /etc/hosts || echo "127.0.0.1 $REG_HOST" | sudo tee -a /etc/hosts >/dev/null
htpasswd -Bbn "$REG_USER" "$REG_PASS" > "$dir/auth/htpasswd"
podman rm -f registry >/dev/null 2>&1 || true
podman run -d --name registry -p "127.0.0.1:$REG_PORT:5000" \
  -v "$dir/certs:/certs:ro" -v "$dir/auth:/auth:ro" -v registry-data:/var/lib/registry \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM=ct-lab \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  docker.io/library/registry:3.1.2 >/dev/null
for _ in $(seq 1 20); do
  curl -fsS -o /dev/null -u "$REG_USER:$REG_PASS" "https://$REG/v2/" 2>/dev/null && break; sleep 1
done
if ! curl -fsS -o /dev/null -u "$REG_USER:$REG_PASS" "https://$REG/v2/"; then
  echo "✘ Registry antwortet nicht" >&2; exit 1
fi
echo "✔ Registry https://$REG läuft"
