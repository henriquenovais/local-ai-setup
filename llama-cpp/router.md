# llama-server router mode

Run one long-lived `llama-server` process that can **replace** the loaded model. This is not millisecond hot-swap: unloading and loading a 14B GGUF on a 6GB GPU takes a normal full reload (seconds to minutes).

## Why `--models-max 1`

This workstation only has 6GB VRAM and 15 GiB RAM. Keeping a single model loaded avoids OOM and swap storms. When you want another model, the previous one is unloaded first.

## Start

```bash
bash scripts/start-router.sh
```

Defaults:

- `--models-dir <repo>/models`
- `--models-max 1`
- `--models-preset <repo>/llama-cpp/models.ini`
- `-c 32768`
- `--cache-type-k q4_0`
- `--cache-type-v q4_0`
- `--host 127.0.0.1 --port 8080`

Open the built-in Web UI at `http://127.0.0.1:8080`.

## KV Cache Quantization & Context Sizing (6GB VRAM)

For a 14B model (48 layers, 8 KV heads with GQA):
- **Full FP16 KV cache at 32k tokens:** requires **~6.0 GiB**, which completely saturates 6GB VRAM on its own and causes CUDA OOM.
- **`q4_0` KV cache at 32k tokens (`cache-type-k = q4_0`, `cache-type-v = q4_0`):** shrinks context memory to **~1.6 GiB** with negligible quality loss.
- **Layer offload tuning:** Pair `q4_0` KV cache with `n-gpu-layers = 16` for Qwen 3 14B Q4_K_M. This yields:
  - ~3.0 GiB GPU layer weights + ~1.6 GiB KV cache + ~0.5 GiB CUDA runtime overhead = **~5.1 GiB VRAM** (safely below 6.0 GiB).
  - ~6.0 GiB remaining layers in system RAM + ~3.5 GiB OS = **~9.5 GiB RAM** (well within 15.3 GiB total RAM).

## Presets

1. Copy `llama-cpp/models.ini.example` to `llama-cpp/models.ini` (done automatically by the start script if missing).
2. Tune `n-gpu-layers` and `ctx-size` per model after the first successful load.
3. `models.ini` is gitignored so local tuning stays on the machine.

## Operator tips

- Quit Handy and other GPU apps before loading.
- GGUF files must exist under `models/` (download scripts come in Setup D).
- OpenCode should keep a single base URL: `http://127.0.0.1:8080/v1`.
