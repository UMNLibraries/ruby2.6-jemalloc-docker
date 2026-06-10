# Contract: Minimal Runtime Multi-Platform Build and Verification

## Purpose

Define required behavior for a minimal scratch-based runtime image that is built and published for multiple architectures with cache reuse and runtime verification.

## Supported Interfaces

### 1. Release publication contract

#### Release Publication Expected Behavior

- A release build publishes one image tag for both linux/amd64 and linux/arm64.
- The published tag resolves to the correct runnable variant for each platform.
- The release is not considered valid unless both variants are present.

### 2. Dockerfile structure contract

#### Dockerfile Structure Expected Behavior

- Build steps are organized in here-doc `RUN` blocks with explicit step grouping.
- Final runtime stage is `scratch` and contains only curated runtime artifacts.
- Runtime artifact assembly includes Ruby binaries, required OpenSSL files, CA certs, and required shared libraries.

### 3. Cache reuse contract

#### Cache Reuse Expected Behavior

- Repeated builds should reuse unchanged work through Buildx/GHA cache import/export.
- Unchanged steps should not be rebuilt when the relevant inputs are identical.
- Build evidence should show cache reuse behavior for warm builds.

### 4. Runtime verification contract

#### Expected behavior

- Runtime verification must pass for both platform variants before release eligibility.
- Runtime verification must include Ruby 2.6.x version confirmation and jemalloc runtime mapping confirmation.
- A failure on either platform blocks release publication.

## Invariants

- Ruby 2.6 runtime compatibility remains unchanged.
- Pinned source versions and deterministic build inputs remain documented.
- Verification remains executable using `docker build` plus runtime container checks.
- Documentation changes in README and quickstart must accompany workflow changes.

## Failure Conditions

- Missing platform variant, failed runtime verification, or cache configuration regression causes the release contract to fail.
