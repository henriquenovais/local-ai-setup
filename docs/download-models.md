# Download models

Weights go under `models/` and are **gitignored**. After every download:

```bash
git check-ignore -v models/<file>
git status
```

Confirm the weight is ignored and not staged. Never `git add .` immediately after a download.

## Qwen2.5-Coder 14B Instruct (Q4_K_M)

```bash
bash scripts/download-qwen25-coder-14b.sh
```

- Source: `bartowski/Qwen2.5-Coder-14B-Instruct-GGUF`
- Remote file: `Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf` (~9 GiB)
- Local path: `models/qwen2.5-coder-14b-instruct-q4_k_m.gguf`

## Qwen3 14B (Q4_K_M)

```bash
bash scripts/download-qwen3-14b.sh
```

- Source: `bartowski/Qwen_Qwen3-14B-GGUF`
- Remote file: `Qwen_Qwen3-14B-Q4_K_M.gguf` (~9 GiB)
- Local path: `models/qwen3-14b-q4_k_m.gguf`

## Gemma 4 12B (Q4_K_M)

```bash
bash scripts/download-gemma4-12b.sh
```

- Source: `unsloth/gemma-4-12b-it-GGUF`
- Remote file: `gemma-4-12b-it-Q4_K_M.gguf` (~7.1 GiB)
- Local path: `models/gemma-4-12b-it-q4_k_m.gguf`
- Native 256k context window (`ctx-size = 262144`) with `q4_0` KV cache (~1.27 GiB cache footprint)

## FLUX.1 Dev

```bash
bash scripts/download-flux-dev-gguf.sh
```

Writes Q3_K_S UNet/T5 plus `clip_l.safetensors` and `ae.safetensors` under `models/flux/`. FLUX is **not** an OpenCode chat model — see [flux.md](flux.md) for ComfyUI `--lowvram` usage.
