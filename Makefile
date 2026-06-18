usage:
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  usage          Show this help message"
	@echo "  lint           Run pre-commit linters on all files"
	@echo "  build          Build multi-arch image locally (no push)"
	@echo "  build-amd64    Build image for linux/amd64, load into local Docker"
	@echo "  build-arm64    Build image for linux/arm64, load into local Docker"
	@echo "  build-release  Build multi-arch image and push to registry"
	@echo "  verify         Build then verify Ruby + jemalloc (local tag)"
	@echo "  verify-amd64   Build then verify amd64 image"
	@echo "  verify-arm64   Build then verify arm64 image"
	@echo "  verify-release Build-release then verify both architectures"
	@echo "  push           Push latest tag to registry"
	@echo "  push-arm64     Push arm64 image to registry"
	@echo "  pull-arm64     Pull arm64 image from registry"
	@echo "  clean          Remove local build cache and images"
	@echo ""
	@echo "Variables (override with make VAR=value):"
	@echo "  REGISTRY              $(REGISTRY)"
	@echo "  MULTIARCH_TAG         $(MULTIARCH_TAG)"
	@echo "  MULTIARCH_PLATFORMS   $(MULTIARCH_PLATFORMS)"
	@echo "  MULTIARCH_CACHE_DIR   $(MULTIARCH_CACHE_DIR)"
	@echo ""

REGISTRY ?= ghcr.io/umnlibraries/ruby2.6-jemalloc
MULTIARCH_TAG ?= sha-$(shell git rev-parse --short HEAD 2>/dev/null || echo local)
MULTIARCH_PLATFORMS ?= linux/amd64,linux/arm64
MULTIARCH_CACHE_DIR ?= .buildx-cache

clean:
	-rm -rf .buildx-cache .buildx-cache-new
	-docker rmi --force ruby2.6-jemalloc:local

lint:
	pre-commit run --all-file

build:
	docker build --no-cache --progress=plain --platform "$(MULTIARCH_PLATFORMS)" --tag $(REGISTRY):latest .

push:
	docker push $(REGISTRY):latest

build-amd64:
	docker buildx build --platform linux/amd64 --load -t ruby2.6-jemalloc:amd64 .

build-arm64:
	docker buildx build --platform linux/arm64 --load -t ruby2.6-jemalloc:arm64 .

push-arm64:
	docker push --platform linux/arm64 $(REGISTRY):latest

pull-arm64:
	docker pull --platform linux/arm64 $(REGISTRY):latest

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
