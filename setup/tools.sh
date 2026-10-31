#!/usr/bin/env bash
# tools.sh [name …] – installiert Release-Binaries aus tools.lock nach /usr/local/bin
# Ohne Argument: alle. Jede Datei wird vor dem Installieren gegen ihre SHA-256 geprüft.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64) arch=arm64 ;;
  *) echo "✘ Architektur $(uname -m) nicht unterstützt" >&2; exit 1 ;;
esac
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

install_one() { # name url sha256
  local name=$1 url=$2 sum=$3 file="$work/${2##*/}"
  curl -fsSL -o "$file" "$url"
  echo "$sum  $file" | sha256sum -c --quiet - || { echo "✘ $name: Prüfsumme falsch" >&2; exit 1; }
  case "$name" in
    nerdctl-full)            # containerd, nerdctl, buildctl, runc, CNI … nach /usr/local
      sudo tar -C /usr/local -xzf "$file" ;;
    crane)                   # Paket enthält crane, gcrane und krane
      tar -C "$work" -xzf "$file" crane krane
      sudo install -m 0755 "$work/crane" "$work/krane" /usr/local/bin/ ;;
    crictl|dive|lazydocker|trivy|syft|oras|grype|dockle|ko)
      tar -C "$work" -xzf "$file" "$name"
      sudo install -m 0755 "$work/$name" /usr/local/bin/ ;;
    *)                       # einzelnes Binary
      sudo install -m 0755 "$file" "/usr/local/bin/$name" ;;
  esac
  echo "✔ $name"
}

want=("$@")
while read -r name a url sum; do
  [[ -z "$name" || "$name" == \#* || "$a" != "$arch" ]] && continue
  if [ ${#want[@]} -eq 0 ] || [[ " ${want[*]} " == *" $name "* ]]; then
    install_one "$name" "$url" "$sum"
  fi
done < "$here/tools.lock"
