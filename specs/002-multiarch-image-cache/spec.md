# Feature Specification: Single Multi-Platform Image Build with Efficient Caching

**Feature Branch**: `[002-multiarch-image-cache]`

**Created**: 2026-06-09

**Status**: Draft

**Input**: User description: "the build process should create a single docker image suitable for running on linux/amd64 and linux/arm64 platforms. The build process should be as efficient as possible, using caching to avoid duplication of effort."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Publish One Multi-Platform Image (Priority: P1)

As a maintainer, I want each release build to publish one image tag that works on both linux/amd64 and linux/arm64 so users can pull a single tag regardless of architecture.

**Why this priority**: A single tag across platforms is the primary user-facing outcome and removes manual tag selection.

**Independent Test**: Run one release build, then pull the same tag on amd64 and arm64 environments and confirm each environment receives a runnable variant.

**Acceptance Scenarios**:

1. **Given** a release build is triggered, **When** it completes successfully, **Then** one image tag is available with both amd64 and arm64 variants.
2. **Given** a user pulls the release tag from an amd64 host, **When** the image is resolved, **Then** the host receives a working amd64 variant.
3. **Given** a user pulls the same release tag from an arm64 host, **When** the image is resolved, **Then** the host receives a working arm64 variant.

---

### User Story 2 - Reduce Rebuild Time Through Cache Reuse (Priority: P2)

As a release engineer, I want repeated builds to reuse prior build work so unchanged layers are not rebuilt and delivery time is reduced.

**Why this priority**: Faster builds reduce infrastructure cost and improve release turnaround.

**Independent Test**: Execute a cold build and then a warm build with no relevant source changes; verify the second run completes significantly faster and reports cache reuse.

**Acceptance Scenarios**:

1. **Given** a prior successful build exists, **When** the same commit is rebuilt, **Then** unchanged build steps are restored from cache instead of rebuilt.
2. **Given** only one component changes, **When** a build runs, **Then** cache is reused for unaffected components and only impacted steps are rebuilt.

---

### User Story 3 - Preserve Runtime Verification Across Platforms (Priority: P3)

As a maintainer, I want runtime checks to pass for both amd64 and arm64 outputs so performance optimizations do not compromise runtime expectations.

**Why this priority**: Caching and multi-platform publishing must not break Ruby or allocator behavior.

**Independent Test**: After publishing the multi-platform image, run runtime verification checks for both architectures and confirm all checks pass.

**Acceptance Scenarios**:

1. **Given** a multi-platform build is completed, **When** runtime verification is executed on amd64 and arm64 variants, **Then** required runtime checks pass on both.
2. **Given** one platform verification fails, **When** release eligibility is evaluated, **Then** the build is treated as failed and not considered release-ready.

### Edge Cases

- One platform build fails while the other succeeds; ensure no incomplete release is published.
- Cache entries are unavailable or expired; ensure the build still succeeds through full rebuild behavior.
- Dependency version updates invalidate cache; ensure rebuild scope is limited to impacted layers.
- Manifest publication succeeds but one platform image is missing; ensure validation detects and fails this state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST produce a single release image tag that contains both linux/amd64 and linux/arm64 variants.
- **FR-002**: The system MUST allow consumers on both target platforms to pull the same image tag and receive the correct runnable variant.
- **FR-003**: The system MUST reuse cached build work across repeated runs when relevant inputs have not changed.
- **FR-004**: The system MUST minimize duplicated work by rebuilding only cache-invalidated steps.
- **FR-005**: The system MUST fail release publication if any required platform variant fails build or verification.
- **FR-006**: The system MUST provide build evidence showing cache usage behavior and platform-specific build outcomes.
- **FR-007**: The system MUST preserve required runtime verification outcomes for both target platforms after optimization changes.
- **FR-008**: The system MUST document the single-tag multi-platform workflow and cache behavior for maintainers.

### Container & Runtime Constraints *(mandatory)*

- Feature work MUST preserve Ruby 2.6 runtime compatibility unless an explicit migration decision is approved.
- Feature work affecting memory allocator behavior MUST define how jemalloc usage is verified.
- Feature work MUST define deterministic build input expectations (base image, package sources, and build args).
- Feature work MUST identify documentation updates required in README or operational guidance.

### Key Entities *(include if feature involves data)*

- **Multi-Platform Image Tag**: A single published image identifier that references both amd64 and arm64 runnable variants.
- **Platform Build Result**: Per-platform outcome record including build status, verification status, and elapsed time.
- **Build Cache Record**: Evidence describing cache hit/miss behavior and which build steps were reused versus rebuilt.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of successful release builds publish one image tag containing both linux/amd64 and linux/arm64 variants.
- **SC-002**: In repeated builds with unchanged inputs, median warm-build duration is at least 30% faster than median cold-build duration.
- **SC-003**: At least 80% of unchanged build steps are restored from cache during warm builds.
- **SC-004**: Required runtime verification checks pass for both platform variants in 100% of release-eligible builds.

## Assumptions

- The target registry supports publishing and resolving one image tag across multiple platforms.
- Build infrastructure supports persistent cache storage between runs.
- Existing runtime verification checks remain the acceptance baseline for Ruby and allocator behavior.
- Platform support scope for this feature is limited to linux/amd64 and linux/arm64.
