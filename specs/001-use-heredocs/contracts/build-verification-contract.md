# Contract: Build and Runtime Verification Interface

## Purpose

Define the contributor-facing and CI-facing commands that must continue to work after the Dockerfile `RUN` refactor.

## Supported Interfaces

### 1. Local build command contract

#### Command

```sh
make build
```

#### Local Build Expected Behavior

- Builds the default local image tag `ruby2.6-jemalloc:local`
- Uses the pinned Dockerfile build args unless the Dockerfile is intentionally updated
- Fails immediately if any Dockerfile build block exits non-zero

#### Compatibility Guarantees

- No additional required flags are introduced for standard local builds
- The resulting image remains suitable for runtime verification with the commands below

### 2. Local runtime verification contract

#### Commands

```sh
make verify
make verify-amd64
make verify-arm64
```

#### Local Verification Expected Behavior

- `make verify` builds the local image and runs runtime verification on the native platform
- `make verify-amd64` builds and verifies `linux/amd64`
- `make verify-arm64` builds and verifies `linux/arm64`
- Each command fails on the first unmet runtime assertion

#### Required Assertions

- `ruby -v` reports a Ruby `2.6.x` version line
- `ldd` on `libruby` shows jemalloc linkage
- `ldconfig -p` exposes jemalloc in the runtime image

### 3. Direct script invocation contract

#### Command Shape

```sh
./scripts/verify-ruby-jemalloc.sh <image> [platform]
```

#### Inputs

- `image`: required Docker image reference
- `platform`: optional Docker platform value passed through to `docker run`

#### Output Contract

- Prints a `[verify] image=... platform=...` banner before checks begin
- Runs the three required runtime assertions inside the container
- Prints `[verify] ruby and jemalloc checks passed` only when all assertions succeed
- Exits non-zero on invalid usage or failed assertions

### 4. CI workflow verification contract

#### Workflow File

- `.github/workflows/build.yml`

#### Required Behavior

- Runs a build matrix for `linux/amd64` and `linux/arm64`
- Uses GitHub Actions cache storage for Docker build layers
- Performs a verification image build with `--load` before runtime checks
- Invokes `./scripts/verify-ruby-jemalloc.sh` for each matrix entry
- Pushes registry images only for non-pull-request events

## Invariants

- Build args remain pinned to Ruby 2.6.10, OpenSSL 1.1.1w, and jemalloc 5.3.0 unless intentionally changed in spec, plan, and docs.
- Dockerfile here-doc blocks preserve command ordering and side effects from the pre-refactor behavior.
- Runtime verification semantics are shared between local contributor workflows and CI.
- Documentation updates in `README.md` and `specs/001-use-heredocs/quickstart.md` accompany any contract change.

## Failure Conditions

- Any non-zero command inside a here-doc block aborts the Docker build.
- Missing jemalloc linkage or missing linker cache registration causes verification failure.
- Architecture-specific failures in the CI matrix are considered contract failures even if another platform passes.

## Evidence

Verification evidence is recorded in:

- `specs/001-use-heredocs/verification/us1-build.md`
- `specs/001-use-heredocs/verification/runtime-consistency.md`
- `specs/001-use-heredocs/verification/polish-checks.md`
