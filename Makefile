usage:
	@echo "usage: make [usage|lint]"

lint:
	pre-commit run --all-file
