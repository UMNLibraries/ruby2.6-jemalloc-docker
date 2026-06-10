# Release Manifest Evidence

## Purpose

Capture evidence that the release workflow publishes one tag with both linux/amd64 and linux/arm64 variants.

## Expected Commands

```sh
make build-release
make verify-release
```

## Evidence Fields

- Release tag name
- Published platform variants
- Registry reference
- Verification results for both platforms

## Notes

- Record the release workflow run URL or build log excerpt here after execution.
