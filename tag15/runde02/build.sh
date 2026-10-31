#!/usr/bin/env bash
# runde02/build.sh – Runde 2 (kaputt): CI-Build von notes-api, neu mit Buildah
set -euo pipefail
cd "$(dirname "$0")"
buildah build -t localhost/notes-api:r02 --build-arg VERSION=r02 notes-api
