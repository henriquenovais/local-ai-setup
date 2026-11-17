# Verify llama.cpp install

Run these checks in order. Model weights are **not** required for steps 1–2.

## 1. Install prebuilt binaries

```bash
bash scripts/install-llama-cpp.sh
```

Expect `llama-server` under `bin/llama-cpp/` (gitignored).

## 2. Smoke test (binary + router flags + CUDA acceleration)

```bash
bash scripts/smoke-llama-server.sh
```

Expect exit code `0`, help text mentioning `models-dir` or `models-max`, and a confirmed CUDA device:
```text
Available devices:
  CUDA0: NVIDIA GeForce RTX 3050 6GB Laptop GPU (... MiB free)
OK: CUDA acceleration verified
```

Exit code `1` means either router flags are missing or CUDA devices were not found (check `libggml-cuda.so` linking).  
Exit code `2` means the binary is missing — run the install script first.

## 3. Start router (after GGUFs exist)

```bash
bash scripts/start-router.sh
```

In another terminal:

```bash
curl -s http://127.0.0.1:8080/v1/models
```

Expect JSON listing discovered models once weights are present under `models/`.

## 4. Web UI

Open `http://127.0.0.1:8080` and confirm the model selector appears. Keep `--models-max 1` behavior: only one model loaded.
