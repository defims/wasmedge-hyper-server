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
	sudo ctr run --rm --net-host --runtime=io.containerd.wasmedge.v1 ghcr.io/containerd/runwasi/wasmedge-hyper-server:latest wasmedge-hyper-server

.PHONY: test-kubectl
test-kubectl: load
	@sudo kubectl apply -f wasm.yml; \
	phase=""; \
	while [ "$$phase" != "Running" ]; do \
          phase=`sudo kubectl get pods --selector='app=wasmedge-hyper-server' -o custom-columns=STATUS:.status.phase --no-headers=true`; \
	  sleep .5; \
	done; \
	sudo curl localhost:30001; \
	sudo kubectl delete -f wasm.yml

.PHONY: test-nginx
test-nginx: 
	@sudo kubectl apply -f nginx.yml; \
	phase=""; \
	while [ "$$phase" != "Running" ]; do \
          phase=`sudo kubectl get pods --selector='app=nginx' -o custom-columns=STATUS:.status.phase --no-headers=true`; \
	  sleep .5; \
	done; \
	sudo curl localhost:30000; \
	sudo kubectl delete -f nginx.yml

