# Cache Reuse Evidence

## Purpose

Capture evidence that repeated builds reuse unchanged work through cache import/export.

## Expected Commands

```sh
make build-release
make build-release
```

## Evidence Fields

- Cold-build duration
- Warm-build duration
- Cache hit evidence
- Cache miss evidence
- Steps rebuilt after changes

## Notes

- Record whether the second run reused cache layers and which steps were rebuilt.