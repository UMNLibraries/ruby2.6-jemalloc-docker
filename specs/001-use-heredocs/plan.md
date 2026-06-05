# Implementation Plan: Simplify Dockerfile RUN Commands with Here-Docs

**Branch**: `[001-use-heredocs]` | **Date**: 2026-06-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-use-heredocs/spec.md`

## Summary

Refactor long multi-step `RUN` command chains in the Dockerfile into shell here-doc blocks to improve readability and maintainability while preserving image behavior. Keep Ruby 2.6 + jemalloc compatibility unchanged, and add explicit build/runtime verification guidance for local and CI execution.

## Technical Context

**Language/Version**: Dockerfile syntax v1, shell script blocks executed by `/bin/sh` in Debian-based images

**Primary Dependencies**: Debian package manager (`apt-get`), source tarballs for OpenSSL 1.1.1w, jemalloc 5.3.0, Ruby 2.6.10

**Storage**: N/A (container image layers only)

**Testing**: `docker build`, runtime checks via `docker run` (`ruby -v`, allocator verification command)

**Target Platform**: Linux containers built in GitHub CI/CD for Intel (`linux/amd64`) and ARM (`linux/arm64`)

**Project Type**: Container build artifact repository

**Performance Goals**: No regression in build success rate; preserve current runtime behavior and startup expectations

**Constraints**: Preserve command order and side effects, keep deterministic build inputs, maintain Ruby 2.6 and jemalloc behavior, avoid introducing secrets into layers

**Scale/Scope**: Single repository, primary changes in `Dockerfile` with documentation and CI verification updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Ruby runtime alignment: PASS - plan keeps Ruby 2.6.10 target unchanged.
- jemalloc verification: PASS - tasks include runtime verification command to prove allocator presence.
- Build determinism: PASS - existing pinned build args remain; refactor is structural rather than dependency-changing.
- Required validation: PASS - plan includes local + CI build checks for amd64/arm64 and runtime validation.
- Documentation impact: PASS - README and workflow notes are updated with the new here-doc style and verification steps.

## Project Structure

### Documentation (this feature)

```text
specs/001-use-heredocs/
├── plan.md
├── spec.md
└── tasks.md
```

### Source Code (repository root)

```text
Dockerfile
README.md
.github/workflows/build.yml
```

**Structure Decision**: Single repository with Docker artifact focus. Implementation is concentrated in `Dockerfile`; verification and contributor guidance are captured in `README.md` and CI workflow checks in `.github/workflows/build.yml`.

## Complexity Tracking

No constitution violations expected for this feature.
