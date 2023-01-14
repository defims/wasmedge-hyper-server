TARGET ?= debug
RELEASE_FLAG :=
ifeq ($(TARGET),release)
RELEASE_FLAG = --release
endif

.PHONY: build
build:
	cargo build $(RELEASE_FLAG)

.PHONY: test
test: build
	wasmedge target/wasm32-wasi/$(TARGET)/wasmedge-hyper-server.wasm

.PHONY: target/wasm32-wasi/$(TARGET)/img.tar
target/wasm32-wasi/$(TARGET)/img.tar: build
	cargo build --features oci-v1-tar

.PHONY: load 
load: target/wasm32-wasi/$(TARGET)/img.tar
	sudo ctr image import --all-platforms $<

.PHONY: test-ctr
test-ctr: load
	sudo ctr run --rm --runtime=io.containerd.wasmedge.v1 ghcr.io/containerd/runwasi/wasmedge-hyper-server:latest wasmedge-hyper-server

.PHONY: test-k3s
test-k3s: load
	sudo k3s kubectl apply -f wasm.yml
