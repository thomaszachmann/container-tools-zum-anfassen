#!/usr/bin/env bash
# buildah-api.sh – Stand Ende Tag 5
# Baut notes-api ohne Dockerfile, nur mit Buildah-Befehlen.
# Aufruf im Ordner mit notes-api/: ./buildah-api.sh [version]
set -euo pipefail
v="${1:-0.2.0}"
cd "$(dirname "$0")"

# 1. Build-Container aus dem Go-Image, Quellcode hinein, kompilieren
b=$(buildah from --name api-build docker.io/library/golang:1.27-alpine)
buildah copy "$b" notes-api /src
buildah run --workingdir /src -e CGO_ENABLED=0 "$b" -- \
  go build -trimpath -ldflags="-s -w -X main.version=$v" -o /out/notes-api .

# 2. Leerer Container (scratch, Docker-Format), Binary und CA-Zertifikate hinein
f=$(buildah from --format docker --name api-final scratch)
buildah copy --from "$b" "$f" /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
buildah copy --from "$b" --chmod 555 "$f" /out/notes-api /notes-api

# 3. Konfiguration wie im Dockerfile, dann Image schreiben
buildah config --port 8080 --user 65532:65532 --stop-signal SIGTERM \
  --entrypoint '["/notes-api"]' \
  --healthcheck 'CMD /notes-api healthcheck' \
  --healthcheck-interval 10s --healthcheck-timeout 2s \
  --healthcheck-start-period 5s --healthcheck-start-interval 1s \
  --label org.opencontainers.image.title=notes-api \
  --label org.opencontainers.image.version="$v" "$f"
buildah commit --format docker --rm "$f" "localhost/notes-api:$v-buildah"
buildah rm "$b" >/dev/null
