#!/usr/bin/env bash
set -euo pipefail
archive="$(realpath -- "$1")"
fixture="$(realpath -- "$2")"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
(cd "$(dirname -- "$archive")" && sha256sum -c "$(basename -- "$archive").sha256")
mkdir "$tmp/bundle" "$tmp/bin" "$tmp/cache"
tar --no-same-owner -xzf "$archive" -C "$tmp/bundle"
for cmd in bash dirname node; do
  ln -s "$(command -v "$cmd")" "$tmp/bin/$cmd"
done
cp -a "$fixture" "$tmp/theme"
mkdir -p "$tmp/theme/snippets"
run() { PATH="$tmp/bin" XDG_CACHE_HOME="$tmp/cache" "$tmp/bundle/theme-check-local" "$@"; }
[[ "$(run --version)" == "$(jq -r .theme_check_version "$tmp/bundle/BUILD_METADATA.json")" ]]
run "$tmp/theme" > "$tmp/good.json"
jq -e 'type == "array" and all(.[]; .severity != 0)' "$tmp/good.json"
printf '%s\n' '{% if product %}' > "$tmp/theme/snippets/bad.liquid"
status=0
run "$tmp/theme" > "$tmp/bad.json" || status=$?
[[ "$status" == 1 ]]
jq -e 'any(.[]; .check == "LiquidHTMLSyntaxError")' "$tmp/bad.json"
rm -- "$tmp/theme/snippets/bad.liquid"
printf '%s\n' "require: './checks.cjs'" > "$tmp/theme/.theme-check.yml"
printf '%s\n' "require('node:fs').writeFileSync(require('node:path').join(__dirname, 'executed'), 'yes'); exports.checks = [];" > "$tmp/theme/checks.cjs"
run "$tmp/theme" > /dev/null 2>"$tmp/denied.log"
test ! -e "$tmp/theme/executed"
rg -q 'Custom Theme Checks are disabled' "$tmp/denied.log"
run --allow-custom-checks "$tmp/theme" > /dev/null
test -f "$tmp/theme/executed"
