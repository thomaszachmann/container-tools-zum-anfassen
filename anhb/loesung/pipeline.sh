#!/usr/bin/env bash
# pipeline.sh – Anhang B, Lösung: die ganze Kette als ein Skript (Exit ≠ 0 = Abbruch)
# Containerfile → hadolint → buildah → dive/dockle → trivy/grype → syft → Push → cosign
# Aufruf im Ordner ~/ct-lab/anhb: COSIGN_PASSWORD=… ./pipeline.sh 1.0.0
set -euo pipefail
# shellcheck source=/dev/null
source "$HOME/ct-lab/setup/env.sh"
v=${1:?Version angeben, z. B. 1.0.0}
: "${COSIGN_PASSWORD:?COSIGN_PASSWORD setzen}"
export DOCKLE_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
img="localhost/notes-api:$v"
key=~/ct-lab/keys/cosign
step() { echo "== $*"; }

step "1/7 hadolint"
hadolint notes-api/Containerfile
step "2/7 buildah build"
buildah build -q --format docker --timestamp 0 --build-arg "VERSION=$v" \
  -f notes-api/Containerfile -t "$img" notes-api >/dev/null
step "3/7 dive und dockle"
dive --ci --source podman "$img" >/dev/null
dockle -c 1 "$img" >/dev/null
step "4/7 trivy und grype"
trivy image -q --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed \
  --exit-code 1 "$img" >/dev/null
grype -q "podman:$img" --only-fixed --fail-on high >/dev/null
step "5/7 syft"
mkdir -p sbom
syft -q "podman:$img" -o "cyclonedx-json=sbom/notes-api-$v.cdx.json" \
  -o "spdx-json=sbom/notes-api-$v.spdx.json" -o "syft-json=sbom/notes-api-$v.syft.json"
step "6/7 push"
podman push -q --digestfile digest.txt "$img" "$REG/anhb/notes-api:$v"
ref="$REG/anhb/notes-api@$(cat digest.txt)"
step "7/7 cosign"
cosign sign --key "$key.key" --signing-config lab-signing-config.json --yes \
  -a "version=$v" "$ref" >/dev/null 2>&1
cosign attest --key "$key.key" --signing-config lab-signing-config.json --yes \
  --type cyclonedx --predicate "sbom/notes-api-$v.cdx.json" "$ref" >/dev/null 2>&1
cosign verify --key "$key.pub" --insecure-ignore-tlog=true -a "version=$v" \
  "$ref" >/dev/null 2>&1
cosign verify-attestation --key "$key.pub" --insecure-ignore-tlog=true \
  --type cyclonedx "$ref" >/dev/null 2>&1
echo "✔ $ref"
