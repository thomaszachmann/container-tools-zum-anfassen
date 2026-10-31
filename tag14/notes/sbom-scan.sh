#!/usr/bin/env bash
# sbom-scan.sh – Stand Ende Tag 13: SBOM einmal erzeugen, dann getrennt scannen
# Aufruf: ./sbom-scan.sh <quelle> [schwelle], z. B.
#   ./sbom-scan.sh podman:localhost/notes-api:0.1.0 high
set -euo pipefail
src=${1:?Quelle angeben, z. B. podman:localhost/notes-api:0.1.0}
fail_on=${2:-high}
name=$(basename "${src#*:}" | tr ':@' '__')
sbom="$name.cdx.json"
syft -q "$src" -o cyclonedx-json="$sbom"
echo "✔ SBOM $sbom: $(jq '.components | length' "$sbom") Komponenten"
if grype -q "sbom:$sbom" --only-fixed --fail-on "$fail_on" -o json > "$name.grype.json"
then
  echo "✔ grype: kein behebbarer Befund ab $fail_on"
else
  rc=$?
  echo "✘ grype: behebbare Befunde ab $fail_on (Exit $rc)"
  jq -r '.matches[] | [.vulnerability.severity, .artifact.name, .vulnerability.id]
         | "  " + join(" ")' "$name.grype.json" | sort -u | head -5 || true
  exit "$rc"
fi
