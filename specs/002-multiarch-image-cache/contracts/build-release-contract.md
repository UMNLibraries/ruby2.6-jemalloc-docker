# Contract: Multi-Platform Build and Cache Reuse

## Purpose

Define the release-build behavior that must remain stable when the workflow is updated for multi-platform publishing and cache reuse.

## Supported Interfaces

### 1. Release publication contract

#### Release Publication Expected Behavior

- A release build publishes one image tag for both linux/amd64 and linux/arm64.
- The published tag resolves to the correct runnable variant for each platform.
- The release is not considered valid unless both variants are present.

### 2. Cache reuse contract

#### Cache Reuse Expected Behavior

- Repeated builds should reuse unchanged work through Buildx/GHA cache import/export.
- Unchanged steps should not be rebuilt when the relevant inputs are identical.
- Build evidence should show cache reuse behavior for warm builds.

### 3. Runtime verification contract

#### Expected behavior

- Runtime verification must pass for both platform variants before release eligibility.
- Existing Ruby and jemalloc checks remain the acceptance baseline.
- A failure on either platform blocks release publication.

## Invariants

- Ruby 2.6 runtime compatibility remains unchanged.
- Pinned source versions and deterministic build inputs remain documented.
- Documentation changes in README and quickstart must accompany workflow changes.

## Failure Conditions

- Missing platform variant, failed runtime verification, or cache configuration regression causes the release contract to fail.
