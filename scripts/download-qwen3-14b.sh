#!/usr/bin/env bash
# Source: bartowski/Qwen_Qwen3-14B-GGUF
# Remote: Qwen_Qwen3-14B-Q4_K_M.gguf
# Local:  models/qwen3-14b-q4_k_m.gguf
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_DIR="$REPO_ROOT/models"
REMOTE_REPO="bartowski/Qwen_Qwen3-14B-GGUF"
REMOTE_FILE="Qwen_Qwen3-14B-Q4_K_M.gguf"
LOCAL_FILE="qwen3-14b-q4_k_m.gguf"
DEST="$MODELS_DIR/$LOCAL_FILE"
HF_URL="https://huggingface.co/${REMOTE_REPO}/resolve/main/${REMOTE_FILE}"

mkdir -p "$MODELS_DIR"

hf_works() {
  command -v hf >/dev/null 2>&1 || return 1
  hf --help >/dev/null 2>&1
}

if [[ -f "$DEST" ]]; then
  echo "Already present: $DEST"
else
  if hf_works; then
    hf download "$REMOTE_REPO" "$REMOTE_FILE" --local-dir "$MODELS_DIR"
    DOWNLOADED="$MODELS_DIR/$REMOTE_FILE"
    if [[ -f "$DOWNLOADED" && "$DOWNLOADED" != "$DEST" ]]; then
      mv -f "$DOWNLOADED" "$DEST"
    fi
  else
    echo "hf unavailable; downloading via curl (no GGUF commit)..."
    curl -fL --retry 3 --retry-delay 2 -C - -o "$DEST.part" "$HF_URL"
    mv -f "$DEST.part" "$DEST"
  fi
fi

if [[ ! -f "$DEST" ]]; then
  echo "Download failed: missing $DEST" >&2
  exit 1
fi

if ! git -C "$REPO_ROOT" check-ignore -q "$DEST"; then
  echo "ERROR: $DEST is not gitignored" >&2
  exit 1
fi

git -C "$REPO_ROOT" check-ignore -v "$DEST"
echo "OK: $DEST"
ls -lh "$DEST"
