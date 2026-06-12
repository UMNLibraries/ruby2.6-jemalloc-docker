<!-- copilot instructions start -->
Use professional, neutral language.
No jokes, sarcasm, playful metaphors, or “cute” commentary.
Keep responses direct and task-focused.
<!-- copilot instructions end -->

<!-- SPECKIT START -->
When writing markdown files, use the following guidelines:
- wrap lines at 80 characters

For additional context about technologies to be used, project structure,
shell commands, and edge-case handling details, read specs/003-support-adduser-utils/plan.md
and treat it as the authoritative implementation context.
<!-- SPECKIT END -->

<!-- project-specific instructions start -->

# Instructions

For governance principles, constraints, and PR requirements, see `.specify/memory/constitution.md`.

The purpose of this project is to build a Docker container image providing the latest patch release
within the Ruby 2.6.x series (intentionally pinned to 2.6, not a newer major version). The 2.6.x pin
is a hard requirement.

The image must include the `jemalloc` implementation of `malloc` for improved memory performance.
The resulting container must be multi-architecture, supporting both `linux/amd64` and `linux/arm64`
architectures.

The image must be derived from a `debian:bookworm-slim` base layer so that downstream images can
install additional packages via `apt-get`. Build artifacts must be minimized, but a functional
package manager must be present in the final image.

## Docker Specification

The build stage must use `debian:bookworm-slim` as the builder image.
It will use a multi-stage build to remove unnecessary image contents.

The `Dockerfile` will be formatted with "here-doc" `RUN` blocks for clarity and maintainability.
The `Dockerfile` must be linted with `hadolint` and follow best practices for layer management and caching.
The `Dockerfile` must include a LABEL with the project name, description, and version.

## Dependency Version Management

The project will use `dependabot` to keep the base builder image up to date. Dependabot is
configured using the `docker` ecosystem in `.github/dependabot.yml`.

Ruby, OpenSSL, and jemalloc version strings are embedded in Dockerfile `ARG` declarations
and are not trackable by Dependabot's built-in ecosystems; these must be updated manually
via pull requests when new patch releases are available.

## CICD

[registry]: ghcr.io/umnlibraries/ruby2.6-jemalloc-docker

* The CI workflow will be implemented with GitHub Actions, using `Buildx` for
  multi-architecture builds and cache management. Buildx cache must use the
  GitHub Actions cache backend (`type=gha`) with `mode=max` to cache all build
  layers across workflow runs.
* The workflow is triggered only when a semantic version tag (e.g., `v1.2.3`) is pushed to the
  repository. Pull request and branch builds must not push images to the registry.
* Tags pushed to the registry must include the full Ruby version (e.g., `2.6.10`). The `latest`
  tag is managed as follows:
  1. The workflow receives the Ruby version as a build arg (e.g., `RUBY_VERSION=2.6.10`).
  2. After a successful build, the workflow queries the GHCR registry API to list all published
     tags matching the pattern `2.6.*`.
  3. The workflow compares `RUBY_VERSION` against the highest published `2.6.x` tag using
     semver comparison.
  4. If `RUBY_VERSION` is strictly greater than the highest published tag, the workflow also
     pushes the `latest` tag.
  5. If `RUBY_VERSION` is equal to or lower than the highest published tag, only the
     version-specific tag (e.g., `2.6.10`) is pushed.
  6. If the registry API query fails or returns no existing `2.6.x` tags (e.g., on first
     publish), the workflow must treat the current version as the highest and push both the
     version-specific tag and `latest`. The comparison step must not fail the entire build if
     tag comparison is unavailable.
* The registry credentials will be provided via GitHub Actions secrets named `REGISTRY_USERNAME`
  and `REGISTRY_PASSWORD`.

## Version Control

* The project will be hosted on GitHub, with a clear branching strategy for
  development and releases.
* Use semantic versioning (`MAJOR.MINOR.PATCH`, e.g., `1.0.0`) for the
  Dockerfile project's own release tags. These project release tags are
  distinct from the version tags of the image dependencies, including Ruby,
  Debian, and jemalloc.
* Maintain a `CHANGELOG.md` file updated with each project release.
* Pull requests will be used for all changes, with code review and automated
  testing before merging.
* Built images will not be pushed to the registry from pull request builds.
  Only builds triggered by a tag push should push images to the registry.

## Release Management

* When a new tag is pushed to the repository, the CI workflow will
  automatically build and push the corresponding Docker image to the registry.
  In addition it will update the "latest" tag if the new version is a higher
  patch version than the current "latest" tag.
* The release process will include validation steps to ensure the image is
  built correctly and functions as expected before it is published.
* The project should contain a changelog file that is updated with each
  release, detailing the changes made in that release.
* The project will use semantic versioning for release tags, following the
  format `MAJOR.MINOR.PATCH` (e.g., `1.2.3`).

## Validation

* The project will use the `pre-commit` toolchain for local development to
  ensure code quality and consistency.
* A `make lint` target will be used to lint files in the repository by running
  `pre-commit run --all-files`. The pre-commit configuration invokes `yamllint`
  (with `.yamllint.yml`) for `.yml`/`.yaml` files and `check-yaml` for YAML
  syntax validation. Markdown and JSON files are checked for trailing whitespace
  and line-ending consistency.

<!-- project-specific instructions end -->
