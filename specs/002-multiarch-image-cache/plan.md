# Implementation Plan: Minimal Scratch Ruby 2.6 Image with Multi-Arch CI Verification

**Branch**: `[main]` | **Date**: 2026-06-10 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-multiarch-image-cache/spec.md`

## Summary

Deliver a minimal `scratch`-based Ruby 2.6 runtime image with jemalloc enabled, preserve multi-architecture publication for `linux/amd64` and `linux/arm64`, and standardize Dockerfile build steps around here-doc `RUN` blocks while keeping verification anchored on `docker build` plus runtime checks.

## Technical Context

**Language/Version**: Dockerfile syntax v1 with here-doc `RUN` blocks, Bash shell scripts, GitHub Actions workflow YAML

**Primary Dependencies**: Docker Buildx, GitHub Actions cache (`type=gha`, `mode=max`), docker/build-push-action, docker/metadata-action, Docker registry publishing

**Storage**: Container image layers, manifest lists, and remote Buildx cache entries in GitHub Actions cache

**Testing**: `docker build`, `docker buildx build`, `make verify`, `make verify-amd64`, `make verify-arm64`, release workflow verification jobs on GitHub Actions

**Target Platform**: Linux container images for `linux/amd64` and `linux/arm64`

**Project Type**: Container build and release workflow repository

**Performance Goals**: Minimize runtime image footprint, preserve high cache hit rates across repeated CI builds, and keep two-platform verification pass rate at release time

**Constraints**: Preserve Ruby 2.6 runtime compatibility, keep jemalloc verification intact in a shell-less scratch runtime, maintain deterministic build inputs, ensure one published tag resolves to both platforms, and keep docs aligned with release behavior

**Scale/Scope**: Single repository; primary changes in `Dockerfile`, `.github/workflows/build.yml`, `scripts/verify-ruby-jemalloc.sh`, `Makefile`, `README.md`, and planning artifacts under `specs/002-multiarch-image-cache/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Ruby runtime alignment: Plan preserves Ruby 2.6 runtime compatibility and does not alter the dependency line.
- jemalloc verification: Plan verifies allocator activation from inside Ruby runtime execution rather than relying on package-manager tooling in final image.
- Build determinism: Plan keeps pinned dependency versions, explicit source URLs, and controlled build args while adding cache reuse.
- Required validation: Plan includes `docker build`/`buildx` plus runtime verification for both architectures.
- Documentation impact: Plan updates README and workflow guidance for minimal image behavior and verification approach.

## Phase 0 Research

Research findings are captured in [research.md](./research.md).

- Final runtime should use `scratch` with a curated filesystem assembled in builder stage.
- Dockerfile build flow should remain explicit and maintainable using here-doc `RUN` blocks per major build step.
- Multi-platform publication should continue as one manifest-backed tag for `linux/amd64` and `linux/arm64`.
- CI should continue Buildx GHA cache import/export to reduce repeat build duration.
- Runtime verification should prove Ruby 2.6 and active jemalloc without requiring a shell in final image.

No `NEEDS CLARIFICATION` items remain after research.

## Phase 1 Design

- Data model: [data-model.md](./data-model.md)
- Interface contract: [contracts/build-release-contract.md](./contracts/build-release-contract.md)
- Quickstart: [quickstart.md](./quickstart.md)

## Project Structure

### Documentation (this feature)

```text
specs/002-multiarch-image-cache/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── build-release-contract.md
├── spec.md
└── tasks.md
```

### Source Code (repository root)

```text
Dockerfile
README.md
.github/workflows/build.yml
Makefile
scripts/verify-ruby-jemalloc.sh
```

**Structure Decision**: Single repository with container build/release focus. The workflow is centered on `.github/workflows/build.yml` for release publication and cache reuse, `Makefile` for contributor entry points, `scripts/verify-ruby-jemalloc.sh` for runtime validation, and `README.md` plus the feature docs for behavior and operational guidance.

## Post-Design Constitution Check

- Ruby runtime alignment: PASS - design keeps Ruby 2.6 runtime compatibility unchanged.
- jemalloc verification: PASS - runtime checks are preserved through Ruby-executed process-map inspection.
- Build determinism: PASS - pinned versions and explicit inputs remain in place; runtime assembly is deterministic.
- Required validation: PASS - quickstart and contract docs define build plus runtime checks for amd64 and arm64.
- Documentation impact: PASS - minimal runtime and verification changes are reflected in project guidance.

## Complexity Tracking

No constitution violations expected for this feature.
