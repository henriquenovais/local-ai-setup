#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_ROOT/bin/llama-cpp"
API_URL="https://api.github.com/repos/ggml-org/llama.cpp/releases/latest"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 1
fi
if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required" >&2
  exit 1
fi

echo "Resolving latest llama.cpp release assets (Ubuntu CUDA 13 x64)..."
RELEASE_JSON="$(curl -fsSL "$API_URL")"

pick_asset() {
  local pattern="$1"
  printf '%s' "$RELEASE_JSON" | python3 -c '
import json, re, sys
pattern = sys.argv[1]
data = json.load(sys.stdin)
assets = data.get("assets") or []
matched = [a for a in assets if re.search(pattern, a.get("name", ""))]
if not matched:
    sys.stderr.write(f"No asset matched /{pattern}/\n")
    sys.exit(1)
# Prefer exact cuda-13.x x64 tarballs; take the first sorted by name for stability.
matched.sort(key=lambda a: a["name"])
print(matched[0]["browser_download_url"])
print(matched[0]["name"])
' "$pattern"
}

mapfile -t LLAMA_ASSET < <(pick_asset 'llama-.*-bin-ubuntu-cuda-13[^/]*-x64\.tar\.gz$')
mapfile -t CUDART_ASSET < <(pick_asset 'cudart-llama-.*-bin-ubuntu-cuda-13[^/]*-x64\.tar\.gz$')

LLAMA_URL="${LLAMA_ASSET[0]}"
LLAMA_NAME="${LLAMA_ASSET[1]}"
CUDART_URL="${CUDART_ASSET[0]}"
CUDART_NAME="${CUDART_ASSET[1]}"

echo "Downloading $LLAMA_NAME (no GGUF)..."
curl -fL --progress-bar -o "$TMP_DIR/$LLAMA_NAME" "$LLAMA_URL"
echo "Downloading $CUDART_NAME (no GGUF)..."
curl -fL --progress-bar -o "$TMP_DIR/$CUDART_NAME" "$CUDART_URL"

mkdir -p "$DEST"
echo "Extracting into $DEST ..."
tar -xzf "$TMP_DIR/$LLAMA_NAME" -C "$DEST"
tar -xzf "$TMP_DIR/$CUDART_NAME" -C "$DEST"

# Normalize: some archives nest a single top-level directory.
if [[ ! -x "$DEST/llama-server" ]]; then
  nested="$(find "$DEST" -maxdepth 2 -type f -name llama-server | head -n 1 || true)"
  if [[ -n "$nested" ]]; then
    nested_dir="$(dirname "$nested")"
    shopt -s dotglob nullglob
    mv "$nested_dir"/* "$DEST"/ 2>/dev/null || true
    shopt -u dotglob nullglob
  fi
fi

SERVER="$DEST/llama-server"
if [[ ! -x "$SERVER" ]]; then
  # Some builds ship llama-server in a bin/ subfolder after extract.
  SERVER="$(find "$DEST" -type f -name llama-server | head -n 1 || true)"
fi

if [[ -z "$SERVER" || ! -f "$SERVER" ]]; then
  echo "llama-server not found after extract under $DEST" >&2
  exit 1
fi

chmod +x "$SERVER" || true
echo "Installed: $SERVER"
if "$SERVER" --version >/dev/null 2>&1; then
  "$SERVER" --version
elif "$SERVER" -h >/dev/null 2>&1; then
  "$SERVER" -h | head -n 20
else
  "$SERVER" --help | head -n 20 || true
fi

echo "Install complete. Next: bash scripts/smoke-llama-server.sh"
