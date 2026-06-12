# ruby2.6-jemalloc-docker

Build a container running the latest 2.6.x Ruby version, with jemalloc.

## Overview

This repository provides a multistage Docker build that compiles:

- **OpenSSL 1.1.1w** – Ruby 2.6 requires OpenSSL 1.1.x; Debian's current stable ships OpenSSL 3, so OpenSSL 1.1.1 is built from source.
- **jemalloc 5.3.0** – linked into Ruby at compile time via `--with-jemalloc` for improved memory performance.
- **Ruby 2.6.10** – the latest 2.6.x release, compiled from source against the above libraries.

The multistage build carries compiled binaries and required runtime libraries into a `debian:bookworm-slim` final image, providing a practical balance between image size and runtime extensibility.

## Build Command Style

Long Docker build sequences are expressed with shell here-doc `RUN` blocks so each logical step
is easier to review and maintain. This keeps ordering explicit while avoiding fragile line
continuation chains.

## Multi-Platform Release and Caching

The release workflow publishes one image tag that resolves to both `linux/amd64` and
`linux/arm64` variants. GitHub Actions uses Buildx cache import/export so unchanged work can be
reused across repeated builds.

Local contributors can mirror the release workflow with:

```sh
make build-release
make verify-release
```

`make build-release` publishes the multi-platform image tag and preserves cache in `.buildx-cache`
between runs. `make verify-release` pulls the published tag and verifies both architectures.

## Usage

### Pull from GitHub Container Registry

```sh
docker pull ghcr.io/umnlibraries/ruby2.6-jemalloc-docker:latest
```

### Build locally

```sh
docker build -t ruby2.6-jemalloc .
```

Override versions at build time with `--build-arg`:

```sh
docker build \
  --build-arg RUBY_VERSION=2.6.10 \
  --build-arg OPENSSL_VERSION=1.1.1w \
  --build-arg JEMALLOC_VERSION=5.3.0 \
  -t ruby2.6-jemalloc .
```

### Run

```sh
docker run --rm -it ghcr.io/umnlibraries/ruby2.6-jemalloc-docker:latest ruby -v
```

### Runtime Verification

Use the provided verification script after a local build:

```sh
make verify
```

Verify specific architectures (requires platform emulation support where needed):

```sh
make verify-amd64
make verify-arm64
```

For the multi-platform release flow, use:

```sh
make build-release
make verify-release
```

The verification script checks:

- Ruby reports `2.6.x`
- jemalloc is mapped into the running Ruby process (`/proc/self/maps`)

## Extending the Image: User Management

The `debian:bookworm-slim` final stage includes user-management utilities, enabling downstream images to create application users and groups. This is useful for running Ruby applications with reduced privileges.

### Example: Creating a Non-Root User

```dockerfile
FROM ghcr.io/umnlibraries/ruby2.6-jemalloc-docker:latest

# Create a non-root user for the application
RUN adduser --system --disabled-password --disabled-login \
    --gecos "Ruby App" rubyapp

# Copy application code
COPY app/ /app/

# Set ownership and permissions
RUN chown -R rubyapp:rubyapp /app && chmod 750 /app

USER rubyapp
WORKDIR /app

ENTRYPOINT ["ruby", "app.rb"]
```

### Example: Managing Groups

```dockerfile
FROM ghcr.io/umnlibraries/ruby2.6-jemalloc-docker:latest

# Create a group and user
RUN groupadd webservices && \
    adduser --system --disabled-password --ingroup webservices www-user

COPY app/ /app/
RUN chown -R www-user:webservices /app

USER www-user
```

The base image does not include verification of specific user-management commands in derived layers; downstream maintainers are responsible for validating user creation and permission workflows in their own Dockerfiles.

## CI/CD

GitHub Actions publishes one multi-platform image tag on pushes to `main` and manual release
runs. Pull requests run per-platform verification builds with cache reuse enabled so changes are
validated without publishing.

The release job publishes a single manifest-backed tag for `linux/amd64` and `linux/arm64`, while
the verification job checks the published tag on `main` and uses cached per-platform build/load
runs on pull requests.
