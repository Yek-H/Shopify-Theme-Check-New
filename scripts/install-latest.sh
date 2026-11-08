#!/usr/bin/env bash
set -euo pipefail
REPO=Yek-H/Shopify-Theme-Check-New
DEST="${1:-$HOME/shopify-theme-tools}"
for command in curl jq sha256sum tar node realpath; do
  command -v "$command" >/dev/null || { echo "$command is required" >&2; exit 1; }
done
if [[ "$DEST" != /* || "$DEST" == */ ]]; then
  echo "Choose an absolute path for a new installation directory." >&2
  exit 1
fi
DEST="$(realpath -sm -- "$DEST")"
if [[ -e "$DEST" || -L "$DEST" ]]; then
  echo "Destination already exists. Choose a new directory." >&2
  exit 1
fi
PARENT="$(dirname -- "$DEST")"
TMP="$(mktemp -d -- "$PARENT/.theme-check-install.XXXXXXXX")"
trap 'rm -rf -- "$TMP"' EXIT
curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" -o "$TMP/release.json"
NAME="$(jq -er '[.assets[].name | select(test("^Shopify-theme-tools-[0-9]+\\.[0-9]+\\.[0-9]+-linux-x64\\.tar\\.gz$"))] | if length == 1 then .[0] else error("Expected one bundle") end' "$TMP/release.json")"
for asset in "$NAME" "$NAME.sha256"; do
  url="$(jq -er --arg name "$asset" '.assets[] | select(.name == $name) | .browser_download_url' "$TMP/release.json")"
  [[ "$url" == "https://github.com/$REPO/releases/download/"* ]] || exit 1
  curl -fsSL "$url" -o "$TMP/$asset"
done
read -r digest filename < "$TMP/$NAME.sha256"
[[ "$digest" =~ ^[a-f0-9]{64}$ && "$filename" == "$NAME" ]] || exit 1
(cd "$TMP" && printf '%s  %s\n' "$digest" "$NAME" | sha256sum -c -)
mkdir "$TMP/install"
tar --no-same-owner -xzf "$TMP/$NAME" -C "$TMP/install"
"$TMP/install/theme-check-local" --version
# No-clobber rename on the same filesystem. A concurrent installer keeps its files.
mv -nT -- "$TMP/install" "$DEST"
[[ ! -e "$TMP/install" ]] || { echo "Destination appeared during installation." >&2; exit 1; }
printf 'Installed at %s\n' "$DEST"
