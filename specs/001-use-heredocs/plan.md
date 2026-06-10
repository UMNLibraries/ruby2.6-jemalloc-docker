# Implementation Plan: Simplify Dockerfile RUN Commands with Here-Docs

**Branch**: `[001-use-heredocs]` | **Date**: 2026-06-09 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-use-heredocs/spec.md`

## Summary

Refactor long multi-step `RUN` command chains in the Dockerfile into shell here-doc blocks to improve readability and maintainability while preserving image behavior. Keep Ruby 2.6 + jemalloc compatibility unchanged, preserve deterministic build inputs, and document the verification contract shared by local contributors and CI.

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

## Phase 0 Research

Research findings are captured in [research.md](./research.md).

- Here-doc `RUN` blocks are the preferred representation for multi-step source-build flows because
  they preserve order, improve editability, and make failures easier to localize.
- Determinism depends on preserving pinned versions, canonical source URLs, cleanup behavior, and
  the OpenSSL -> jemalloc -> Ruby build order.
- Runtime verification must keep the existing three-part contract: Ruby version, jemalloc linkage,
  and linker-cache visibility.

No `NEEDS CLARIFICATION` items remain after research.

## Phase 1 Design

- Data model: [data-model.md](./data-model.md)
- Interface contract: [contracts/build-verification-contract.md](./contracts/build-verification-contract.md)
- Quickstart: [quickstart.md](./quickstart.md)

## Project Structure

### Documentation (this feature)

```text
specs/001-use-heredocs/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── build-verification-contract.md
├── spec.md
├── verification/
└── tasks.md
```

### Source Code (repository root)

```text
Dockerfile
README.md
.github/workflows/build.yml
Makefile
scripts/verify-ruby-jemalloc.sh
```

**Structure Decision**: Single repository with Docker artifact focus. Implementation is concentrated in `Dockerfile`; verification behavior is exposed through `Makefile`, `scripts/verify-ruby-jemalloc.sh`, and `.github/workflows/build.yml`; contributor guidance and evidence are captured in `README.md` and the feature spec directory.

## Post-Design Constitution Check

- Ruby runtime alignment: PASS - design artifacts keep Ruby 2.6.10 as the runtime target and do
  not introduce migration work.
- jemalloc verification: PASS - the contract and data model require scriptable runtime checks for
  linkage and linker-cache visibility.
- Build determinism: PASS - research and quickstart preserve pinned versions, source locations,
  cleanup rules, and stage ordering.
- Required validation: PASS - quickstart and contract docs define local and CI verification paths
  for amd64 and arm64.
- Documentation impact: PASS - the feature documents contract changes in the plan artifacts and
  keeps README alignment explicit.

## Complexity Tracking

No constitution violations expected for this feature.
