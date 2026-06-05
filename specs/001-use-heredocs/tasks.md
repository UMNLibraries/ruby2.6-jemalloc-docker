# Tasks: Simplify Dockerfile RUN Commands with Here-Docs

**Input**: Design documents from `/specs/001-use-heredocs/`

**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Tests**: No separate TDD test suite was explicitly requested. Verification tasks are included as build/runtime validation steps.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create shared verification and execution scaffolding for this refactor.

- [x] T001 Create runtime verification script scaffold in scripts/verify-ruby-jemalloc.sh
- [x] T002 Add make targets for build and verification flow in Makefile
- [x] T003 [P] Create feature quickstart verification doc in specs/001-use-heredocs/quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish baseline rules and CI guardrails required by all user stories.

**⚠️ CRITICAL**: No user story work should begin until this phase is complete.

- [x] T004 Document here-doc style and shell safety conventions in specs/001-use-heredocs/research.md
- [x] T005 [P] Add CI matrix scaffold for linux/amd64 and linux/arm64 builds in .github/workflows/build.yml
- [x] T006 [P] Add deterministic build-input notes and validation steps in specs/001-use-heredocs/quickstart.md
- [x] T007 Add verification evidence template for consistency checks in specs/001-use-heredocs/verification/runtime-consistency.md

**Checkpoint**: Foundation ready; story work can begin.

---

## Phase 3: User Story 1 - Maintainable Build Steps (Priority: P1) 🎯 MVP

**Goal**: Refactor long Dockerfile command chains into readable here-doc blocks while preserving command order.

**Independent Test**: Modify one build step in a here-doc block, run docker build, and confirm the image builds successfully without line-continuation rewrites.

### Implementation for User Story 1

- [x] T008 [US1] Refactor OpenSSL build command sequence to here-doc format in Dockerfile
- [x] T009 [US1] Refactor jemalloc build command sequence to here-doc format in Dockerfile
- [x] T010 [US1] Refactor Ruby build command sequence to here-doc format in Dockerfile
- [x] T011 [US1] Refactor runtime ldconfig configuration step to readable multi-line form in Dockerfile
- [x] T012 [US1] Capture US1 build verification commands and results in specs/001-use-heredocs/verification/us1-build.md

**Checkpoint**: User Story 1 is independently functional and demonstrable.

---

## Phase 4: User Story 2 - Behavioral Consistency After Refactor (Priority: P2)

**Goal**: Prove runtime behavior remains equivalent after RUN command refactoring.

**Independent Test**: Run the same runtime checks before/after refactor and confirm Ruby version and jemalloc validation results remain equivalent.

### Implementation for User Story 2

- [x] T013 [US2] Implement Ruby/jemalloc runtime verification commands in scripts/verify-ruby-jemalloc.sh
- [x] T014 [US2] Document runtime verification procedure and expected outputs in README.md
- [x] T015 [US2] Execute and record before/after runtime consistency evidence in specs/001-use-heredocs/verification/runtime-consistency.md
- [x] T016 [US2] Add CI runtime verification execution step for both target architectures in .github/workflows/build.yml

**Checkpoint**: User Story 2 is independently verifiable with documented runtime consistency evidence.

---

## Phase 5: User Story 3 - Faster Troubleshooting (Priority: P3)

**Goal**: Make build failures easier to localize and triage through better command structure and guidance.

**Independent Test**: Trigger a controlled failure in one build block and identify the failing step directly from logs and troubleshooting guidance.

### Implementation for User Story 3

- [x] T017 [US3] Add explicit step labels/comments inside here-doc build blocks in Dockerfile
- [x] T018 [P] [US3] Add build-failure troubleshooting guide for here-doc blocks in README.md
- [x] T019 [P] [US3] Add CI/local triage command checklist in specs/001-use-heredocs/quickstart.md

**Checkpoint**: User Story 3 provides standalone troubleshooting value.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Complete final validation and documentation alignment across stories.

- [x] T020 [P] Run repository checks and record outcomes in specs/001-use-heredocs/verification/polish-checks.md
- [x] T021 Verify documentation alignment with final Dockerfile behavior in README.md
- [x] T022 Verify all verification artifacts are present and linked in specs/001-use-heredocs/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): No dependencies.
- Foundational (Phase 2): Depends on Setup completion.
- User Stories (Phases 3-5): Depend on Foundational completion.
- Polish (Phase 6): Depends on completion of all selected user stories.

### User Story Dependencies

- User Story 1 (P1): Starts first after Foundational; establishes primary Dockerfile refactor.
- User Story 2 (P2): Depends on User Story 1 refactor output for before/after behavior verification.
- User Story 3 (P3): Depends on User Story 1 structure; can overlap late with User Story 2 documentation tasks.

### Within Each User Story

- Update core implementation first.
- Run and capture verification evidence next.
- Update docs/guidance last.

### Parallel Opportunities

- T003 can run in parallel with T001-T002.
- T005 and T006 can run in parallel in Phase 2.
- T018 and T019 can run in parallel in User Story 3.
- T020 can run in parallel with final doc-alignment work.

---

## Parallel Example: User Story 3

```bash
# Parallel documentation and triage updates after Dockerfile labels are added:
Task: "Add build-failure troubleshooting guide for here-doc blocks in README.md"
Task: "Add CI/local triage command checklist in specs/001-use-heredocs/quickstart.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup).
2. Complete Phase 2 (Foundational).
3. Complete Phase 3 (User Story 1).
4. Validate Docker image build and readability improvements.

### Incremental Delivery

1. Deliver User Story 1 for maintainability.
2. Add User Story 2 runtime equivalence evidence.
3. Add User Story 3 troubleshooting improvements.
4. Finalize Polish phase for release readiness.

### Parallel Team Strategy

1. One contributor refactors Dockerfile command blocks (US1).
2. Another contributor prepares verification docs/scripts once structure stabilizes (US2).
3. A third contributor improves troubleshooting docs and triage flow (US3).

---

## Notes

- Every task uses explicit file paths and actionable outcomes.
- Story labels map implementation work directly to user stories for traceability.
- Verification artifacts are treated as first-class deliverables for CI and review.
