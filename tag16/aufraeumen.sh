#!/usr/bin/env bash
# aufraeumen.sh – Stand Ende Tag 16: entfernt alles, was die Runden angelegt haben
# Container r15-*, Units r15-*, Images localhost/r15-* und notes-api:r02, alle Tags in
# lab/notes-api und lab/release-api (samt sha256-…). Die Rundenordner bleiben liegen.
set -uo pipefail
# shellcheck source=/dev/null
source "${LAB:-$HOME/ct-lab}/setup/env.sh"
q=~/.config/containers/systemd
for u in r15-web r15-api; do
  systemctl --user stop "$u.service" 2>/dev/null
  rm -f "$q/$u.container"
done
systemctl --user daemon-reload
podman ps -aq --filter name='^r15-' | xargs -r podman rm -f -v -t 0 >/dev/null
podman images -q --filter reference='localhost/r15-*' \
  | xargs -r podman rmi -f >/dev/null
podman rmi -f localhost/notes-api:r02 >/dev/null 2>&1
for r in lab/notes-api lab/release-api; do
  for t in $(regctl tag ls "$REG/$r" 2>/dev/null); do regctl tag rm "$REG/$r:$t"; done
done
echo "✔ Container r15-*: $(podman ps -aq --filter name='^r15-' | wc -l)"
echo "✔ Tags in lab/: $(regctl tag ls "$REG/lab/notes-api" 2>/dev/null | wc -l)"
