# Install llama.cpp (prebuilt CUDA 13)

Prefer official Ubuntu **CUDA 13** prebuilt binaries. This machine has the NVIDIA driver (CUDA 13.0 reported) but **no** CUDA toolkit, `nvcc`, or `cmake`, so do not compile from source unless those tools are installed later.

## What gets installed

- Destination: `bin/llama-cpp/` (gitignored via `bin/`)
- Binaries from `llama-*-bin-ubuntu-cuda-13*-x64.tar.gz`
- CUDA runtime libraries from `cudart-llama-*-bin-ubuntu-cuda-13*-x64.tar.gz` when needed for `libcudart`

This step downloads **no GGUF** and no other model weights.

## Automated install

From the repository root:

```bash
bash scripts/install-llama-cpp.sh
```

The script:

1. Requires `curl` and `tar`
2. Walks recent `ggml-org/llama.cpp` GitHub releases (skips meta tags like `v1.0.0` that ship no binaries)
3. Downloads the newest Ubuntu x64 CUDA 13.x server bundle and matching cudart bundle
4. Extracts both into `bin/llama-cpp/`
5. Flattens `cudart-*.tar.gz` shared libraries (`libcudart.so.13`, `libcublas.so.13`, `libcublasLt.so.13`) into `bin/llama-cpp/` so `libggml-cuda.so` can resolve them
6. Prints the path to `llama-server` and runs a short help/version probe

---

## Manual install (same assets)

1. Open https://github.com/ggml-org/llama.cpp/releases
2. Download `llama-*-bin-ubuntu-cuda-13*-x64.tar.gz` and matching `cudart-llama-*-bin-ubuntu-cuda-13*-x64.tar.gz`
3. Extract both archives into `bin/llama-cpp/`
4. If `cudart` extracts into a subdirectory (e.g. `bin/llama-cpp/cudart-*/`), move all `.so*` files directly into `bin/llama-cpp/`
5. Confirm device detection:
   ```bash
   LD_LIBRARY_PATH="$PWD/bin/llama-cpp" bin/llama-cpp/llama-server --list-devices
   ```
   Verify `CUDA0:` appears in the output.

## After install

- Smoke test: `bash scripts/smoke-llama-server.sh`
- Router: see [router.md](router.md) and `scripts/start-router.sh`

## Source builds (not recommended here)

Building from source needs at least `cmake`, a C++ toolchain, and a CUDA toolkit matching the driver. Prefer prebuilt CUDA 13 until that toolchain exists.
