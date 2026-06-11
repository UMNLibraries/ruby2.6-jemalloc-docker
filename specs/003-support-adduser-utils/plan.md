# Implementation Plan: Debian Slim Runtime with Downstream User-Management Support

**Branch**: `[003-support-adduser-utils]` | **Date**: 2026-06-11 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-support-adduser-utils/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Switch the final runtime from strict minimal runtime assumptions to a small-but-practical `debian:bookworm-slim` image while preserving Ruby 2.6 + jemalloc guarantees, ensuring downstream `adduser` workflows function, and enforcing temporary-file cleanup and multi-architecture verification.

## Technical Context

**Language/Version**: Dockerfile syntax v1, Bash shell scripts, GitHub Actions workflow YAML

**Primary Dependencies**: Docker Buildx, Debian bookworm-slim runtime packages, GitHub Actions cache backend (`type=gha`, `mode=max`)

**Storage**: Container image layers and registry manifests (GHCR)

**Testing**: `docker build`, `docker buildx build`, `./scripts/verify-ruby-jemalloc.sh`, downstream derived-image build check using `adduser`

**Target Platform**: Linux container images for `linux/amd64` and `linux/arm64`

**Project Type**: Container build and release workflow repository

**Performance Goals**: Keep runtime image small for practical downstream use
while preserving downstream operability

**Constraints**: Ruby 2.6 compatibility must remain, jemalloc verification must pass, final runtime base constrained to `debian:bookworm-slim`, temporary build/package files must be removed

**Scale/Scope**: Changes centered on `Dockerfile`, verification script/workflow behavior, and docs in this single repository

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Ruby runtime alignment: Plan preserves Ruby 2.6 target and explains any version/build flag
  changes.
- jemalloc verification: Plan defines how runtime allocator activation will be verified in the
  built container.
- Build determinism: Plan identifies key build inputs (base image, package sources, build args)
  and how drift is controlled.
- Required validation: Plan includes build + runtime verification commands for CI/local checks.
- Documentation impact: Plan lists README/ops documentation updates required by behavior changes.

## Phase 0 Research

Research findings are captured in [research.md](./research.md).

- Final runtime base is `debian:bookworm-slim` for downstream user-management compatibility.
- Build remains multi-stage and small-by-default while preserving practical runtime utilities.
- Temporary files and package caches must be cleaned during image assembly.
- Verification remains build plus runtime checks across amd64 and arm64.

No `NEEDS CLARIFICATION` items remain after clarifications.

## Phase 1 Design

- Data model: [data-model.md](./data-model.md)
- Interface contract: [contracts/runtime-build-verification-contract.md](./contracts/runtime-build-verification-contract.md)
- Quickstart: [quickstart.md](./quickstart.md)

## Project Structure

### Documentation (this feature)

```text
specs/003-support-adduser-utils/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── runtime-build-verification-contract.md
├── checklists/
│   └── requirements.md
└── spec.md
```

### Source Code (repository root)

```text
Dockerfile
README.md
scripts/verify-ruby-jemalloc.sh
.github/workflows/build.yml
Makefile
```

**Structure Decision**: Single repository with Docker build/release focus. Feature changes primarily affect `Dockerfile` final runtime stage behavior, runtime verification script behavior for both architectures, and workflow/docs alignment.

## Post-Design Constitution Check

- Ruby runtime alignment: PASS - plan preserves Ruby 2.6 runtime target and verification.
- jemalloc verification: PASS - plan requires runtime allocator checks after image changes.
- Build determinism: PASS - plan keeps explicit build inputs and base-image decision documented.
- Required validation: PASS - plan includes local/CI build and runtime verification for amd64 and arm64.
- Documentation impact: PASS - README updates are included as explicit deliverables.

## Complexity Tracking

No constitution violations expected for this feature.
