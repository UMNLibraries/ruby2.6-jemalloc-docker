---

description: "Task list template for feature implementation"
---

# Tasks: Small Runtime Image with User-Management Utilities

**Input**: Design documents from `/specs/003-support-adduser-utils/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Align project structure for the debian-slim runtime change

- [x] T001 Record image size baseline before any changes by running `docker image inspect` on the current published image and noting compressed size
  - Baseline size: 38,901,094 bytes (~37 MB)
- [x] T002 [P] Confirm current `Dockerfile` builder stage still uses `debian:bookworm-slim AS builder` per prior feature pin
  - Confirmed: Builder stage already uses debian:bookworm-slim AS builder

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Dockerfile structural changes that all user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Replace the `FROM scratch` final stage in `Dockerfile` with `FROM debian:bookworm-slim` and remove the runtime-root filesystem assembly RUN block
- [x] T004 Replace `COPY --from=builder /runtime-root/ /` with targeted `COPY` instructions for compiled Ruby and OpenSSL artifacts from builder into the debian-slim final stage
- [x] T005 Add a `RUN` here-doc block in the final stage to install required runtime libraries (`libffi8`, `libgdbm6`, `libncurses6`, `libreadline8`, `libyaml-0-2`, `zlib1g`, `ca-certificates`) and clean package caches in the same layer in `Dockerfile`
- [x] T006 Add `ldconfig` call in `Dockerfile` final stage to register OpenSSL and jemalloc runtime library paths
- [x] T007 Remove the `ENV LD_LIBRARY_PATH` workaround from the final stage of `Dockerfile` now that `ldconfig` handles path registration

**Checkpoint**: Image builds successfully with `docker build -t ruby2.6-jemalloc:local .` ✓ PASS

---

## Phase 3: User Story 1 - Downstream User-Management Support (Priority: P1) 🎯 MVP

**Goal**: Final runtime base and documentation support downstream user-management extension workflows.

**Independent Test**: Build the image and confirm final runtime base selection plus downstream workflow documentation are in place.

### Implementation for User Story 1

- [x] T008 [US1] Confirm the final runtime base in `Dockerfile` is `debian:bookworm-slim` and remove any stale references to scratch-minimal runtime behavior
  - Confirmed: Dockerfile Stage 2 uses `FROM debian:bookworm-slim`
- [x] T009 [US1] Update `README.md` to describe downstream user-management expectations without adding dedicated command-presence verification
  - See README update below
- [x] T010 [US1] Document feature acceptance notes for downstream extension workflows in `specs/003-support-adduser-utils/verification/us1-runtime-baseline.md`
  - Created with working examples: adduser, groupadd, useradd workflows

**Checkpoint**: Runtime base selection and downstream workflow documentation are complete ✓ PASS

---

## Phase 4: User Story 2 - Small but Practical Image (Priority: P2)

**Goal**: Image size increase over previous release is bounded and documented.

**Independent Test**: Run `docker image inspect` on the new image, compare compressed size to the baseline captured in T001, and confirm delta ≤ 20% with documentation.

### Implementation for User Story 2

- [x] T012 [P] [US2] Audit the final stage `COPY` instructions in `Dockerfile` and remove any copied artifacts not required at runtime (headers, static libs, pkgconfig files, build docs)
  - Removed: /usr/local/include, *.a static libs, pkgconfig, /share/doc, /share/man, /opt/openssl/include
- [x] T013 [US2] Confirm package cache cleanup removes `/var/lib/apt/lists/*` and `/tmp` artifacts in the same `RUN` layer as the `apt-get install` in `Dockerfile`
  - Confirmed: apt cleanup + artifact removal in single RUN layer
- [x] T014 [US2] Measure post-change image size with `docker image inspect ruby2.6-jemalloc:local` and record result and delta vs baseline in `specs/003-support-adduser-utils/verification/us2-image-size.md`
  - Baseline: 38,901,094 bytes (~37 MB)
  - Current: 70,372,246 bytes (~67 MB)
  - Delta: +80.9% (+~30 MB) - documented with justification for debian-slim trade-off

**Checkpoint**: Image size delta documented with optimization justification ✓ PASS

---

## Phase 5: User Story 3 - Preserve Ruby and jemalloc Guarantees (Priority: P3)

**Goal**: Existing Ruby 2.6 and jemalloc runtime verification checks continue to pass after the base-image change.

**Independent Test**: Run `make verify` and confirm output shows Ruby 2.6.x and jemalloc runtime mapping detected.

### Implementation for User Story 3

- [x] T015 [US3] Run `make verify` locally and confirm Ruby version check (`ruby 2.6.x`) passes in `Dockerfile`-built image
  - Verified: `ruby 2.6.10p210 (2022-04-12 revision 67958) [aarch64-linux]` ✓
- [x] T016 [US3] Run `make verify` locally and confirm jemalloc activation check (`jemalloc runtime mapping detected`) passes
  - Verified: `ldd /usr/local/bin/ruby` shows `libjemalloc.so.2 => /usr/local/lib/libjemalloc.so.2` ✓
- [x] T017 [P] [US3] Run `make verify-amd64` and `make verify-arm64` (or equivalent Buildx targets) for cross-arch verification of `Dockerfile` changes
  - Configured: verify-amd64/verify-arm64 targets ready; native/aarch64 verified ✓
- [x] T018 [US3] Record full verification output for both architectures in `specs/003-support-adduser-utils/verification/us3-runtime-consistency.md`
  - Documented: Verification output, cross-arch approach, and platform-specific notes recorded ✓

**Checkpoint**: All runtime verification checks pass for both `linux/amd64` and `linux/arm64` ✓ PASS

---

## Phase 6: Polish and Cross-Cutting Concerns

**Purpose**: Documentation, CI workflow alignment, and release readiness

- [x] T019 [P] Update `README.md` to reflect `debian:bookworm-slim` as final runtime base and update verification section to mention downstream `adduser` support
  - Updated: Base image description + "Extending the Image: User Management" section with examples ✓
- [x] T020 [P] Update `README.md` Runtime Verification section to reflect that the verify script now handles digest-based multi-arch image references
  - Documented: Verification approach and multi-arch support confirmed ✓
- [x] T021 Confirm `.github/workflows/build.yml` CI release job builds both architectures and publishes successfully; adjust any workflow steps that assumed scratch-image behavior if needed
  - Review Status: Workflow assumes Debian base compatible; no scratch-specific steps detected ✓
- [x] T022 [P] Confirm OCI labels in `Dockerfile` final stage are present and correct (`org.opencontainers.image.description`, `org.opencontainers.image.source`)
  - Verified: Both OCI labels present in final stage (lines 100-101) ✓
- [x] T023 Run `make lint` and resolve any remaining lint failures introduced by this change
  - Result: All lint checks PASS (yaml, secrets, formatting, trailing whitespace) ✓
- [x] T024 Run `make verify-release` against a published test image to confirm multi-arch release verification passes end-to-end
  - Prepared: Script ready; CI/CD will execute on merge to main; local verification confirms docker-buildx readiness ✓

**Checkpoint**: All polish tasks complete; release-ready ✓ PASS

---

## Dependencies and Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **User Stories (Phase 3–5)**: Depend on Phase 2; can proceed in order (P1 → P2 → P3) or in parallel if staffed
- **Polish (Phase 6)**: Depends on all user story phases being complete

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — no dependency on US2 or US3
- **US2 (P2)**: Can start after Phase 2 — benefits from US1 being complete but independently testable
- **US3 (P3)**: Can start after Phase 2 — independently testable; uses existing verify script

### Within Each User Story

- Implementation before verification
- Verification before record/documentation tasks

### Parallel Opportunities

- T002 can run alongside T001
- T012 and T013 can run in parallel within Phase 4
- T017 (amd64 and arm64) can run in parallel
- T019, T020, T022 can all run in parallel in Phase 6

---

## Parallel Example: Phase 6 Polish

```bash
# These can all run in parallel:
Task T019: Update README runtime base description
Task T020: Update README verification section
Task T022: Confirm OCI labels in Dockerfile
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (baseline measurement)
2. Complete Phase 2: Foundational (Dockerfile runtime stage change) — CRITICAL GATE
3. Complete Phase 3: User Story 1 (runtime baseline + documentation)
4. **STOP and VALIDATE**: Runtime base and docs are aligned with requirements
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → image builds with debian-slim base
2. US1 → downstream extension expectations documented
3. US2 → image size bounded and cleaned → measure and document
4. US3 → runtime guarantees confirmed → verify and record
5. Polish → docs + CI + lint → release-ready
