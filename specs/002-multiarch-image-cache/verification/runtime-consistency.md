# Runtime Consistency Evidence

## Purpose

Capture evidence that runtime verification passes for both platform variants after the release workflow changes.

## Expected Commands

```sh
make verify-release
```

## Evidence Fields

- Release tag reference
- amd64 verification result
- arm64 verification result
- Ruby version check result
- jemalloc linkage result
- ldconfig visibility result

## Notes

- Record the release run URL and verification output for both platforms here after execution.
