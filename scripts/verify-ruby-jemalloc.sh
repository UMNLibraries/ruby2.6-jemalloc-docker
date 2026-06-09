#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <image> [platform]" >&2
  exit 1
fi

image="$1"
platform="${2:-}"

run_args=(--rm)
if [[ -n "$platform" ]]; then
  run_args+=(--platform "$platform")
fi

echo "[verify] image=${image} platform=${platform:-native}"

docker run "${run_args[@]}" "$image" sh -euxc '
  ruby -v | grep -E "ruby 2\.6\."

  libruby=$(ruby -rrbconfig -e "print File.join(RbConfig::CONFIG[\"libdir\"], RbConfig::CONFIG[\"LIBRUBY_SO\"])")
  ldd "$libruby" | grep -qi jemalloc

  ldconfig -p | grep -qi jemalloc
'

echo "[verify] ruby and jemalloc checks passed"
