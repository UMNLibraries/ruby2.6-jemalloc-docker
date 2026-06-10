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

ruby_version="$(docker run "${run_args[@]}" "$image" ruby -v)"
echo "$ruby_version" | grep -E "ruby 2\.6\."

docker run "${run_args[@]}" "$image" ruby -e '
  maps = File.read("/proc/self/maps")
  unless maps.downcase.include?("jemalloc")
    warn "jemalloc not found in process memory map"
    exit 1
  end
  puts "jemalloc runtime mapping detected"
'

echo "[verify] ruby and jemalloc checks passed"
