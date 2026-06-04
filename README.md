# ruby2.6-jemalloc-docker

Build a container running the latest 2.6.x Ruby version, with jemalloc.

## Overview

This repository provides a multistage Docker build that compiles:

- **OpenSSL 1.1.1w** – Ruby 2.6 requires OpenSSL 1.1.x; Debian's current stable ships OpenSSL 3, so OpenSSL 1.1.1 is built from source.
- **jemalloc 5.3.0** – linked into Ruby at compile time via `--with-jemalloc` for improved memory performance.
- **Ruby 2.6.10** – the latest 2.6.x release, compiled from source against the above libraries.

The multistage build keeps the final image lean by carrying over only the compiled binaries and runtime libraries from the builder stage.

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

## CI/CD

GitHub Actions builds the image on every push to `main` and publishes it to the [GitHub Container Registry](https://ghcr.io/umnlibraries/ruby2.6-jemalloc-docker). Pull requests trigger a build-only run (no push) to validate the `Dockerfile`.
