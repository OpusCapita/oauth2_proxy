# include .env
BINARY := oauth2_proxy
VERSION := $(shell git describe --always --dirty --tags 2>/dev/null || echo "undefined")
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GO := go
.NOTPARALLEL:

.PHONY: all
all: dep lint $(BINARY)

.PHONY: clean
clean:
	rm -rf release
	rm -f $(BINARY)

.PHONY: distclean
distclean: clean
	rm -rf vendor

.PHONY: lint
lint:
	$(GOMETALINTER) --vendor --disable-all \
		--enable=vet \
		--enable=vetshadow \
		--enable=golint \
		--enable=ineffassign \
		--enable=goconst \
		--enable=deadcode \
		--enable=gofmt \
		--enable=goimports \
		--deadline=120s \
		--tests ./...

.PHONY: dep
dep:
	$(DEP) ensure --vendor-only

.PHONY: build
build: clean $(BINARY)

$(BINARY):
	CGO_ENABLED=0 $(GO) build -a -installsuffix cgo -ldflags="-X main.VERSION=${VERSION}" -o $@ github.com/OpusCapita/oauth2_proxy

.PHONY: docker
docker:
	docker build -f Dockerfile -t opuscapita/oauth2-proxy:${BRANCH} .

# .PHONY: docker-all
# docker-all: docker
# 	docker build -f Dockerfile -t opuscapita/oauth2-proxy:latest-amd64 .
# 	docker build -f Dockerfile -t opuscapita/oauth2-proxy:${VERSION} .
# 	docker build -f Dockerfile -t opuscapita/oauth2-proxy:${VERSION}-amd64 .
# 	docker build -f Dockerfile.arm64 -t opuscapita/oauth2-proxy:latest-arm64 .
# 	docker build -f Dockerfile.arm64 -t opuscapita/oauth2-proxy:${VERSION}-arm64 .
# 	docker build -f Dockerfile.armv6 -t opuscapita/oauth2-proxy:latest-armv6 .
# 	docker build -f Dockerfile.armv6 -t opuscapita/oauth2-proxy:${VERSION}-armv6 .

.PHONY: docker-push
docker-push:
	docker push opuscapita/oauth2-proxy:${BRANCH}

# .PHONY: docker-push-all
# docker-push-all: docker-push
# 	docker push opuscapita/oauth2-proxy:latest-amd64
# 	docker push opuscapita/oauth2-proxy:${VERSION}
# 	docker push opuscapita/oauth2-proxy:${VERSION}-amd64
# 	docker push opuscapita/oauth2-proxy:latest-arm64
# 	docker push opuscapita/oauth2-proxy:${VERSION}-arm64
# 	docker push opuscapita/oauth2-proxy:latest-armv6
# 	docker push opuscapita/oauth2-proxy:${VERSION}-armv6

.PHONY: test
test: dep lint
	$(GO) test -v -race ./...

# .PHONY: release
# release: lint test
# 	mkdir release
# 	mkdir release/$(BINARY)-$(VERSION).darwin-amd64.$(GO_VERSION)
# 	mkdir release/$(BINARY)-$(VERSION).linux-amd64.$(GO_VERSION)
# 	mkdir release/$(BINARY)-$(VERSION).linux-arm64.$(GO_VERSION)
# 	mkdir release/$(BINARY)-$(VERSION).linux-armv6.$(GO_VERSION)
# 	mkdir release/$(BINARY)-$(VERSION).windows-amd64.$(GO_VERSION)
# 	GOOS=darwin GOARCH=amd64 go build -ldflags="-X main.VERSION=${VERSION}" \
# 		-o release/$(BINARY)-$(VERSION).darwin-amd64.$(GO_VERSION)/$(BINARY) github.com/OpusCapita/oauth2_proxy
# 	GOOS=linux GOARCH=amd64 go build -ldflags="-X main.VERSION=${VERSION}" \
# 		-o release/$(BINARY)-$(VERSION).linux-amd64.$(GO_VERSION)/$(BINARY) github.com/OpusCapita/oauth2_proxy
# 	GOOS=linux GOARCH=arm64 go build -ldflags="-X main.VERSION=${VERSION}" \
# 		-o release/$(BINARY)-$(VERSION).linux-arm64.$(GO_VERSION)/$(BINARY) github.com/OpusCapita/oauth2_proxy
# 	GOOS=linux GOARCH=arm GOARM=6 go build -ldflags="-X main.VERSION=${VERSION}" \
# 		-o release/$(BINARY)-$(VERSION).linux-armv6.$(GO_VERSION)/$(BINARY) github.com/OpusCapita/oauth2_proxy
# 	GOOS=windows GOARCH=amd64 go build -ldflags="-X main.VERSION=${VERSION}" \
# 		-o release/$(BINARY)-$(VERSION).windows-amd64.$(GO_VERSION)/$(BINARY) github.com/OpusCapita/oauth2_proxy
# 	shasum -a 256 release/$(BINARY)-$(VERSION).darwin-amd64.$(GO_VERSION)/$(BINARY) > release/$(BINARY)-$(VERSION).darwin-amd64-sha256sum.txt
# 	shasum -a 256 release/$(BINARY)-$(VERSION).linux-amd64.$(GO_VERSION)/$(BINARY) > release/$(BINARY)-$(VERSION).linux-amd64-sha256sum.txt
# 	shasum -a 256 release/$(BINARY)-$(VERSION).linux-arm64.$(GO_VERSION)/$(BINARY) > release/$(BINARY)-$(VERSION).linux-arm64-sha256sum.txt
# 	shasum -a 256 release/$(BINARY)-$(VERSION).linux-armv6.$(GO_VERSION)/$(BINARY) > release/$(BINARY)-$(VERSION).linux-armv6-sha256sum.txt
# 	shasum -a 256 release/$(BINARY)-$(VERSION).windows-amd64.$(GO_VERSION)/$(BINARY) > release/$(BINARY)-$(VERSION).windows-amd64-sha256sum.txt
# 	tar -C release -czvf release/$(BINARY)-$(VERSION).darwin-amd64.$(GO_VERSION).tar.gz $(BINARY)-$(VERSION).darwin-amd64.$(GO_VERSION)
# 	tar -C release -czvf release/$(BINARY)-$(VERSION).linux-amd64.$(GO_VERSION).tar.gz $(BINARY)-$(VERSION).linux-amd64.$(GO_VERSION)
# 	tar -C release -czvf release/$(BINARY)-$(VERSION).linux-arm64.$(GO_VERSION).tar.gz $(BINARY)-$(VERSION).linux-arm64.$(GO_VERSION)
# 	tar -C release -czvf release/$(BINARY)-$(VERSION).linux-armv6.$(GO_VERSION).tar.gz $(BINARY)-$(VERSION).linux-armv6.$(GO_VERSION)
# 	tar -C release -czvf release/$(BINARY)-$(VERSION).windows-amd64.$(GO_VERSION).tar.gz $(BINARY)-$(VERSION).windows-amd64.$(GO_VERSION)
