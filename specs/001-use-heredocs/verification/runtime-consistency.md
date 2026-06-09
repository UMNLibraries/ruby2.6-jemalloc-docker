# Runtime Consistency Evidence

## Verification Template

Fill this table when executing runtime checks before/after Dockerfile refactor changes.

| Check | Before | After | Status |
| ----- | ------ | ----- | ------ |
| `ruby -v` reports `2.6.x` | baseline requirement defined | pass (`2.6.10`) native/amd64/arm64 | pass |
| `ldd libruby` references jemalloc | baseline requirement defined | pass native/amd64/arm64 | pass |
| `ldconfig -p` includes jemalloc | baseline requirement defined | pass native/amd64/arm64 | pass |
| amd64 image build succeeds | baseline requirement defined | pass (`make build-amd64`) | pass |
| arm64 image build succeeds | baseline requirement defined | pass (`make verify-arm64`) | pass |

## Executed Commands

```sh
make build
make verify
make build-amd64
./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:amd64 linux/amd64
make verify-arm64
```

## Run Date

- 2026-06-09

## Outcome Summary

- Native verification passed (`ruby2.6-jemalloc:local`).
- amd64 verification passed (`ruby2.6-jemalloc:amd64`).
- arm64 verification passed (`ruby2.6-jemalloc:arm64`).

## Notes

- Use `./scripts/verify-ruby-jemalloc.sh <image> <platform>` for runtime checks.
- Record command outputs or CI links in PR notes.
