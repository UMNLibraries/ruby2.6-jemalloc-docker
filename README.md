# ruby2.6-jemalloc-docker

Build a container running the latest 2.6.x Ruby version, with jemalloc.
Supported architectures are `linux/amd64` and `linux/arm64`.

## Overview

This repository provides a multistage Docker build based on
`debian:bookworm-slim` that compiles:

- **OpenSSL 1.1.1w** – Ruby 2.6 requires OpenSSL 1.1.x; Debian's current stable
  ships OpenSSL 3, so OpenSSL 1.1.1 is built from source.
- **jemalloc 5.3.0** – linked into Ruby at compile time via `--with-jemalloc`
  for improved memory performance.
- **Ruby 2.6.10** – the latest 2.6.x release, compiled from source against the
  above libraries.
