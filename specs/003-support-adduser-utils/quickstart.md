# Quickstart: Debian Slim Runtime with User-Management Support

## Prerequisites

- Docker with Buildx support
- Access to build and run containers locally

## Local Build and Runtime Verification

```sh
docker build -t ruby2.6-jemalloc:local .
./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:local
```

## Downstream Extension Note

The final runtime base is `debian:bookworm-slim`, which preserves practical downstream extension workflows. This feature does not require dedicated command-presence verification for user-management utilities.

## Multi-Architecture CI Verification

- Build and publish with GitHub Actions Buildx for `linux/amd64` and `linux/arm64`.
- Run runtime verification job on both architectures.
- Confirm final image hygiene checks for temporary file cleanup pass.
