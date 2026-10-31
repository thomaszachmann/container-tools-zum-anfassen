#!/usr/bin/env bash
# build-images.sh – Stand Ende Tag 1
# Baut die drei notes-Images rootless im Docker-Format (HEALTHCHECK bleibt erhalten).
# Aufruf im Ordner mit notes-api/, notes-web/, notes-worker/: ./build-images.sh [version]
set -euo pipefail
v="${1:-0.1.0}"
cd "$(dirname "$0")"
podman build --format docker -t "localhost/notes-api:$v" --build-arg "VERSION=$v" notes-api
podman build --format docker -t "localhost/notes-web:$v" notes-web
podman build --format docker -t "localhost/notes-worker:$v" notes-worker
podman images --filter reference='localhost/notes-*' --format '{{.Repository}}:{{.Tag}}'
