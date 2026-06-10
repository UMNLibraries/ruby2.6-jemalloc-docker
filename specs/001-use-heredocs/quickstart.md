# Quickstart: Here-Doc Dockerfile Verification

## Prerequisites

- Docker with Buildx support
- Optional: QEMU emulation for cross-architecture runtime checks

## Reference Artifacts

- Research decisions: `./research.md`
- Data model: `./data-model.md`
- Interface contract: `./contracts/build-verification-contract.md`

## Local Build and Verification

```sh
make build
make verify
```

## Architecture-Specific Verification

```sh
make verify-amd64
make verify-arm64
```

## Deterministic Input Checklist

- Build args remain pinned to:
  - `RUBY_VERSION=2.6.10`
  - `OPENSSL_VERSION=1.1.1w`
  - `JEMALLOC_VERSION=5.3.0`
- Source download locations are unchanged.
- Build step order is unchanged after here-doc conversion.
- Package manager cache cleanup (`rm -rf /var/lib/apt/lists/*`) remains in place.

## CI Triage Commands

```sh
# Rebuild exactly as CI does for amd64
docker buildx build --platform linux/amd64 --load -t ruby2.6-jemalloc:ci-amd64 .
./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:ci-amd64 linux/amd64

# Rebuild exactly as CI does for arm64
docker buildx build --platform linux/arm64 --load -t ruby2.6-jemalloc:ci-arm64 .
./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:ci-arm64 linux/arm64
```

## Expected Verification Outcomes

- `ruby -v` reports a `2.6.x` Ruby version
- `ldd` on `libruby` shows jemalloc linkage
- `ldconfig -p` lists jemalloc in the runtime image

## Contract Notes

- Contributor-facing build and verification interfaces are defined in
  `./contracts/build-verification-contract.md`.
- Any change to Dockerfile build args, verification semantics, or Make targets must update the
  contract, README guidance, and verification evidence together.

## Verification Artifacts

- [runtime consistency](./verification/runtime-consistency.md)
- [US1 build verification](./verification/us1-build.md)
- [polish checks](./verification/polish-checks.md)
