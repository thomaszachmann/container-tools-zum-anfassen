# shellcheck shell=bash
# env.sh – zum source'n: Variablen des Trainingsgeländes (für Tests überschreibbar)
export LAB="${LAB:-$HOME/ct-lab}"
export NOTES="$LAB/notes"
export REG_HOST="${REG_HOST:-registry.ct.lab}"
export REG_PORT="${REG_PORT:-5000}"
export REG="$REG_HOST:$REG_PORT"              # eigene Registry ab Tag 7
export REG_USER=lab
export REG_PASS="${REG_PASS:-lab-registry-pw-123}"   # Lab-Wert
