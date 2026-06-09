# Quickstart: Multi-Platform Release Build with Efficient Caching

## Prerequisites

- Docker with Buildx support
- Access to a registry that can publish multi-platform images
- GitHub Actions cache or equivalent remote cache support for repeated builds

## Build and Verify Locally

```sh
make build
make verify
```

## Multi-Platform Verification

```sh
make build-amd64
make verify-amd64
make build-arm64
make verify-arm64
```

## Expected Outcomes

- One published tag resolves to both amd64 and arm64 variants.
- Warm builds reuse cached work when inputs are unchanged.
- Runtime verification passes for both platforms.

## Evidence To Capture

- Build logs showing cache reuse on repeated runs
- Release workflow logs showing one tag published for both variants
- Runtime verification output for amd64 and arm64
