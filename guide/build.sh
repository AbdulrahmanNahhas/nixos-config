#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
if command -v hugo >/dev/null 2>&1; then
  runner=(hugo)
else
  runner=(nix shell --inputs-from .. nixpkgs#hugo -c hugo)
fi
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != serve ) ]]; then
  printf 'Usage: %s [serve]\n' "$0" >&2
  exit 2
fi
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/shadow-guide.XXXXXX")
trap 'rm -rf -- "$build_dir"' EXIT
if [[ "${1:-}" == serve ]]; then
  "${runner[@]}" server --bind 127.0.0.1 --disableFastRender --destination "$build_dir" --noBuildLock
  exit
fi
"${runner[@]}" --destination "$build_dir" --cacheDir "${TMPDIR:-/tmp}/shadow-hugo-cache" --noBuildLock --panicOnWarning
if command -v node >/dev/null 2>&1; then
  node check.mjs "$build_dir"
fi
for page in "$build_dir"/*.html; do
  sed 's/[[:blank:]]*$//' "$page" > "./$(basename -- "$page")"
done
printf 'Built %s/index.html\n' "$PWD"
