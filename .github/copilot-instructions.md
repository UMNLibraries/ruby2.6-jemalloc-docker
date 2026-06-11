<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and edge-case handling details, read specs/003-support-adduser-utils/plan.md
and treat it as the authoritative implementation context.
<!-- SPECKIT END -->

<!-- project-specific instructions start -->

# Instructions

The purpose of this project is to build a Docker container image providing the latest patch release
within the Ruby 2.6.x series (intentionally pinned to 2.6, not a newer major version). The 2.6.x pin
is a hard requirement.

The image must include the `jemalloc` implementation of `malloc` for improved memory performance.
To support development and testing, the resulting container will be multi-architecture, supporting both
`linux/amd64` and `linux/arm64` architectures.

This container image is intended to be used in turn as a base image for rails and other applications,
so the image must support the ability to install additional packages whose identities are not yet known
at this time.

The image must include the `jemalloc` implementation of `malloc` for improved memory performance.
To support development and testing, the resulting container will be multi-architecture, supporting both
`linux/amd64` and `linux/arm64` architectures.

The project will use `dependabot` to keep the pinned versions of Ruby, OpenSSL, and jemalloc up to
 date.

## Docker Specification

The resulting Docker image will be based on the "scratch" image, and have a minimal runtime footprint.
It will use a multi-stage build to limit image contents to only the compiled Ruby binaries, necessary
runtime libraries, and files needed for testing and validating the image.

The `Dockerfile` will be formatted with "here-doc" `RUN` blocks for clarity and maintainability.

## CICD

[registry]: ghcr.io/umnlibraries/ruby2.6-jemalloc-docker

* The CI workflow will be implemented with GitHub Actions, using `Buildx` for multi-architecture
  builds and cache management. Buildx cache must use the GitHub Actions cache backend (`type=gha`) with `mode=max` to cache all build layers across workflow runs.
* The workflow must push the final multi-arch manifest to [registry]:latest. Tags must include the full Ruby
  version (e.g. `2.6.10`) and a `latest` alias for the highest 2.6.x version. The `latest` tag must be updated only
  when the image being built carries a Ruby patch version higher than any previously published 2.6.x tag in the
  registry; the workflow should derive the Ruby version from build args and compare it against existing registry tags
  before deciding to also push `latest`. The registry credentials will be
  provided via GitHub Actions secrets named `REGISTRY_USERNAME` and `REGISTRY_PASSWORD`.

## Version Control

* The project will be hosted on GitHub, with a clear branching strategy for development and releases.
* Use semantic versioning for release tags, and maintain a changelog to document changes.
* Pull requests will be used for all changes, with code review and automated testing before merging.
* Use `dependabot` to keep dependencies up to date.

## Release Management

* When a new tag is pushed to the repository, the CI workflow will automatically build and push the
  corresponding Docker image to the registry.
* The release process will include validation steps to ensure the image is built correctly and functions
  as expected before it is published.

## Validation

* The project will use the `pre-commit` toolchain for local development to ensure code quality
  and consistency.
* A `make lint` target will be used to lint all markdown, JSON, and YAML files in the repository,
  ensuring source code quality.

<!-- project-specific instructions end -->
