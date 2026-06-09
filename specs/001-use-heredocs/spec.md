# Feature Specification: Simplify Container Build Commands

**Feature Branch**: `[001-use-heredocs]`

**Created**: 2026-06-05

**Status**: Draft

**Input**: User description: "use here-docs in docker file to simplify run commands"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintainable Build Steps (Priority: P1)

As a maintainer, I want long container build command sequences to be grouped into readable script-style blocks so I can safely modify them without breaking line continuations or quoting.

**Why this priority**: Build command readability directly affects the speed and safety of routine maintenance.

**Independent Test**: A maintainer can update one multi-step build sequence and complete a successful image build without adjusting fragile escaping or line-continuation patterns.

**Acceptance Scenarios**:

1. **Given** a multi-step build sequence with several shell operations, **When** the maintainer updates one command, **Then** the sequence remains readable and builds successfully.
2. **Given** a command block includes environment values and conditionals, **When** the block is reviewed, **Then** each step is understandable without reconstructing escaped lines.

---

### User Story 2 - Behavioral Consistency After Refactor (Priority: P2)

As a release engineer, I want build command simplification to preserve runtime behavior so image outputs remain compatible with current Ruby and allocator expectations.

**Why this priority**: Refactoring for readability must not alter functional outcomes.

**Independent Test**: Build before and after the change produce equivalent runtime verification results for Ruby version and allocator activation.

**Acceptance Scenarios**:

1. **Given** the command simplification is applied, **When** the image is built and verified, **Then** runtime validation checks produce the same pass/fail outcomes as before.
2. **Given** existing downstream usage expectations, **When** users run the resulting image, **Then** no required invocation behavior changes are introduced unintentionally.

---

### User Story 3 - Faster Troubleshooting (Priority: P3)

As a contributor, I want grouped build command logic to be easier to debug so I can identify failing steps quickly during CI or local builds.

**Why this priority**: Faster troubleshooting reduces turnaround time for build failures.

**Independent Test**: On an induced build failure, contributor identifies the failing step from command structure and logs without reconstructing concatenated shell strings.

**Acceptance Scenarios**:

1. **Given** a build step fails, **When** logs are inspected, **Then** the failing operation can be mapped directly to a single logical step.

### Edge Cases

- What happens when a command block contains characters that are commonly misinterpreted by shell parsing?
- How does the build behave when one step in a grouped command block fails partway through execution?
- How are runtime checks preserved when command ordering is reorganized for readability?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST represent long multi-step container build command logic in a structured, multi-line form that is easier to read and edit than escaped single-line chains.
- **FR-002**: The system MUST preserve existing build outcomes and artifact behavior after command-structure simplification.
- **FR-003**: Maintainers MUST be able to modify an individual command step without rewriting unrelated command segments.
- **FR-004**: The system MUST keep command execution order explicit and reviewable.
- **FR-005**: The system MUST make failure points in grouped command logic traceable to specific steps.
- **FR-006**: The system MUST document updated build-command conventions so contributors apply the same style consistently.
- **FR-007**: The system MUST provide verification evidence that runtime expectations remain satisfied after refactoring.

### Container & Runtime Constraints *(mandatory)*

- Feature work MUST preserve Ruby 2.6 runtime compatibility unless an explicit migration decision is approved.
- Feature work affecting memory allocator behavior MUST define how jemalloc usage is verified.
- Feature work MUST define deterministic build input expectations (base image, package sources, and build args).
- Feature work MUST identify documentation updates required in README or operational guidance.

### Key Entities *(include if feature involves data)*

- **Build Command Block**: A logical grouping of sequential shell operations used during image construction, with ordered steps and failure boundaries.
- **Verification Record**: Evidence that post-change image behavior matches required runtime checks (Ruby version compatibility and allocator verification outcomes).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Contributors can correctly identify and edit a targeted build step in under 5 minutes during review exercises.
- **SC-002**: 100% of mandatory runtime verification checks pass before and after command simplification.
- **SC-003**: At least 80% of build-command changes in the first month require edits to a single logical block rather than multiple escaped lines.
- **SC-004**: Time to diagnose build command failures is reduced by at least 30% compared to the prior command structure baseline.

## Assumptions

- The current container build flow remains in scope; this feature improves command clarity rather than changing product behavior.
- Existing runtime verification checks for Ruby and allocator usage are available and remain the acceptance baseline.
- Contributors and reviewers use documented build steps from this repository when validating changes.
- No new external services or infrastructure are required for this refactor-focused feature.
