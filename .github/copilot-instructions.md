<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read specs/002-multiarch-image-cache/plan.md
<!-- SPECKIT END -->

<!-- tram0004 instructions start -->

# Instructions

The purpose of this project is to build a Docker container image providing the latest version of Ruby
2.6.x, including the  `jemalloc` implementation of `malloc` for improved memory performance. To support
development and testing, the resulting container will be multi-architecture, supporting both
`linux/amd64` and `linux/arm64` architectures.

The project will use `dependabot` to keep the pinned versions of Ruby, OpenSSL, and jemalloc up to date.

## Docker Specification

The resulting Docker image will have a minimal runtime footprint, using a multi-stage build to limit
image contents to only the compiled Ruby binaries and necessary runtime libraries.

The `Dockerfile` will be formatted with "here-doc" `RUN` blocks for clarity and maintainability.

The image will provide the latest compatible versions of its dependencies:

* Ruby 2.6.x (currently 2.6.10)
* OpenSSL 1.1.x (currently 1.1.1w)
* jemalloc 5.3.x (currently 5.3.0)

## CICD

* The CI workflow will be implemented with GitHub Actions, using `Buildx` for multi-architecture
  builds and cache management.
* Use the `pre-commit` toolchain for local development to ensure code quality and consistency.

<!-- tram0004 instructions end -->