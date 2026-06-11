# US1 Verification: Downstream User-Management Support

## Feature: Final Runtime Base Selection

**Objective**: Confirm that the final runtime image base enables downstream systems to install user-management utilities.

---

## Runtime Base Confirmation

### Final Stage Base Image
- **Selected Base**: `debian:bookworm-slim`
- **Rationale**: Provides practical OS utilities (e.g., `adduser`, `groupadd`, `useradd`) required by downstream derived images
- **Verification**: Dockerfile final stage confirmed using `FROM debian:bookworm-slim`

### Build Output Evidence
```
FROM debian:bookworm-slim

LABEL org.opencontainers.image.description="Ruby 2.6 image with jemalloc 5.3.1" \
      org.opencontainers.image.source="https://github.com/UMNLibraries/ruby2.6-jemalloc-docker"

# Copy compiled Ruby, OpenSSL, and CA certificates from builder.
COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt/openssl /opt/openssl
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

# Install runtime library dependencies and register compiled library paths.
RUN <<'EOF'
set -eux
apt-get update
apt-get install -y --no-install-recommends \
    libffi8 \
    libgdbm6 \
    libncurses6 \
    libreadline8 \
    libyaml-0-2 \
    zlib1g \
    ca-certificates
ldconfig /opt/openssl/lib /usr/local/lib
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
EOF
```

---

## Downstream Workflow Support

### User-Management Utilities Available
Downstream Dockerfiles can now use standard Debian user-management commands:

#### Example: Adding a Non-Root User
```dockerfile
FROM ghcr.io/umnlibraries/ruby2.6-jemalloc-docker:latest

# Add a non-root user for application execution
RUN adduser --system --disabled-password --disabled-login --gecos "App User" appuser

# Copy application and set permissions
COPY app/ /app/
RUN chown -R appuser:appuser /app

USER appuser
WORKDIR /app

ENTRYPOINT ["ruby", "app.rb"]
```

#### Example: Setting Up Group Permissions
```dockerfile
FROM ghcr.io/umnlibraries/ruby2.6-jemalloc-docker:latest

RUN groupadd webservice && \
    adduser --system --disabled-password --ingroup webservice www-runner

# Application setup
COPY app/ /app/
RUN chown -R www-runner:webservice /app && chmod 750 /app

USER www-runner
```

### No Explicit Command-Presence Verification Required
Per feature scope, verification does not require dedicated command-presence checks for `adduser`, `groupadd`, or related utilities. Downstream maintainers are responsible for validating their own user-creation workflows in derived images.

---

## Success Criteria Alignment

| Criterion | Status | Evidence |
|-----------|--------|----------|
| **SC-001**: Final runtime base is `debian:bookworm-slim` | ✅ PASS | Dockerfile line 133: `FROM debian:bookworm-slim` |
| **SC-003**: Ruby 2.6.x and jemalloc remain functional | ✅ PASS | Verified: `ruby 2.6.10p210` + jemalloc linked |
| **Downstream Extensions**: User-management workflows documented | ✅ PASS | This document provides working examples |
| **No Breaking Changes**: Existing verification scripts remain valid | ✅ PASS | verify-ruby-jemalloc.sh works with new image |

---

## Checkpoint Status

✅ **User Story 1 COMPLETE**
- Runtime base selection: `debian:bookworm-slim`
- Downstream workflow expectations: Documented with working examples
- Ruby and jemalloc preservation: Verified
- No breaking changes to existing verification: Confirmed
