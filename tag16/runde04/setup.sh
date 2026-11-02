#!/usr/bin/env bash
# runde04/setup.sh – Runde 4: legt die Unit r15-api an und lädt systemd neu
set -euo pipefail
q=~/.config/containers/systemd
mkdir -p "$q"
systemctl --user stop r15-api.service 2>/dev/null || true
cp r15-api.container "$q/"
systemctl --user daemon-reload
