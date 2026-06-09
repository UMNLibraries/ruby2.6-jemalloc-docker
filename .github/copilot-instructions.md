<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read specs/002-multiarch-image-cache/plan.md
<!-- SPECKIT END -->

<!-- tram0004 instructions start -->
* The purpose of this project is to build a Docker container running the latest 2.6.x Ruby
  version, with jemalloc.
* The target architecture of this a multi-architecture image supporting `linux/amd64` and
  `linux/arm64` architectures.
* The image will be built using a multistage Dockerfile that compiles OpenSSL 1.1.1w,
  jemalloc 5.3.0, and Ruby 2.6.10 from source.
* The resulting image will have a minimal runtime footprint, containing only the compiled
  Ruby binaries and necessary runtime libraries.
* The build process will be structured with shell here-doc `RUN` blocks for clarity and
  maintainability.
<!-- tram0004 instructions end -->