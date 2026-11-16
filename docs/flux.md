# FLUX.1 Dev (local, low VRAM)

FLUX.1 Dev is an **image** model. It is **not** an OpenCode chat model and is **not** loaded through `llama-server` router mode.

OpenCode may expose cloud/experimental `image_generate` providers elsewhere; this document is only the **local ComfyUI** path for 6GB VRAM.

## Quant for this GPU

Use **Q3_K_S** class weights on the RTX 3050 6GB Laptop GPU. Higher quants will OOM or thrash.

## Files (stored under `models/flux/`, gitignored)

| File | Role | Typical source |
| --- | --- | --- |
| `flux1-dev-Q3_K_S.gguf` | Diffusion UNet (GGUF) | `city96/FLUX.1-dev-gguf` |
| `t5-v1_1-xxl-encoder-Q3_K_S.gguf` | T5 text encoder (GGUF) | `city96/t5-v1_1-xxl-encoder-gguf` |
| `clip_l.safetensors` | CLIP-L | Comfy / BFL text-encoder packs |
| `ae.safetensors` | VAE | Ungated mirror (`camenduru/FLUX.1-dev-ungated`); official BFL repo is gated |

Download helper:

```bash
bash scripts/download-flux-dev-gguf.sh
```

## ComfyUI

1. Install ComfyUI and the ComfyUI-GGUF custom nodes.
2. Point or copy files into ComfyUI’s `models/diffusion_models`, `models/clip`, and `models/vae` as required by your nodes (or symlink from `models/flux/`).
3. Launch with **`--lowvram`**.
4. Workflow: Unet Loader (GGUF) + DualCLIPLoader (GGUF) + Load VAE.

## Mutual exclusion

Do **not** co-run FLUX with a loaded 14B LLM on this GPU. Stop `llama-server` (or unload the LLM) before generating images.
