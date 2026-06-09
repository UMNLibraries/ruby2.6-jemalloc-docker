# Runtime Consistency Evidence

## Verification Template

Fill this table when executing runtime checks before/after Dockerfile refactor changes.

| Check | Before | After | Status |
|------|--------|-------|--------|
| `ruby -v` reports `2.6.x` | not captured in this branch | pass (`2.6.10`) native/amd64/arm64 | pass |
| `ldd libruby` references jemalloc | not captured in this branch | pass native/amd64/arm64 | pass |
| `ldconfig -p` includes jemalloc | not captured in this branch | pass native/amd64/arm64 | pass |
| amd64 image build succeeds | not captured in this branch | pass (`make build-amd64`) | pass |
| arm64 image build succeeds | not captured in this branch | pass (`make verify-arm64`) | pass |

## Executed Commands

```sh
make build
make verify
make build-amd64
./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:amd64 linux/amd64
make verify-arm64
```

## Notes

- Use `./scripts/verify-ruby-jemalloc.sh <image> <platform>` for runtime checks.
- Record command outputs or CI links in PR notes.
