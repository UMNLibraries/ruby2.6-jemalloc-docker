<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Modified principles:
	- PRINCIPLE_1_NAME -> I. Reproducible Ruby 2.6 Runtime
	- PRINCIPLE_2_NAME -> II. Verified jemalloc Integration
	- PRINCIPLE_3_NAME -> III. Deterministic Container Build Inputs
	- PRINCIPLE_4_NAME -> IV. Mandatory Build and Runtime Verification
	- PRINCIPLE_5_NAME -> V. Documentation and Change Traceability
- Added sections:
	- Container and Security Constraints
	- Delivery Workflow and Quality Gates
- Removed sections:
	- None
- Templates requiring updates:
	- ✅ updated: .specify/templates/plan-template.md
	- ✅ updated: .specify/templates/spec-template.md
	- ✅ updated: .specify/templates/tasks-template.md
	- ✅ reviewed (no change required): .specify/extensions/git/commands/speckit.git.initialize.md
	- ✅ reviewed (no change required): .specify/extensions/git/commands/speckit.git.commit.md
	- ✅ reviewed (no change required): .specify/extensions/git/commands/speckit.git.feature.md
	- ✅ reviewed (no change required): .specify/extensions/git/commands/speckit.git.remote.md
	- ✅ reviewed (no change required): .specify/extensions/git/commands/speckit.git.validate.md
	- ✅ reviewed (no change required): .specify/extensions/agent-context/commands/speckit.agent-context.update.md
- Follow-up TODOs:
	- None
-->

# ruby2.6-jemalloc-docker Constitution

## Core Principles

### I. Reproducible Ruby 2.6 Runtime
All image changes MUST preserve the project goal of producing a Ruby 2.6 container with a
predictable runtime environment. Changes to Ruby version selection, build flags, or image
composition MUST be explicit in code and docs, and MUST include rationale in the change set.
Rationale: consumers rely on consistent behavior from a legacy runtime line.

### II. Verified jemalloc Integration
The built image MUST use jemalloc for Ruby execution, and each change affecting allocator,
linking, or runtime startup MUST include a verification step that demonstrates jemalloc is
active at runtime. Verification evidence MUST be scriptable and repeatable.
Rationale: allocator behavior is a core feature, not an optional optimization.

### III. Deterministic Container Build Inputs
Dockerfiles and build scripts MUST minimize non-determinism: dependency sources, package
install steps, and build arguments MUST be documented and controlled. Network-time-dependent
or implicit defaults MUST be avoided unless documented as an explicit exception.
Rationale: deterministic builds reduce breakage and simplify incident recovery.

### IV. Mandatory Build and Runtime Verification
Every change merged to main MUST pass a minimum verification gate: successful image build,
Ruby version confirmation, and allocator verification inside the built container. If a change
alters image size, startup behavior, or package set, the change MUST include impact notes.
Rationale: container artifacts require runtime validation beyond static review.

### V. Documentation and Change Traceability
User-visible behavior changes MUST update README usage/build instructions in the same change.
All non-trivial decisions (base image changes, allocator strategy changes, build flow changes)
MUST be captured in commit or PR rationale. Unexplained drift between docs and implementation
is non-compliant.
Rationale: this repository is operational infrastructure and must remain maintainable.

## Container and Security Constraints

- Container images MUST avoid embedding secrets, credentials, or private tokens.
- Package installation steps MUST clean caches and temporary build artifacts where practical.
- Base image and package upgrades MUST be reviewed for compatibility with Ruby 2.6 behavior.
- Image tags and release notes SHOULD communicate compatibility-impacting changes.

## Delivery Workflow and Quality Gates

- Pull requests MUST include:
	- what changed,
	- how Ruby 2.6 and jemalloc behavior was verified,
	- and any compatibility risks.
- Reviewers MUST reject changes that do not include reproducible verification commands/results.
- Emergency fixes may bypass non-critical polish, but MUST complete verification and
	documentation updates before release cut.

## Governance

This constitution overrides conflicting project process notes.

Amendment process:
- Propose amendments via pull request describing motivation, impact, and migration concerns.
- At least one maintainer approval is required before merge.
- Ratified amendments take effect on merge to main.

Versioning policy for this constitution:
- MAJOR: incompatible governance changes or principle removal/redefinition.
- MINOR: new principle/section or materially expanded obligations.
- PATCH: clarifications, wording, or typo fixes without semantic impact.

Compliance review expectations:
- Every PR review MUST include a constitution compliance check.
- Plan, spec, and task artifacts under `.specify/templates/` MUST remain aligned with these
	principles.

**Version**: 1.0.0 | **Ratified**: 2026-06-04 | **Last Amended**: 2026-06-04
