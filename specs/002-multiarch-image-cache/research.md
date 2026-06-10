# Research Notes: Minimal Scratch Runtime with Multi-Arch CI Cache

## Topic: Minimal Final Runtime Image

- Decision: Use a `scratch` final stage with a curated runtime filesystem copied from the builder stage.
- Rationale: This yields the smallest practical runtime footprint while preserving Ruby 2.6 + jemalloc requirements and avoids package-manager drift in final image.
- Alternatives considered: Keep `debian:latest` runtime stage with apt-installed dependencies; rejected due to larger image size and additional mutable runtime surface.

## Topic: Dockerfile RUN Structure

- Decision: Keep build workflow in here-doc `RUN` blocks grouped by concern (build deps, OpenSSL build, jemalloc build, Ruby build, runtime filesystem assembly).
- Rationale: The structure is explicit, reviewable, and aligned with project guidance for maintainability.
- Alternatives considered: Flatten commands into long line-continuation chains; rejected due to lower readability and higher maintenance risk.

## Topic: Multi-Architecture Publication

- Decision: Publish one manifest-backed tag resolving to both `linux/amd64` and `linux/arm64` variants.
- Rationale: Consumers use a single tag while registries resolve architecture-specific variants automatically.
- Alternatives considered: Publish separate arch tags only; rejected due to poorer UX and release-management overhead.

## Topic: CI Cache Reuse

- Decision: Use Buildx cache import/export with GitHub Actions backend (`type=gha`) and `mode=max`.
- Rationale: Cache persistence across workflow runs reduces duplicate build work for unchanged layers.
- Alternatives considered: Cold builds on every run or local-only cache; rejected because hosted runners are ephemeral and local cache is not shared.

## Topic: Runtime Verification in Scratch Images

- Decision: Verify runtime with `docker run` invoking Ruby directly, validating Ruby 2.6 version output and jemalloc mapping from `/proc/self/maps`.
- Rationale: Scratch images may not provide shell or `ldconfig`; verification must rely on tools guaranteed by shipped runtime.
- Alternatives considered: Shell-based checks (`sh`, `ldd`, `ldconfig`) inside final image; rejected because they are brittle or unavailable in minimal scratch runtime.
