.PHONY: build run default enumerate-tools upstream fedora-downstream source

REPOSITORY = modularitycontainers/ruby

default: build

build:
	docker build --tag=$(REPOSITORY) .

check: build
	IMAGE_NAME=$(REPOSITORY) pytest-3 -vv ./test/test_s2i.py

test: check
