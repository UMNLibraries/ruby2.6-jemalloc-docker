# Feature Specification: Small Runtime Image with User-Management Utilities

**Feature Branch**: `[003-support-adduser-utils]`

**Created**: 2026-06-11

**Status**: Draft

**Input**: User description:

> The final image must be small, but it must allow downstream consumers of the image
> to install applications, users, and make other changes when they use the image.

## Clarifications

### Session 2026-06-11

- Q: Which final-runtime strategy should be used for downstream user-management compatibility? → A: Use `debian:bookworm-slim` as the final image and remove temporary build files.
- Q: Should the spec define and manage an explicit user-management utility command set? → A: No; use `debian:bookworm-slim` defaults and do not curate an additional command matrix.

## User Scenarios & Testing *(mandatory)*


### User Story 1 - Create Runtime Users in Derived Images (Priority: P1)

As a downstream image maintainer, I want to run user-management commands in a derived image so I can create application users and groups during my own image build.

**Why this priority**: Downstream user creation is the primary blocker called out by the request; without it, the base image is not usable for intended consumers.

**Independent Test**: Build the base image with the configured `debian:bookworm-slim` runtime and confirm it is release-ready for downstream image extension workflows.

**Acceptance Scenarios**:

1. **Given** this feature branch changes the final runtime stage, **When** the image is built, **Then** the final stage uses `debian:bookworm-slim` and remains compatible with downstream extension workflows.
2. **Given** runtime packaging decisions are updated, **When** release artifacts are reviewed, **Then** documentation explains downstream user-management expectations and constraints.

---

### User Story 2 - Keep Runtime Image Small but Practical (Priority: P2)

As a platform owner, I want the image to remain small while still including operationally necessary runtime utilities so that pull times and storage stay efficient without breaking downstream workflows.

**Why this priority**: The image-size objective remains important, but it must now be balanced with practical downstream utility support.

**Independent Test**: Compare image size before and after adding required utilities and verify the resulting image remains within an agreed small-image threshold.

**Acceptance Scenarios**:

1. **Given** the updated runtime image, **When** its size is measured against the prior release, **Then** the increase is bounded and documented.
2. **Given** the updated runtime image, **When** runtime utilities are exercised, **Then** required utility behavior works without adding unnecessary toolchains.

---

### User Story 3 - Preserve Ruby and jemalloc Runtime Guarantees (Priority: P3)

As a maintainer, I want existing runtime guarantees to remain intact after utility additions so that compatibility and allocator behavior do not regress.

**Why this priority**: The constitution requires Ruby 2.6 and jemalloc verification on every relevant image change.

**Independent Test**: Build the image and run existing runtime verification checks to confirm Ruby 2.6 and active jemalloc behavior remain unchanged.

**Acceptance Scenarios**:

1. **Given** the updated image, **When** runtime verification is executed, **Then** Ruby reports a 2.6.x version.
2. **Given** the updated image, **When** runtime verification is executed, **Then** jemalloc activation checks pass.

---

### Edge Cases


- Downstream build uses `adduser` with non-default options (UID/GID/home path); commands should still behave as expected.
- Derived image runs in non-interactive mode; user-management commands must not hang on prompts.
- Utility package installation introduces unexpected runtime dependency growth; build should fail policy checks if footprint exceeds defined bound.
- A package refresh changes behavior of user-management commands; CI verification should detect regressions before release.
- Temporary files from package operations remain in image layers; release validation should fail if cleanup expectations are not met.

## Requirements *(mandatory)*


### Functional Requirements

- **FR-001**: The runtime image MUST support downstream user-management workflows using `adduser` and related commands available by default in `debian:bookworm-slim`.
- **FR-002**: The runtime image MUST support non-interactive downstream execution of user-management commands in Docker build steps.
- **FR-003**: The image build workflow MUST keep the final image small while allowing required utilities.
- **FR-004**: The image MUST preserve Ruby 2.6 runtime compatibility after utility support is added.
- **FR-005**: The image MUST preserve verified jemalloc activation behavior after utility support is added.
- **FR-006**: CI MUST include build and runtime verification checks that cover runtime compatibility expectations.
- **FR-007**: Documentation MUST explain supported downstream user-management workflows and any practical constraints.
- **FR-008**: The final runtime image MUST use `debian:bookworm-slim` as its base.
- **FR-009**: The build process MUST remove temporary files created during package or artifact preparation before producing the final image.

### Container & Runtime Constraints *(mandatory)*

- Feature work MUST preserve Ruby 2.6 runtime compatibility unless an explicit migration
  decision is approved.
- Final runtime image selection for this feature is constrained to `debian:bookworm-slim`.
- Feature work affecting memory allocator behavior MUST define how jemalloc usage is verified.
- Feature work MUST define deterministic build input expectations (base image, package sources,
  and build args).
- Feature work MUST identify documentation updates required in README or operational guidance.

### Key Entities *(include if feature involves data)*

- **Runtime Utility Baseline**: The user-management behavior available by default from `debian:bookworm-slim`, without an additional curated utility matrix.
- **Derived Image Build Step**: A downstream Dockerfile instruction that depends on runtime user-management utilities.
- **Verification Result**: Outcome records for build-time and runtime checks confirming compatibility and utility support.

## Success Criteria *(mandatory)*


### Measurable Outcomes

- **SC-001**: 100% of release builds produce an image with `debian:bookworm-slim` as the final runtime base.
- **SC-002**: The updated image remains small while preserving required downstream utility support.
- **SC-003**: 100% of release-eligible builds pass Ruby version verification (2.6.x) and jemalloc activation checks.
- **SC-004**: Documentation-based setup success rate for downstream user-creation workflows is at least 95% in maintainer validation runs.
- **SC-005**: 100% of release-eligible builds pass an image hygiene check confirming temporary package/build files are removed from the final image.

## Assumptions

- Downstream consumers perform user creation in derived image builds rather than mutating running containers.
- Existing Ruby 2.6 and jemalloc verification scripts remain the baseline acceptance mechanism and may be extended if needed.
- The repository will continue to target `linux/amd64` and `linux/arm64` outputs under existing CI workflows.
- "Small" means optimized for practical runtime use, not strict scratch-minimality.
