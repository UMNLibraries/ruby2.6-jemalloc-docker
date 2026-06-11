# Contract: Runtime Build and Verification Behavior

## Purpose

Define required externally observable behavior for image build, downstream utility support, and runtime verification.

## Interfaces

### 1. Image build interface

Expected behavior:
- Local build command (`docker build` or equivalent make target) succeeds.
- CI build publishes multi-architecture image variants (`linux/amd64`, `linux/arm64`).

### 2. Downstream user-management interface

Expected behavior:
- Final runtime base remains `debian:bookworm-slim`, preserving practical downstream extension workflows.
- Feature validation does not require dedicated command-presence checks for specific user-management binaries.

### 3. Runtime verification interface

Expected behavior:
- Runtime checks verify Ruby reports `2.6.x`.
- Runtime checks verify jemalloc is active.
- Verification runs for both target architectures.

## Invariants

- Final runtime base remains `debian:bookworm-slim` for this feature.
- Temporary package/build files are removed from final image layers where practical.
- README/operational docs are updated when behavior changes.

## Failure Conditions

- Ruby or jemalloc verification fails on either architecture.
- Hygiene check indicates temporary file cleanup regressions.
