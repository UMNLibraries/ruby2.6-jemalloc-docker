# Data Model: Runtime Utility Baseline Feature

## Entity: Runtime Utility Baseline

**Purpose**: Represents runtime capabilities available by default in the final `debian:bookworm-slim` image.

### Fields

- `base_image`: final runtime base image reference
- `user_mgmt_available`: whether downstream `adduser` workflows function in derived images
- `runtime_packages`: runtime package subset retained in final image
- `cleanup_state`: confirmation that temp/cache files are removed

### Validation Rules

- `base_image` must be `debian:bookworm-slim`.
- `user_mgmt_available` must be true for release eligibility.
- `cleanup_state` must pass hygiene checks.

## Entity: Derived Image Build Step

**Purpose**: Captures a downstream Dockerfile step that uses user-management commands.

### Fields

- `command`: user-management command executed by downstream image
- `mode`: non-interactive or interactive
- `result`: success/failure

### Validation Rules

- Non-interactive downstream build usage must succeed.

## Entity: Verification Result

**Purpose**: Captures build and runtime verification outcomes for each architecture.

### Fields

- `platform`: `linux/amd64` or `linux/arm64`
- `build_passed`: build success flag
- `ruby_version_ok`: Ruby 2.6 verification result
- `jemalloc_ok`: allocator verification result
- `hygiene_ok`: temp-file cleanup verification result

### Validation Rules

- All verification fields must pass for both target platforms before release.
