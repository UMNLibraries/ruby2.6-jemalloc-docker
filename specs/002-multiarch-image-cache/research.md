# Research Notes: Single Multi-Platform Image Build with Efficient Caching

## Topic: Single Published Image Tag

### Single Tag Decision

Publish one release tag that resolves to both linux/amd64 and linux/arm64 variants through a multi-platform manifest.

### Single Tag Rationale

- Users should not need to choose architecture-specific tags.
- A single tag keeps release documentation and usage simpler.
- The workflow already supports GitHub Container Registry publishing, which is compatible with manifest-based multi-platform images.

### Single Tag Alternatives Considered

- Separate architecture-specific tags.
  - Rejected because it increases user confusion and creates unnecessary release surface area.

## Topic: Cache Reuse Strategy

### Cache Strategy Decision

Use Buildx cache import/export with shared remote cache storage so unchanged layers can be reused across repeated builds.

### Cache Strategy Rationale

- Remote cache reuse reduces duplicate work between cold and warm builds.
- GitHub Actions cache support is already present in the repository workflow style.
- Cache reuse must not change build outputs; it only changes how existing work is retrieved.

### Cache Strategy Alternatives Considered

- Build each platform fully from scratch on every run.
  - Rejected because it wastes CI time and increases release latency.
- Rely only on local builder cache.
  - Rejected because CI runners are ephemeral and need remote cache persistence.

## Topic: Runtime Verification Preservation

### Verification Decision

Keep runtime verification as a release gate for both amd64 and arm64 outputs after the multi-platform image is published.

### Verification Rationale

- Multi-platform publishing is only acceptable if the resulting image still satisfies Ruby and jemalloc expectations.
- Verification needs to be repeatable for both target platforms.

### Verification Alternatives Considered

- Verify only one platform and assume the other matches.
  - Rejected because platform-specific builds can diverge.
