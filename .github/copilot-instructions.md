<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and edge-case handling details, read specs/002-multiarch-image-cache/plan.md and treat it as the authoritative implementation context.
<!-- SPECKIT END -->

<!-- project-specific instructions start -->

# Instructions

The purpose of this project is to build a Docker container image providing the latest patch release within the Ruby 2.6.x series (intentionally pinned to 2.6, not a newer major version). The 2.6.x pin is a hard requirement.

The image must include the `jemalloc` implementation of `malloc` for improved memory performance. To support
development and testing, the resulting container will be multi-architecture, supporting both
`linux/amd64` and `linux/arm64` architectures.

The project will use `dependabot` to keep the pinned versions of Ruby, OpenSSL, and jemalloc up to date.

## Docker Specification

The resulting Docker image will be based on the "scratch" image, and have a minimal runtime footprint.
It will use a multi-stage build to limit image contents to only the compiled Ruby binaries and necessary
runtime libraries.

The `Dockerfile` will be formatted with "here-doc" `RUN` blocks for clarity and maintainability.

## CICD

* The CI workflow will be implemented with GitHub Actions, using `Buildx` for multi-architecture
  builds and cache management. Buildx cache must use the GitHub Actions cache backend (`type=gha`) with `mode=max` to cache all build layers across workflow runs.
* The workflow must push the final multi-arch manifest to [registry/image:tag]. Tags must include the full Ruby
  version (e.g. `2.6.10`) and a `latest` alias for the highest 2.6.x version. The registry credentials will be
  provided via GitHub Actions secrets named `REGISTRY_USERNAME` and `REGISTRY_PASSWORD`.
* Use the `pre-commit` toolchain for local development to ensure code quality and consistency.

## Version Control

* The project will be hosted on GitHub, with a clear branching strategy for development and releases.
* Use semantic versioning for release tags, and maintain a changelog to document changes.
* Pull requests will be used for all changes, with code review and automated testing before merging.
* Use `dependabot` to keep dependencies up to date.

<!-- project-specific instructions end -->