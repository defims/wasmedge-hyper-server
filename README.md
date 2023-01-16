# HTTP server example

## install dependencies

```bash
# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# wasmedge
curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash

# k3s
curl -sfL https://get.k3s.io | sh - 
```

## add wasmedge runtime support to containerd
edit /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl add

```yaml
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.wasmedge]
      runtime_type = "io.containerd.wasmedge.v1"
```

and restart k3s

```bash
sudo systemctl restart k3s
```

## Build

```bash
cargo build --target wasm32-wasi --release
```

## Test

```bash
# wasmedge
wasmedge target/wasm32-wasi/release/wasmedge-hyper-server.wasm
sudo curl localhost:8089

# run with make
make test
sudo curl localhost:8089

# run with ctr run
make test-ctr
sudo curl localhost:8089

# run with kubectl
make test-kubectl
sudo curl localhost:8089
```

## Problem

### ctr works fine:

```bash
# run:
make test-ctr

# got:
cargo build 
   Compiling wasmedge-hyper-server v0.1.0 (/home/ubuntu/wasmedge-hyper-server)
    Finished dev [unoptimized + debuginfo] target(s) in 0.73s
cargo build --features oci-v1-tar
   Compiling wasmedge-hyper-server v0.1.0 (/home/ubuntu/wasmedge-hyper-server)
    Finished dev [unoptimized + debuginfo] target(s) in 4.42s
sudo ctr image import --all-platforms target/wasm32-wasi/debug/img.tar
unpacking ghcr.io/containerd/runwasi/wasmedge-hyper-server:latest (sha256:c396fc7621b1f3ec8692225f2ada55455b325aba2e7c49bd17dfda17219958dc)...done
sudo ctr run --rm --net-host --runtime=io.containerd.wasmedge.v1 ghcr.io/containerd/runwasi/wasmedge-hyper-server:latest wasmedge-hyper-server
Listening on http://0.0.0.0:8089

# run curl test
sudo curl localhost:8089

# got:
Try POSTing data to /echo such as: `curl localhost:8089/echo -XPOST -d 'hello world'`
```

### nginx kubectl works either

```bash
# run
make test-nginx

# got
deployment.apps/nginx-deployment created
service/nginx-service created
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
deployment.apps "nginx-deployment" deleted
service "nginx-service" deleted
```

### wasmedge kubectl failed

```bash
# run
make test-kubectl

# got
cargo build 
   Compiling wasmedge-hyper-server v0.1.0 (/home/ubuntu/wasmedge-hyper-server)
    Finished dev [unoptimized + debuginfo] target(s) in 0.77s
cargo build --features oci-v1-tar
   Compiling wasmedge-hyper-server v0.1.0 (/home/ubuntu/wasmedge-hyper-server)
    Finished dev [unoptimized + debuginfo] target(s) in 4.57s
sudo ctr image import --all-platforms target/wasm32-wasi/debug/img.tar
unpacking ghcr.io/containerd/runwasi/wasmedge-hyper-server:latest (sha256:39b01805688ade5f3eb70ecd36409e6f8be4c8a0a655a01df05090b1dbe56559)...done
runtimeclass.node.k8s.io/wasmedge created
deployment.apps/wasmedge-deployment created
service/wasmedge-service created
curl: (7) Failed to connect to localhost port 30001 after 1 ms: Connection refused
runtimeclass.node.k8s.io "wasmedge" deleted
deployment.apps "wasmedge-deployment" deleted
service "wasmedge-service" deleted
```


