# Research Notes: Here-Doc Refactor Rules

## Topic: Multi-Step Dockerfile Build Blocks

### Build Blocks Decision

Use shell here-doc `RUN` blocks for multi-step Dockerfile sequences across the OpenSSL,
jemalloc, Ruby, and runtime setup stages.

### Build Blocks Rationale

- The Dockerfile contains several sequential source-build flows that are easier to review as
  script-style blocks than as escaped `&&` chains.
- Here-doc blocks let maintainers change one step, flag, or cleanup action without rewriting
  unrelated continuations.
- Inline step comments map build log output to a specific logical operation, which speeds up CI
  and local debugging.
- Starting each block with `set -eux` preserves immediate failure behavior and command tracing.

### Build Blocks Alternatives Considered

- Continue with long `&&` chains.
  - Rejected because review, editing, and failure localization are harder, especially in the
    multi-architecture CI matrix.
- Move build logic into separate shell scripts copied into the image.
  - Rejected because it introduces extra indirection for a repository whose primary source of
    truth is the Dockerfile itself.

## Topic: Deterministic Build Inputs

### Deterministic Inputs Decision

Keep version pins, source download endpoints, build order, and cleanup behavior unchanged while
converting the Dockerfile structure.

### Deterministic Inputs Rationale

- Ruby 2.6.10, OpenSSL 1.1.1w, and jemalloc 5.3.0 are already pinned in the Dockerfile, workflow,
  and contributor guidance.
- Ruby compilation depends on the previously installed OpenSSL and jemalloc outputs, so execution
  order is a behavioral invariant rather than a formatting detail.
- Preserving `rm -rf /var/lib/apt/lists/*` and source tree cleanup in the same logical blocks
  keeps image hygiene and layer contents stable.
- Reusing canonical download sources avoids introducing new dependency resolution behavior during
  the refactor.

### Deterministic Inputs Alternatives Considered

- Float to newer or "latest" dependency versions during the refactor.
  - Rejected because it would mix a readability change with a runtime compatibility change.
- Reorder compilation stages for perceived readability.
  - Rejected because Ruby must build against the OpenSSL and jemalloc outputs already in place.

## Topic: Runtime Verification Contract

### Verification Contract Decision

Retain a three-part runtime verification contract for every built image: Ruby version check,
jemalloc linkage check, and linker-cache visibility check.

### Verification Contract Rationale

- `ruby -v` confirms the runtime remains in the Ruby 2.6 line.
- `ldd` against `libruby` proves jemalloc is actually linked into the built runtime.
- `ldconfig -p` confirms the final image has the required runtime linker visibility.
- The same verification script is used locally and in CI, which keeps behavior reproducible across
  contributors and the GitHub Actions matrix.

### Verification Contract Alternatives Considered

- Manual verification during review only.
  - Rejected because the constitution requires scriptable, repeatable evidence.
- Performance benchmarks as the primary jemalloc proof.
  - Rejected because they are noisy and unnecessary for establishing allocator activation.

## Topic: Contributor and CI Workflow Impact

### Workflow Impact Decision

Keep contributor entry points centered on `make build`, `make verify`, `make verify-amd64`,
`make verify-arm64`, and the existing GitHub Actions build matrix.

### Workflow Impact Rationale

- Maintainers already have documented build and verification commands, so the refactor should not
  require a new workflow to gain confidence.
- The workflow already uses Buildx and GHA cache storage, which provides a stable foundation for
  validating the here-doc refactor on both target platforms.
- Preserving these interfaces focuses the feature on readability and troubleshooting rather than
  operational retraining.

### Workflow Impact Alternatives Considered

- Introduce new wrapper tooling for build verification.
  - Rejected because current Make targets and the verification script already provide a stable
    public interface for both local and CI execution.
