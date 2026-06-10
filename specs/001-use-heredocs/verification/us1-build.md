# US1 Build Verification

## Run Date

- 2026-06-09

## Commands

```sh
docker build -t ruby2.6-jemalloc:us1 .
docker build -t ruby2.6-jemalloc:local .
```

## Result

- PASS
- Build completed successfully with refactored here-doc RUN blocks.
- Core build sections validated as here-doc blocks with ordered, labeled steps:
  - builder dependencies
  - OpenSSL build
  - jemalloc build
  - Ruby build
  - runtime ldconfig setup

## Notes

- Validate that all major build sections now use here-doc style.
- Confirm build completes without changing dependency versions.
- Pinned versions confirmed during run: Ruby 2.6.10, OpenSSL 1.1.1w, jemalloc 5.3.0.
