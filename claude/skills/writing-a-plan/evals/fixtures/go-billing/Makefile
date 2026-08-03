.PHONY: test test-billing lint build gen-api

test:
	go test ./...

test-billing:
	go test ./internal/billing/...

lint:
	golangci-lint run ./...

build:
	go build ./...

gen-api:
	oapi-codegen -config internal/billing/api/v1/cfg.yaml internal/billing/api/v1/openapi.yaml
