#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <image> [platform]" >&2
  exit 1
fi

image="$1"
platform="${2:-}"

run_args=(--rm)

echo "[verify] image=${image} platform=${platform:-native}"

# Determine whether the image reference points to a remote registry or is a
# local-only tag (produced by `docker build --load` / `buildx --load`).
# A remote reference contains a registry host (contains a '.' or ':' before
# the first '/') or an explicit digest.  Local tags look like "name:tag" with
# no host component.
is_remote=false
if [[ "$image" == *"@sha256:"* ]]; then
  is_remote=true
elif [[ "$image" =~ ^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+/ || "$image" =~ ^[^/]+:[0-9]+/ ]]; then
  is_remote=true
fi

# When a platform is requested and the image is remote, resolve the
# platform-specific child digest from the manifest list so docker pull/run do
# not receive a manifest-list digest combined with --platform (which causes
# "cannot overwrite digest" errors).
if [[ -n "$platform" && "$is_remote" == "true" ]]; then
  child_digest="$(
    docker buildx imagetools inspect --format \
      '{{range .Manifest.Manifests}}{{if eq (printf "%s/%s" .Platform.OS .Platform.Architecture) "'"${platform}"'"}}{{.Digest}}{{end}}{{end}}' \
      "${image}"
  )"
  # Strip the repo/tag portion, keep only registry/repo prefix.
  image_ref="${image%%@*}"
  image="${image_ref}@${child_digest}"
  echo "[verify] resolved platform digest: ${image}"
fi

run_args+=(--platform "${platform:-linux/$(uname -m | sed s/x86_64/amd64/)}")

# Pre-pull remote images; local images are already available in the daemon.
if [[ "$is_remote" == "true" ]]; then
  docker pull "${image}" >/dev/null
fi

ruby_version="$(docker run --pull=never "${run_args[@]}" "$image" ruby -v)"
echo "$ruby_version" | grep -E "ruby 2\.6\."

docker run --pull=never "${run_args[@]}" "$image" ruby -e '
  maps = File.read("/proc/self/maps")
  unless maps.downcase.include?("jemalloc")
    warn "jemalloc not found in process memory map"
    exit 1
  end
  puts "jemalloc runtime mapping detected"
'

echo "[verify] ruby and jemalloc checks passed"
