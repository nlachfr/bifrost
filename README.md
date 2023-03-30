<div align="center">
<h1>bifrost</h1>
<p>A protobuf router and reverse proxy for services, with input validation capabilities</p>
<a href="https://coveralls.io/github/nlachfr/bifrost?branch=main"><img src="https://coveralls.io/repos/nlachfr/bifrost/badge.svg?branch=main&service=github"/></a>
<a href="https://goreportcard.com/badge/github.com/nlachfr/bifrost"><img src="https://goreportcard.com/badge/github.com/nlachfr/bifrost"/></a>
<a href="https://img.shields.io/github/license/nlachfr/bifrost"><img src="https://img.shields.io/github/license/nlachfr/bifrost"></a>
</div>

## About

*This project is still in alpha: APIs should be considered unstable and likely to change.*

Bifrost is a reflective protobuf router and reverse proxy. It uses your protobuf definitions for dynamically generating the gateway and is able to check input based on user-defined rules (see [protoc-gen-cel-validate](https://github.com/nlachfr/protoc-gen-cel-validate) for more details regarding rules).

It features :

- `gRPC`, `gRPC-web` and `connect` protocols (binding and proxying)
- [protoc-gen-cel-validate](https://github.com/nlachfr/protoc-gen-cel-validate) validation rules
- supports Go plugin for loading your custom rules

## Installation

For installing **bifrost**, you can simply run the `go install`:

```shell
$ go install github.com/nlachfr/bifrost/cmd/bifrost
```

The binary will be placed in your $GOBIN location.

## Configuration file

In order to use the gateway, you must provided a configuration file. It will allows you to :
- define listening address and upstreams
- specify proto files location
- configure validation

All the configuration fields are specified in the [`bifrost.gateway.Configuration`](./gateway/gateway.proto) message specification.
## Example

1. Create your configuration file

```yml
servers:
  - listen:
      - 127.0.0.1:8888
    upstreams:
      '*':
        address: https://demo.connect.build    
        protocol: grpc
files:
  sources:
    - proto/*.proto
  imports:
    - "."
validate:
  rule:
    servicerules:
      buf.connect.demo.eliza.v1.ElizaService:
        rule:
          programs:
            - expr: 'attribute_context.request.headers["ok"] == "ok"'      
      connect.ping.v1.PingService:
        rule:
          programs:
            - expr: 'attribute_context.request.headers["ok"] == "ok"'
```

2. Call bifrost with your newly created configuration

```bash
$ bifrost -config ./config.yml
```