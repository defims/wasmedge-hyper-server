# HTTP server example

## Build

```bash
cargo build --target wasm32-wasi --release
```

## Run

```bash
wasmedge target/wasm32-wasi/release/wasmedge-hyper-server.wasm
```

or use make

```bash
make test
```

or test ctr run

```bash
make test-ctr
```

or test k3s

```bash
make test-k3s
```

## Test

Run the following from another terminal.

```bash
$ curl http://localhost:8080/echo -X POST -d "WasmEdge"
WasmEdge
```

## test

