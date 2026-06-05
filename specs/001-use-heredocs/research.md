# Research Notes: Here-Doc Refactor Rules

## Decision

Use shell here-doc `RUN` blocks for multi-step Dockerfile sequences to improve readability and
reduce accidental breakage from line-continuation edits.

## Shell Safety Conventions

- Every here-doc block starts with `set -eux`.
- Keep command order identical to pre-refactor behavior.
- Include explicit step labels as comments for traceability in build logs.
- Keep cleanup commands in the same block as installation/build commands.
- Quote variable expansions where shell parsing could be ambiguous.

## Determinism Guardrails

- Do not change base images as part of this refactor.
- Do not modify versioned build args unless intentionally updating dependencies.
- Keep source URLs and archive extraction flow unchanged.

## Rejected Alternative

- Continue with long `&&` chains.
  - Rejected because review and troubleshooting are harder, especially for multi-arch CI failures.
