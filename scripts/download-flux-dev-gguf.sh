#!/usr/bin/env bash
# FLUX.1 Dev low-VRAM pack into models/flux/ (gitignored via models/ + extensions).
# Not wired as an OpenCode chat model.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="$REPO_ROOT/models/flux"
mkdir -p "$DEST_DIR"

download() {
  local url="$1"
  local out="$2"
  # -f: path exists and is a regular file.
  if [[ -f "$out" ]]; then
    echo "Already present: $out"
    return 0
  fi
  echo "Downloading $(basename "$out") ..."
  # --http1.1: avoid intermittent HTTP/2 stream CANCEL (curl exit 92) on large HF files.
  # --retry 5 / --retry-all-errors: retry transient network failures, not only HTTP 5xx.
  # -C -: resume from the existing .part byte offset when present.
  # ${HF_TOKEN:+-H "Authorization: Bearer $HF_TOKEN"}: add auth header only when HF_TOKEN is set.
  curl -fL --http1.1 --retry 5 --retry-delay 2 --retry-all-errors \
    -C - \
    ${HF_TOKEN:+-H "Authorization: Bearer ${HF_TOKEN}"} \
    -o "${out}.part" \
    "$url"
  # mv -f: replace destination if a stale partial somehow shares the final name.
  mv -f "${out}.part" "$out"
}

# UNet GGUF (Q3_K_S)
download \
  "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q3_K_S.gguf" \
  "$DEST_DIR/flux1-dev-Q3_K_S.gguf"

# T5 encoder GGUF (Q3_K_S)
download \
  "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q3_K_S.gguf" \
  "$DEST_DIR/t5-v1_1-xxl-encoder-Q3_K_S.gguf"

# CLIP-L
download \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
  "$DEST_DIR/clip_l.safetensors"

# VAE (ungated mirror of the official FLUX.1-dev ae.safetensors; BFL repo is gated/401 without HF auth)
download \
  "https://huggingface.co/camenduru/FLUX.1-dev-ungated/resolve/main/ae.safetensors" \
  "$DEST_DIR/ae.safetensors"

echo "Verifying gitignore fence..."
git -C "$REPO_ROOT" check-ignore -v "$DEST_DIR/flux1-dev-Q3_K_S.gguf" || true
git -C "$REPO_ROOT" check-ignore -v "$DEST_DIR/clip_l.safetensors" || true
ls -lh "$DEST_DIR"
echo "OK: FLUX files under $DEST_DIR (use with ComfyUI --lowvram; not OpenCode chat)"
