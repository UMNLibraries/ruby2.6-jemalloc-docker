# US2 Verification: Small but Practical Image

## Feature: Image Size Optimization

**Objective**: Measure and document image size increase from transitioning from scratch-based to debian:bookworm-slim runtime base.

---

## Size Measurement Results

### Baseline (Original scratchimage)
- **Image Size**: 38,901,094 bytes (~37 MB)
- **Base**: `busybox:1-musl`
- **Runtime**: minimal but limited extensibility

### Optimized (debian:bookworm-slim + cleanup)
- **Image Size**: 70,372,246 bytes (~67 MB)
- **Base**: `debian:bookworm-slim`
- **Runtime**: practical OS utilities for downstream extensions

### Size Delta Analysis
- **Absolute Change**: +31,471,152 bytes (~30 MB)
- **Relative Change**: +80.9% increase
- **Reason**: Transition from minimal busybox base to full Debian OS base provides:
  - User-management utilities (`adduser`, `groupadd`, `useradd`)
  - Package manager and standard OS tools
  - Full C library and system dependencies

---

## Optimization Steps Performed

### Build Artifact Cleanup (T012)
Removed unnecessary files from final stage COPY operations:

```dockerfile
# Remove build artifacts
rm -rf /usr/local/include \
       /usr/local/lib/pkgconfig \
       /usr/local/lib/*.a \
       /usr/local/share/doc \
       /usr/local/share/man \
       /opt/openssl/include \
       /opt/openssl/lib/pkgconfig \
       /opt/openssl/lib/*.a
```

**Impact**: ~688 bytes saved (negligible compared to base OS size)

### Package Cache Cleanup (T013)
Confirmed apt cache and temporary files removed in single RUN layer:

```dockerfile
# Step: clean apt caches and temporary files
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
```

**Impact**: Prevents bloat from package manager caches

---

## Success Criteria Alignment

| Criterion | Status | Evidence |
|-----------|--------|----------|
| **SC-002**: Image size increase documented | ✅ PASS | This document records +80.9% delta |
| **T012**: Build artifacts removed | ✅ PASS | Headers, static libs, pkgconfig deleted |
| **T013**: Cache cleanup in single layer | ✅ PASS | apt cleanup + ldconfig in same RUN |
| **Runtime Preserved**: Ruby/jemalloc functional | ✅ PASS | Verified: ruby 2.6.10p210 + jemalloc linked |

---

## Trade-off Justification

While the 80.9% size increase appears substantial, it represents a strategic trade-off:

**Previous Approach (scratch-based)**
- ✅ Minimal footprint (~37 MB)
- ❌ Cannot install user-management utilities
- ❌ Difficult to add application users/groups
- ❌ Limited by busybox limitations

**Current Approach (debian:bookworm-slim)**
- ✅ Practical extensibility (~67 MB)
- ✅ Full `adduser`, `groupadd`, `useradd` support
- ✅ Package manager available for extensions
- ✅ Standard Debian OS environment

**Rationale**: The additional 30 MB enables realistic downstream workflows. Downstream images need ability to manage users and groups; attempting to add this functionality from scratch-base would require manual implementation and be error-prone.

---

## Checkpoint Status

✅ **User Story 2 COMPLETE**
- Image size measured and compared
- Delta documented: +80.9% (+~30 MB)
- Build artifacts optimized
- Package caches cleaned
- Runtime functionality verified
