
.PHONY: build
build:
	docker build . -t elevate

up: build
	./scripts/elevate-test-setup.sh apply

down: build
	./scripts/elevate-test-setup.sh destroy