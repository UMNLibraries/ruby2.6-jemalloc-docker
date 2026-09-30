vim: set tw=80 :
---
# Copilot instructions for ruby2.6-jemalloc-docker

## Repository purpose

This repository builds and publishes a Docker image containing the latest stable
versions of:

- Ruby 2.6.x
- jemalloc
- OpenSSL 1.1.1.x

The primary artifact is a container image intended for publication to GitHub
Container Registry (GHCR) as a base image for a Rails application.

## Expectations for changes

- Prefer small, focused changes that match the repository's existing style.
- Preserve the current Dockerfile structure, especially the use of heredoc-style
  `RUN` blocks for build steps.
- Do not introduce unnecessary tooling, frameworks, or large refactors.
- Keep changes easy to review and compatible with the existing GitHub Actions
  setup.
- Git commit messages should follow "Conventional Commit" style, for example
  `feat: add support for Ruby 2.6.10` or `fix: update jemalloc to 5.5.0`.

## Dockerfile guidance

- Keep the build reproducible and explicit.
- Preserve multi-stage or minimal-runtime-image patterns if present.
- When changing package installation or build steps:
  - minimize added dependencies
  - clean apt metadata where appropriate
  - keep comments that explain why legacy components are required
- Do not upgrade Ruby beyond 2.6.x unless explicitly requested.
- Do not replace OpenSSL 1.1.x without confirming Ruby 2.6 compatibility.

## GitHub Actions guidance

- Prefer GitHub Actions solutions that work cleanly with the existing workflow
  layout in `.github/workflows/`.
- Reuse existing repository conventions and secrets where possible.
- For deployment/publish automation:
  - assume images should be published to
    `ghcr.io/umnlibraries/ruby2.6-jemalloc`
  - prefer tag-driven releases when implementing deploy workflows
  - avoid changing unrelated workflows unless required
- Keep workflow permissions minimal.

## Pull request expectations

When preparing changes:

- summarize the user-visible effect
- call out any required secrets, tags, or repository settings
- note any assumptions about release/tag naming
- keep documentation in sync with workflow behavior
