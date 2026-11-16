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
  if [[ -f "$out" ]]; then
    echo "Already present: $out"
    return 0
  fi
  echo "Downloading $(basename "$out") ..."
  curl -fL --retry 3 --retry-delay 2 -C - -o "${out}.part" "$url"
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

# VAE
download \
  "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors" \
  "$DEST_DIR/ae.safetensors"

echo "Verifying gitignore fence..."
git -C "$REPO_ROOT" check-ignore -v "$DEST_DIR/flux1-dev-Q3_K_S.gguf" || true
git -C "$REPO_ROOT" check-ignore -v "$DEST_DIR/clip_l.safetensors" || true
ls -lh "$DEST_DIR"
echo "OK: FLUX files under $DEST_DIR (use with ComfyUI --lowvram; not OpenCode chat)"
