#!/usr/bin/env bash
# runde03/setup.sh – Runde 3: legt die Unit r15-web an und lädt systemd neu
set -euo pipefail
q=~/.config/containers/systemd
mkdir -p "$q"
systemctl --user stop r15-web.service 2>/dev/null || true
systemctl --user reset-failed r15-web.service 2>/dev/null || true
cp r15-web.container "$q/"
systemctl --user daemon-reload
