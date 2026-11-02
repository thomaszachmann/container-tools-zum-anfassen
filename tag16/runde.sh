#!/usr/bin/env bash
# runde.sh NN|challenge – Stand Ende Tag 16: baut eine Desaster-Runde auf
# Legt ~/ct-lab/tag16/rundeNN neu an: Demo-Anwendung (code/notes) plus kaputter Stand
# aus code/tag16/rundeNN, danach läuft dort setup.sh, falls vorhanden. Ein alter
# Rundenordner wird ersetzt. Dein Stand von Tag 15 bleibt unberührt.
set -euo pipefail
# shellcheck source=/dev/null
source "${LAB:-$HOME/ct-lab}/setup/env.sh"
nr="${1:?Aufruf: runde.sh 01..10 oder runde.sh challenge}"
case "$nr" in
  challenge) name=challenge ;;
  0[1-9] | 10) name="runde$nr" ;;
  *) echo "✘ unbekannte Runde: $nr" >&2; exit 1 ;;
esac
src="$LAB/code/tag16/$name"
dst="$LAB/tag16/$name"
[ -d "$src" ] || { echo "✘ $src fehlt" >&2; exit 1; }
# Runde 5 hinterlässt Dateien fremder UIDs: Löschen im User Namespace (Tag 2)
[ -e "$dst" ] && podman unshare rm -rf "$dst"
mkdir -p "$dst"
cp -R "$LAB/code/notes/." "$dst/"
cp -R "$src/." "$dst/"
chmod +x "$dst"/*.sh 2>/dev/null || true
if [ -f "$dst/setup.sh" ]; then
  (cd "$dst" && bash ./setup.sh)
fi
echo "✔ $dst bereit"
