# Quickstart: Minimal Scratch Runtime Build and Multi-Arch Verification

## Prerequisites

- Docker with Buildx support
- Access to a registry that can publish multi-platform images
- GitHub Actions cache or equivalent remote cache support for repeated builds

## Build and Verify Locally

```sh
docker build -t ruby2.6-jemalloc:local .
./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:local
```

Equivalent make target:

```sh
make verify
```

## Multi-Platform Release Workflow

```sh
make build-release
make verify-release
```

## Multi-Platform Verification

```sh
make build-amd64
make verify-amd64
make build-arm64
make verify-arm64
```

## GitHub Actions Verification Path

Release workflow expectations:

- Build and push one multi-platform tag (`linux/amd64`, `linux/arm64`) via Buildx.
- Import/export Buildx cache via GitHub Actions backend with `mode=max`.
- Run runtime verification job for each platform variant.

## Expected Outcomes

- One published tag resolves to both amd64 and arm64 variants.
- Final runtime image remains minimal (`scratch`) while still executing Ruby successfully.
- Warm builds reuse cached work when inputs are unchanged.
- Runtime verification passes for both platforms.

## Cache Notes

- Local release builds store cache in `.buildx-cache`.
- CI release builds export cache to GitHub Actions cache for reuse across runs.
- Pull request verification builds import the shared cache and rebuild only platform-specific work.

## Evidence To Capture

Record results in the following verification artifacts:

- [verification/release-manifest.md](./verification/release-manifest.md) — single-tag publication evidence for both platform variants
- [verification/cache-reuse.md](./verification/cache-reuse.md) — cold-build and warm-build cache reuse evidence
- [verification/runtime-consistency.md](./verification/runtime-consistency.md) — runtime verification results for amd64 and arm64
