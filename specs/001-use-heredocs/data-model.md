# Data Model: Simplify Dockerfile RUN Commands with Here-Docs

## Entity: Build Command Block

**Purpose**: Represents one logical multi-step shell sequence inside the Dockerfile that contributors can review, edit, and troubleshoot as a single unit.

### Build Command Block Fields

- `name`: Human-readable identifier for the block, such as `builder-deps`, `openssl-build`, `jemalloc-build`, `ruby-build`, or `runtime-deps`
- `stage`: Docker stage where the block executes (`builder` or `runtime`)
- `shell_mode`: Required shell safety flags for the block, currently `set -eux`
- `ordered_steps`: Ordered list of shell operations contained in the here-doc block
- `inputs`: Build args, environment variables, packages, or source tarballs consumed by the block
- `outputs`: Installed binaries, libraries, config files, or cleaned directories produced by the block
- `cleanup_actions`: Cleanup work that must occur before the block completes successfully
- `failure_boundary`: The first command whose non-zero exit code aborts the block and the build

### Build Command Block Validation Rules

- A build command block MUST be expressed as a multi-line here-doc `RUN` block when it contains multiple sequential steps.
- A build command block MUST begin with `set -eux` so failures remain immediate and traceable.
- A build command block MUST preserve the pre-refactor execution order of dependent commands.
- Cleanup steps for package indexes or extracted build artifacts MUST remain in the same logical block as the work that created them.
- Comment labels SHOULD identify major steps to improve log traceability.

### Build Command Block Relationships

- A build command block contributes to one `Build Artifact`.
- A build command block can be referenced by one or more `Verification Record` entries when evidence is captured after a build.

### Build Command Block State Transitions

- `defined` -> `implemented` when the block exists in the Dockerfile with ordered steps.
- `implemented` -> `validated` when build and runtime verification succeed against the resulting image.
- `implemented` -> `failed` when a command exits non-zero or verification reveals a behavioral regression.

## Entity: Build Artifact

**Purpose**: Represents the container image output produced from the Dockerfile for a specific platform and set of pinned build inputs.

### Build Artifact Fields

- `image_tag`: Local or CI tag applied to the image, such as `ruby2.6-jemalloc:local` or `ruby2.6-jemalloc:ci-amd64`
- `platform`: Target platform, such as `linux/amd64` or `linux/arm64`
- `ruby_version`: Expected Ruby version line, currently `2.6.10`
- `openssl_version`: Expected OpenSSL source version, currently `1.1.1w`
- `jemalloc_version`: Expected jemalloc source version, currently `5.3.0`
- `source_locations`: Canonical download endpoints used during the build
- `runtime_paths`: Library locations that must be available at runtime, including `/opt/openssl/lib` and `/usr/local/lib`

### Build Artifact Validation Rules

- A build artifact MUST be produced from pinned build args documented in the Dockerfile, workflow, and quickstart.
- A build artifact MUST preserve Ruby 2.6 compatibility and jemalloc linkage.
- A build artifact MUST be reproducible for both supported platforms in CI.

### Build Artifact Relationships

- A build artifact is produced by multiple `Build Command Block` instances.
- A build artifact is evaluated by one or more `Verification Record` entries.

## Entity: Verification Record

**Purpose**: Captures repeatable evidence that a built image still satisfies runtime expectations after the Dockerfile refactor.

### Verification Record Fields

- `artifact_tag`: Reference to the built image under test
- `platform`: Platform used for the verification run
- `ruby_version_check`: Result of validating that `ruby -v` reports `2.6.x`
- `jemalloc_link_check`: Result of validating `libruby` linkage to jemalloc via `ldd`
- `linker_cache_check`: Result of validating `ldconfig -p` exposes jemalloc in the runtime image
- `execution_path`: Command path used to run verification, such as `make verify` or `./scripts/verify-ruby-jemalloc.sh`
- `status`: `planned`, `passed`, or `failed`
- `evidence_location`: Path to captured notes or verification artifact files under `specs/001-use-heredocs/verification/`

### Verification Record Validation Rules

- A verification record MUST capture all three runtime assertions: Ruby version, jemalloc linkage, and linker cache availability.
- A verification record MUST identify the tested image and platform.
- A failed check MUST leave enough command context to reproduce the failure locally or in CI.

### Verification Record Relationships

- A verification record validates one `Build Artifact`.
- A verification record provides evidence for the affected `Build Command Block` instances.

### Verification Record State Transitions

- `planned` -> `passed` when all required verification commands succeed.
- `planned` -> `failed` when any runtime assertion fails.
- `failed` -> `passed` after the artifact is rebuilt and all verification checks succeed.
