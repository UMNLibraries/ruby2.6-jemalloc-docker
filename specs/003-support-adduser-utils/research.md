# Research Notes: Debian Slim Runtime with Downstream User-Management Support

## Topic: Final Runtime Base Selection

- Decision: Use `debian:bookworm-slim` as the final runtime stage.
- Rationale: Downstream images need built-in OS user-management behavior (`adduser` and related defaults) that scratch images do not provide.
- Alternatives considered:
  - `scratch` runtime: rejected because downstream utility workflows are blocked.
  - distroless runtime: rejected because user-management tooling is not reliably present for downstream Dockerfile use.

## Topic: Small-but-Practical Image Strategy

- Decision: Keep multistage build, copy only required Ruby/OpenSSL artifacts to runtime, and install only practical runtime packages.
- Rationale: Balances image size goals with downstream operability.
- Alternatives considered:
  - Full distro runtime with broad package set: rejected due to unnecessary footprint.
  - Strict minimal runtime policy: rejected by feature requirements.

## Topic: Temporary File Hygiene

- Decision: Remove package caches and temporary build artifacts at each stage where files are created.
- Rationale: Required by clarified requirements and constitution security/hygiene constraints.
- Alternatives considered:
  - Relying on layer squashing only: rejected because cache/temp files remain in intermediate layers and reduce reproducibility.

## Topic: Multi-Architecture CI and Verification

- Decision: Continue GitHub Actions Buildx for `linux/amd64` and `linux/arm64`; verify using `docker build` and runtime checks.
- Rationale: Matches repository baseline and constitution validation gates.
- Alternatives considered:
  - Single-arch verification: rejected because release targets both architectures.
