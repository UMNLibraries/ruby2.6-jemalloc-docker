# Implementation Plan: Single Multi-Platform Image Build with Efficient Caching

**Branch**: `[002-multiarch-image-cache]` | **Date**: 2026-06-09 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-multiarch-image-cache/spec.md`

## Summary

Consolidate the release workflow into a single multi-platform image publication flow that produces one tag for both `linux/amd64` and `linux/arm64`, while maximizing cache reuse to avoid rebuilding unchanged layers and preserving runtime verification coverage.

## Technical Context

**Language/Version**: Dockerfile syntax v1, Bash shell scripts, GitHub Actions workflow YAML

**Primary Dependencies**: Docker Buildx, GitHub Actions cache, docker/build-push-action, docker/metadata-action, Docker registry publishing

**Storage**: Container image layers and remote build cache (GitHub Actions cache)

**Testing**: `docker buildx build`, `make verify`, `make verify-amd64`, `make verify-arm64`, release workflow runs on GitHub Actions

**Target Platform**: Linux container images for `linux/amd64` and `linux/arm64`

**Project Type**: Container build and release workflow repository

**Performance Goals**: Reduce repeated-build time by maximizing cache hits and avoiding duplicate work across platform builds; preserve release verification pass rate

**Constraints**: Preserve Ruby 2.6 runtime compatibility, keep jemalloc verification intact, maintain deterministic build inputs, ensure one published tag resolves to both platforms, and keep documentation aligned with workflow changes

**Scale/Scope**: Single repository; primary changes in `.github/workflows/build.yml`, `Makefile`, `README.md`, and supporting verification notes under `specs/002-multiarch-image-cache/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Ruby runtime alignment: Plan preserves Ruby 2.6 runtime compatibility and does not alter the dependency line.
- jemalloc verification: Plan keeps runtime checks for jemalloc activation in place for both target platforms.
- Build determinism: Plan keeps pinned dependency versions and controlled build inputs while adding cache reuse.
- Required validation: Plan includes build and runtime verification for both architectures plus cache-behavior evidence.
- Documentation impact: Plan updates README and workflow guidance for the single-tag multi-platform process.

## Phase 0 Research

Research findings are captured in [research.md](./research.md).

- One release tag should resolve to both architectures using a multi-platform manifest rather than separate user-facing tags.
- Build cache reuse should occur through Buildx/GHA cache so unchanged layers are restored instead of rebuilt.
- Runtime verification remains required for both architectures after publishing.

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
- jemalloc verification: PASS - runtime checks remain required for both platform variants.
- Build determinism: PASS - pinned versions and explicit inputs remain in place; caching is additive.
- Required validation: PASS - quickstart and contract docs define local and CI verification paths for amd64 and arm64.
- Documentation impact: PASS - release workflow and user guidance will be documented together.

## Complexity Tracking

No constitution violations expected for this feature.
