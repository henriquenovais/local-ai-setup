# local-ai-setup

Recipes and scripts for running local LLMs on this workstation with llama.cpp, then wiring them into OpenCode. Model weights live on disk under this repo but are never committed.

## Purpose

Provide a reproducible, weight-safe setup for:

- llama.cpp `llama-server` in router mode (one model loaded at a time)
- OpenCode as an OpenAI-compatible client of that server
- Optional FLUX.1 Dev notes via ComfyUI (separate from chat models)

## Hardware summary

See [docs/hardware.md](docs/hardware.md). Short form: RTX 3050 Laptop 6GB, 15 GiB RAM, CUDA 13 driver — 14B Q4 models need hybrid GPU+RAM offload; run only one heavy model at a time.

## Directory map

| Path | Role |
| --- | --- |
| `docs/` | Hardware, checklists, verification, download notes |
| `llama-cpp/` | Install and router documentation / examples |
| `scripts/` | Install, start, smoke, and (later) download helpers |
| `opencode/` | Example provider config (no secrets) |
| `models/` | GGUF / FLUX weights only (gitignored except `.gitkeep`) |
| `bin/` | Downloaded llama.cpp binaries (gitignored) |

Full contract: [docs/directory-layout.md](docs/directory-layout.md).

## Safety

- `.gitignore` fences `models/`, weight extensions (`*.gguf`, `*.safetensors`, …), `bin/`, caches, and local secrets.
- `.githooks/pre-commit` rejects any staged file over **50 MiB**. Enable with `bash scripts/enable-git-hooks.sh`.
- After downloading weights, do **not** run `git add .`. Use [docs/commit-checklist.md](docs/commit-checklist.md).

## Workflow

1. Install prebuilt CUDA `llama-server` into `bin/` (`scripts/install-llama-cpp.sh`, see `llama-cpp/install.md`).
2. Start router mode with `--models-max 1` (`scripts/start-router.sh`).
3. Load **one** model (Web UI at `http://127.0.0.1:8080` or API). To try another model, unload/replace — expect a full reload (seconds to minutes), not a millisecond hot-swap.
4. Point OpenCode at `http://127.0.0.1:8080/v1` using the example under `opencode/`.

## OpenCode

Example provider block: [opencode/provider.llamacpp.jsonc.example](opencode/provider.llamacpp.jsonc.example). Merge into `~/.config/opencode/opencode.jsonc` manually. Never commit live API keys into this repository. Verification: [docs/verify-opencode.md](docs/verify-opencode.md).

## Models

Download weights **last**, into `models/`, with the scripts under `scripts/` and notes in [docs/download-models.md](docs/download-models.md). Confirm `git check-ignore -v` on every weight file before committing anything else.

Planned LLM files:

- `models/qwen2.5-coder-14b-instruct-q4_k_m.gguf`
- `models/qwen3-14b-q4_k_m.gguf`

## FLUX

FLUX.1 Dev is an image model, not a llama.cpp chat model. Use ComfyUI with a low-VRAM GGUF path. See [docs/flux.md](docs/flux.md). Do not co-run FLUX with a loaded 14B LLM on 6GB VRAM.

## Token / resume note

Implementation order is docs-first: **Setup A–C** (documentation and easy configuration) before **Setup D** (model downloads). If a session stops mid-way, finish from the docs in this repo without re-deriving the design.
