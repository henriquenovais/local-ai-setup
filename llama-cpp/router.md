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
- `-c 8192`
- `--host 127.0.0.1 --port 8080`

Open the built-in Web UI at `http://127.0.0.1:8080`.

## Presets

1. Copy `llama-cpp/models.ini.example` to `llama-cpp/models.ini` (done automatically by the start script if missing).
2. Tune `n-gpu-layers` and `ctx-size` per model after the first successful load.
3. `models.ini` is gitignored so local tuning stays on the machine.

## Operator tips

- Quit Handy and other GPU apps before loading.
- GGUF files must exist under `models/` (download scripts come in Setup D).
- OpenCode should keep a single base URL: `http://127.0.0.1:8080/v1`.
