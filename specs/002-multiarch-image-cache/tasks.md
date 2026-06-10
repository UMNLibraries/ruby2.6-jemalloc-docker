# Tasks: Single Multi-Platform Image Build with Efficient Caching

**Input**: Design documents from `/specs/002-multiarch-image-cache/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: No standalone TDD suite was requested in the feature specification; verification tasks are included as build, cache, and runtime evidence.

**Organization**: Tasks are grouped by user story to preserve independent implementation and validation.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare shared workflow, build, and contributor scaffolding for the multi-platform release flow.

- [X] T001 Update release workflow structure for multi-platform publication in .github/workflows/build.yml
- [X] T002 [P] Add cache-enabled Buildx build settings for release jobs in .github/workflows/build.yml
- [X] T003 [P] Add local multi-platform build and verify targets in Makefile
- [X] T004 [P] Record contributor-facing single-tag release guidance in README.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish design, contract, and evidence scaffolding required before user story delivery.

**⚠️ CRITICAL**: No user story work should begin until this phase is complete.

- [X] T005 Capture multi-platform manifest and cache reuse decisions in specs/002-multiarch-image-cache/research.md
- [X] T006 [P] Finalize build result and cache record entities in specs/002-multiarch-image-cache/data-model.md
- [X] T007 [P] Finalize single-tag release and cache reuse contract in specs/002-multiarch-image-cache/contracts/build-release-contract.md
- [X] T008 Document cold-build and warm-build validation flow in specs/002-multiarch-image-cache/quickstart.md
- [X] T009 Create release-manifest evidence template in specs/002-multiarch-image-cache/verification/release-manifest.md
- [X] T010 Create cache-reuse evidence template in specs/002-multiarch-image-cache/verification/cache-reuse.md

**Checkpoint**: Foundation ready; story work can begin.

---

## Phase 3: User Story 1 - Publish One Multi-Platform Image (Priority: P1) 🎯 MVP

**Goal**: Publish one release tag that resolves to both linux/amd64 and linux/arm64 variants.

**Independent Test**: Trigger one release build and confirm the same tag resolves to a working variant on both amd64 and arm64 hosts.

### Implementation for User Story 1

- [X] T011 [US1] Publish one manifest-backed image tag for both amd64 and arm64 in .github/workflows/build.yml
- [X] T012 [US1] Validate release publication includes both platform variants in .github/workflows/build.yml
- [X] T013 [US1] Record single-tag publication evidence in specs/002-multiarch-image-cache/verification/release-manifest.md

**Checkpoint**: User Story 1 can be demonstrated and validated independently.

---

## Phase 4: User Story 2 - Reduce Rebuild Time Through Cache Reuse (Priority: P2)

**Goal**: Reuse prior build work so unchanged layers are not rebuilt on repeated runs.

**Independent Test**: Run a cold build and a warm build with unchanged inputs and confirm cache reuse reduces duplicated work.

### Implementation for User Story 2

- [X] T014 [US2] Enable remote cache import/export for repeated builds in .github/workflows/build.yml
- [X] T015 [US2] Add cache-aware local build guidance and targets in Makefile
- [X] T016 [US2] Record warm-build and cache-hit evidence in specs/002-multiarch-image-cache/verification/cache-reuse.md

**Checkpoint**: User Story 2 is independently verifiable with cache evidence.

---

## Phase 5: User Story 3 - Preserve Runtime Verification Across Platforms (Priority: P3)

**Goal**: Keep Ruby and jemalloc verification passing for both amd64 and arm64 outputs.

**Independent Test**: After publishing the multi-platform image, run runtime verification for both platforms and confirm all checks pass.

### Implementation for User Story 3

- [X] T017 [US3] Keep runtime verification checks aligned with both target platforms in scripts/verify-ruby-jemalloc.sh
- [X] T018 [US3] Wire runtime verification into the release workflow for both platforms in .github/workflows/build.yml
- [X] T019 [P] [US3] Document runtime verification and release-gating behavior in README.md
- [X] T020 [US3] Record runtime verification evidence for both platform variants in specs/002-multiarch-image-cache/verification/runtime-consistency.md

**Checkpoint**: User Story 3 provides standalone runtime confidence for the release flow.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final alignment across docs, workflow, and evidence artifacts.

- [X] T021 [P] Validate quickstart examples against final workflow commands in specs/002-multiarch-image-cache/quickstart.md
- [X] T022 Verify README release and cache guidance matches workflow behavior in README.md
- [X] T023 Verify all verification artifacts are linked from specs/002-multiarch-image-cache/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): Starts immediately.
- Foundational (Phase 2): Depends on Phase 1 and blocks all user stories.
- User Stories (Phases 3-5): Depend on Phase 2 completion.
- Polish (Phase 6): Depends on completion of selected user stories.

### User Story Dependencies

- User Story 1 (P1): Starts first after Foundational; establishes the single-tag multi-platform release path.
- User Story 2 (P2): Builds on the workflow foundation to add cache reuse and warm-build efficiency.
- User Story 3 (P3): Depends on the release workflow and cache strategy to validate runtime behavior across both platforms.

### Parallel Opportunities

- Setup: T002 and T003 can run in parallel once T001 is in place.
- Foundational: T006 and T007 can run in parallel while T008 progresses.
- User Story 1: T012 and T013 can run in parallel after the manifest publication step is defined.
- User Story 2: T015 can run in parallel with T014 once cache strategy is agreed.
- User Story 3: T019 can run in parallel with T017 and T018 after runtime contract details are stable.
- Polish: T021 can run in parallel with T022 before final documentation linkage is confirmed.

---

## Parallel Example: User Story 1

```bash
Task: "Validate release publication includes both platform variants in .github/workflows/build.yml"
Task: "Record single-tag publication evidence in specs/002-multiarch-image-cache/verification/release-manifest.md"
```

## Parallel Example: User Story 2

```bash
Task: "Enable remote cache import/export for repeated builds in .github/workflows/build.yml"
Task: "Add cache-aware local build guidance and targets in Makefile"
```

## Parallel Example: User Story 3

```bash
Task: "Document runtime verification and release-gating behavior in README.md"
Task: "Record runtime verification evidence for both platform variants in specs/002-multiarch-image-cache/verification/runtime-consistency.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup).
2. Complete Phase 2 (Foundational).
3. Complete Phase 3 (User Story 1).
4. Validate that one tag publishes both platform variants before expanding scope.

### Incremental Delivery

1. Deliver User Story 1 for single-tag multi-platform publication.
2. Add User Story 2 to reduce warm-build time with cache reuse.
3. Add User Story 3 to preserve runtime verification across platforms.
4. Finish with polish tasks and linked evidence artifacts.

### Parallel Team Strategy

1. Contributor A: Release workflow and manifest publication tasks (US1).
2. Contributor B: Cache reuse workflow and build guidance tasks (US2).
3. Contributor C: Runtime verification and documentation tasks (US3).

---

## Notes

- All tasks follow the required checklist format with IDs, labels, and explicit file paths.
- Story phases are independently testable and sequenced by priority.
- Verification artifacts are first-class deliverables for CI and review gates.
