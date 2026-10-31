#!/usr/bin/env bash
# check.sh – prüft das Trainingsgelände; Exit-Code = Zahl der ✘
# shellcheck disable=SC2015  # ok() gibt immer 0 zurück
source "$(dirname "$0")/env.sh"
fail=0
ok() { echo "✔ $1"; }
ko() { echo "✘ $1"; fail=$((fail + 1)); }
. /etc/os-release
[ "$VERSION_ID" = "26.04" ] && ok "Ubuntu $VERSION_ID" || ko "Ubuntu $VERSION_ID (erwartet 26.04)"
for t in podman buildah skopeo jq; do
  command -v "$t" >/dev/null && ok "$t vorhanden" || ko "$t fehlt (sudo apt install $t)"
done
v=$(podman version --format '{{.Client.Version}}' 2>/dev/null)
[[ "$v" == 5.* ]] && ok "Podman $v" || ko "Podman ${v:-fehlt} (erwartet 5.x)"
[ -d "$NOTES/notes-api" ] && ok "Demo-Anwendung unter $NOTES" || ko "$NOTES fehlt"
free=$(df -Pk "$HOME" | awk 'NR==2{print int($4/1048576)}')
# Tag 13: trivy- und grype-Datenbank brauchen zusammen ca. 5 GB
[ "$free" -ge 8 ] && ok "$free GB frei" || ko "nur $free GB frei (mind. 8)"
exit "$fail"
