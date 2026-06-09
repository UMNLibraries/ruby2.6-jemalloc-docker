usage:
	@echo "usage: make [usage|lint|build|build-amd64|build-arm64|verify|verify-amd64|verify-arm64]"

lint:
	pre-commit run --all-file

build:
	docker build -t ruby2.6-jemalloc:local .

build-amd64:
	docker buildx build --platform linux/amd64 --load -t ruby2.6-jemalloc:amd64 .

build-arm64:
	docker buildx build --platform linux/arm64 --load -t ruby2.6-jemalloc:arm64 .

verify: build
	./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:local

verify-amd64: build-amd64
	./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:amd64 linux/amd64

verify-arm64: build-arm64
	./scripts/verify-ruby-jemalloc.sh ruby2.6-jemalloc:arm64 linux/arm64
