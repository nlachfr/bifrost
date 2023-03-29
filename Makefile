GOPATH := $(PWD)/.cache
PATH := $(PATH):$(GOPATH)/bin
SHELL := env PATH=$(PATH) /bin/bash

PROTOC_GEN_GO := $(GOPATH)/bin/protoc-gen-go

PROTO := gateway/gateway.proto
GENPROTO_GO := $(PROTO:.proto=.pb.go)

.PHONY: all
all: go-genproto

$(PROTOC_GEN_GO):
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28

%.pb.go: %.proto
	protoc -I. -Ivendor/github.com/nlachfr/protocel --go_out=. --go_opt=paths=source_relative $<

.PHONY: go-genproto
go-genproto: $(PROTOC_GEN_GO) $(GENPROTO_GO)

test:
	go test -count=1 ./cmd/... ./gateway/...

.PHONY: testdata
testdata:
	find testdata/ -name '*.proto' -exec protoc --go_out=. --go_opt=paths=source_relative {} \;
	find testdata/plugin -name '*.go' -exec bash -c 'export FILE={}; go build -o $$(dirname $${FILE}) -buildmode=plugin ./$${FILE}' \;

coverage:
	go test -count=1 ./cmd/... ./gateway/... -cover -coverprofile=.cover.tmp
	grep -v .pb.go .cover.tmp > .cover
	go tool cover -func .cover