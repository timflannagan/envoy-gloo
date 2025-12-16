VERSION ?= $(COMMIT_SHA)
RELEASE := "false"
ifneq ($(TAGGED_VERSION),)
        VERSION := $(shell echo $(TAGGED_VERSION) | cut -c 2-)
        RELEASE := "true"
endif

ifeq ($(REGISTRY),) # Set quay.io/solo-io as default if REGISTRY is unset
        REGISTRY := quay.io/solo-io
endif

.PHONY: docker-release
docker-release:
	cd ci && docker build -t $(REGISTRY)/envoy-gloo:$(VERSION) . && docker push $(REGISTRY)/envoy-gloo:$(VERSION)

#----------------------------------------------------------------------------------
# Multi-arch Builds
#----------------------------------------------------------------------------------
# For multi-arch releases, use the GitHub Actions workflow (release-multiarch.yaml)
# or run this target locally with both architecture binaries present in ci/

.PHONY: docker-build-multiarch
docker-build-multiarch:
	docker buildx create --name envoy-multiarch-builder --use 2>/dev/null || docker buildx use envoy-multiarch-builder
	cd ci && docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t $(REGISTRY)/envoy-gloo:$(VERSION) \
		--push \
		.

gengo:
	./ci/gen_go.sh
	cd go; go mod tidy
	cd go; go build ./...

check-gencode:
	touch SOURCE_VERSION
	CHECK=1 ./ci/gen_go.sh
	rm SOURCE_VERSION