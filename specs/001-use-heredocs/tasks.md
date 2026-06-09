# Tasks: Simplify Dockerfile RUN Commands with Here-Docs

**Input**: Design documents from `/specs/001-use-heredocs/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: No standalone TDD suite was requested in the feature specification; runtime verification tasks are included as implementation evidence.

**Organization**: Tasks are grouped by user story to preserve independent implementation and validation.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare shared build and verification scaffolding used by all stories.

- [x] T001 Confirm pinned build args and stage comments in Dockerfile
- [x] T002 Align Make targets for local and architecture-specific verification in Makefile
- [x] T003 [P] Align direct verification script invocation contract in scripts/verify-ruby-jemalloc.sh
- [x] T004 [P] Record quickstart entry points and artifact references in specs/001-use-heredocs/quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish governance, contract, and CI guardrails required before story delivery.

**⚠️ CRITICAL**: User story implementation starts only after this phase is complete.

- [x] T005 Capture here-doc safety and determinism decisions in specs/001-use-heredocs/research.md
- [x] T006 [P] Finalize build entities and validation rules in specs/001-use-heredocs/data-model.md
- [x] T007 [P] Finalize contributor/CI interface contract in specs/001-use-heredocs/contracts/build-verification-contract.md
- [x] T008 Ensure buildx matrix, cache configuration, and verify steps align with contract in .github/workflows/build.yml
- [x] T009 Create verification evidence skeleton for US1 and US2 in specs/001-use-heredocs/verification/us1-build.md
- [x] T010 Create runtime consistency evidence skeleton in specs/001-use-heredocs/verification/runtime-consistency.md

**Checkpoint**: Foundation is ready; stories can be implemented.

---

## Phase 3: User Story 1 - Maintainable Build Steps (Priority: P1) 🎯 MVP

**Goal**: Make multi-step build sequences easy to edit by using readable here-doc blocks with explicit step order.

**Independent Test**: Update one operation inside a here-doc build block and complete a successful image build without changing unrelated lines.

### Implementation for User Story 1

- [x] T011 [US1] Refactor OpenSSL build sequence into a structured here-doc block in Dockerfile
- [x] T012 [US1] Refactor jemalloc build sequence into a structured here-doc block in Dockerfile
- [x] T013 [US1] Refactor Ruby build and runtime ldconfig sequences into structured here-doc blocks in Dockerfile
- [x] T014 [P] [US1] Add per-step traceability comments for each major operation in Dockerfile
- [x] T015 [US1] Record build verification evidence for maintainability checks in specs/001-use-heredocs/verification/us1-build.md

**Checkpoint**: User Story 1 can be demonstrated and validated on its own.

---

## Phase 4: User Story 2 - Behavioral Consistency After Refactor (Priority: P2)

**Goal**: Prove runtime behavior remains equivalent after RUN command structure changes.

**Independent Test**: Execute runtime checks pre/post refactor and confirm Ruby version and jemalloc activation outcomes are equivalent.

### Implementation for User Story 2

- [x] T016 [US2] Implement Ruby 2.6, jemalloc linkage, and linker cache assertions in scripts/verify-ruby-jemalloc.sh
- [x] T017 [US2] Wire runtime verification commands to make targets in Makefile
- [x] T018 [US2] Run runtime verification for amd64 and arm64 in .github/workflows/build.yml
- [x] T019 [P] [US2] Document runtime verification procedure and expected outcomes in README.md
- [x] T020 [US2] Capture before/after runtime consistency evidence in specs/001-use-heredocs/verification/runtime-consistency.md

**Checkpoint**: User Story 2 is independently verifiable with repeatable evidence.

---

## Phase 5: User Story 3 - Faster Troubleshooting (Priority: P3)

**Goal**: Speed up build failure diagnosis with clearer block structure and triage guidance.

**Independent Test**: Trigger a controlled failure and identify the failing operation directly from logs and troubleshooting guidance.

### Implementation for User Story 3

- [x] T021 [US3] Add CI/local triage command sequence and failure interpretation guidance in specs/001-use-heredocs/quickstart.md
- [x] T022 [P] [US3] Add build-failure troubleshooting guide mapped to step labels in README.md
- [x] T023 [P] [US3] Add contract-level failure conditions and expected operator actions in specs/001-use-heredocs/contracts/build-verification-contract.md
- [x] T024 [US3] Record troubleshooting walkthrough and outcomes in specs/001-use-heredocs/verification/polish-checks.md

**Checkpoint**: User Story 3 provides standalone troubleshooting value.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across specs, docs, workflow, and verification artifacts.

- [x] T025 [P] Re-run full verification flow and record final pass criteria in specs/001-use-heredocs/verification/polish-checks.md
- [x] T026 Verify documentation linkage among plan, research, data model, contracts, and quickstart in specs/001-use-heredocs/plan.md
- [x] T027 Verify README and workflow reflect final runtime/build behavior in README.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): Starts immediately.
- Foundational (Phase 2): Depends on Phase 1 and blocks all user stories.
- User Stories (Phases 3-5): Depend on Phase 2 completion.
- Polish (Phase 6): Depends on completion of selected user stories.

### User Story Dependencies

- User Story 1 (P1): Starts first after Foundational; delivers the MVP refactor outcome.
- User Story 2 (P2): Depends on User Story 1 command-block structure to verify behavioral equivalence.
- User Story 3 (P3): Depends on User Story 1 step labeling and benefits from User Story 2 verification context.

### Parallel Opportunities

- Setup: T003 and T004 can run in parallel after T001.
- Foundational: T006 and T007 can run in parallel while T008 progresses.
- User Story 1: T014 can run in parallel with T011-T013 once block boundaries are established.
- User Story 2: T019 can run in parallel with T016-T018.
- User Story 3: T022 and T023 can run in parallel after T021.
- Polish: T025 can run in parallel with T026 before final README/workflow alignment.

---

## Parallel Example: User Story 1

```bash
Task: "Add per-step traceability comments for each major operation in Dockerfile"
Task: "Refactor OpenSSL build sequence into a structured here-doc block in Dockerfile"
```

## Parallel Example: User Story 2

```bash
Task: "Document runtime verification procedure and expected outcomes in README.md"
Task: "Run runtime verification for amd64 and arm64 in .github/workflows/build.yml"
```

## Parallel Example: User Story 3

```bash
Task: "Add build-failure troubleshooting guide mapped to step labels in README.md"
Task: "Add contract-level failure conditions and expected operator actions in specs/001-use-heredocs/contracts/build-verification-contract.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup).
2. Complete Phase 2 (Foundational).
3. Complete Phase 3 (User Story 1).
4. Validate independent build/readability outcome before expanding scope.

### Incremental Delivery

1. Deliver User Story 1 to establish maintainable command blocks.
2. Deliver User Story 2 to prove runtime behavior consistency.
3. Deliver User Story 3 to improve troubleshooting speed.
4. Finish with cross-cutting polish and evidence consolidation.

### Parallel Team Strategy

1. Contributor A: Dockerfile refactor tasks (US1).
2. Contributor B: Verification script/workflow and evidence capture (US2).
3. Contributor C: Troubleshooting and contract documentation (US3).

---

## Notes

- All tasks follow the required checklist format with IDs, labels, and explicit file paths.
- Story phases are independently testable and sequenced by priority.
- Verification artifacts are first-class deliverables for CI and review gates.
