# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic
Versioning for project releases.

## [Unreleased]

### Changed

- Align release workflow with tag-based publishing and conditional `latest`
  promotion.
- Add hadolint to pre-commit checks.

## [1.2.0] - 2026-06-11

### Changed

- Switched final runtime image to `debian:bookworm-slim` to support downstream
  package installation and user-management workflows.
- Kept Ruby 2.6 and jemalloc verification behavior while updating runtime image
  composition.
- Updated verification docs for downstream usage and runtime consistency.

## [1.1.0] - 2026-06-09

### Changed

- Added multi-architecture Buildx workflow support for `linux/amd64` and
  `linux/arm64`.
- Added GitHub Actions cache backend usage (`type=gha`, `mode=max`) for
  improved layer reuse.

## [1.0.0] - 2026-06-04

### Changed

- Standardized Dockerfile build steps using heredoc `RUN` blocks for improved
  readability and maintenance.
- Established initial Ruby 2.6 + jemalloc container baseline.
