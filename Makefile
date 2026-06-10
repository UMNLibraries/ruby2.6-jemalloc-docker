usage:
	@echo "usage: make [usage|lint|build|build-amd64|build-arm64|build-release|verify|verify-amd64|verify-arm64|verify-release]"

REGISTRY ?= ghcr.io/umnlibraries/ruby2.6-jemalloc-docker
MULTIARCH_TAG ?= sha-$(shell git rev-parse --short HEAD 2>/dev/null || echo local)
MULTIARCH_PLATFORMS ?= linux/amd64,linux/arm64
MULTIARCH_CACHE_DIR ?= .buildx-cache

lint:
	pre-commit run --all-file

build:
	docker build -t ruby2.6-jemalloc:local .

build-amd64:
	docker buildx build --platform linux/amd64 --load -t ruby2.6-jemalloc:amd64 .

build-arm64:
	docker buildx build --platform linux/arm64 --load -t ruby2.6-jemalloc:arm64 .

build-release:
	docker buildx build \
	  --platform $(MULTIARCH_PLATFORMS) \
	  --cache-from type=local,src=$(MULTIARCH_CACHE_DIR) \
	  --cache-to type=local,dest=$(MULTIARCH_CACHE_DIR)-new,mode=max \
	  --push \
	  -t $(REGISTRY):$(MULTIARCH_TAG) \
	  .
	@rm -rf $(MULTIARCH_CACHE_DIR)
	@mv $(MULTIARCH_CACHE_DIR)-new $(MULTIARCH_CACHE_DIR)

verify: build
	./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:local

verify-amd64: build-amd64
	./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:amd64 linux/amd64

verify-arm64: build-arm64
	./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:arm64 linux/arm64

verify-release: build-release
	./scripts/verify-ruby-jemalloc.sh $(REGISTRY):$(MULTIARCH_TAG) linux/amd64
	./scripts/verify-ruby-jemalloc.sh $(REGISTRY):$(MULTIARCH_TAG) linux/arm64
