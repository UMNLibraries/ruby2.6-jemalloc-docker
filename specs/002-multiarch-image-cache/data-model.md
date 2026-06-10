# Data Model: Single Multi-Platform Image Build with Efficient Caching

## Entity: Multi-Platform Image Tag

**Purpose**: Represents the single published release identifier that points to both target platform variants.

### Multi-Platform Image Tag Fields

- `tag_name`: Release tag name exposed to users
- `registry`: Registry hostname or namespace where the tag is published
- `platform_variants`: Set of supported platforms included in the manifest
- `publish_status`: Whether the tag was published successfully

### Multi-Platform Image Tag Validation Rules

- A multi-platform image tag MUST include both linux/amd64 and linux/arm64 variants.
- A tag MUST not be considered release-ready unless every required platform variant is present.

## Entity: Platform Build Result

**Purpose**: Captures the build and verification outcome for one target platform.

### Platform Build Result Fields

- `platform`: Target platform for the result
- `build_status`: Success or failure of the platform build
- `verification_status`: Success or failure of runtime verification
- `elapsed_time`: Time spent building or verifying the platform
- `image_reference`: Local or remote image reference used during verification

### Platform Build Result Validation Rules

- Each platform build result MUST be recorded separately.
- A failed build or verification MUST block publication of the release tag.

## Entity: Build Cache Record

**Purpose**: Records cache reuse behavior for one build run.

### Fields

- `build_id`: Identifier for the build run
- `cache_source`: Where reused build data came from
- `cache_hits`: Number or percentage of steps restored from cache
- `cache_misses`: Number or percentage of steps rebuilt
- `affected_steps`: Build steps that were rebuilt due to input changes

### Validation Rules

- Cache reuse MUST be measurable for repeated builds.
- Unchanged build steps SHOULD be restored from cache rather than rebuilt.
- A cache record MUST be associated with the build run that produced it.
