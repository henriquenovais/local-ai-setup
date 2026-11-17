#!/usr/bin/env bash
# ^ Shebang: Uses /usr/bin/env to locate bash from $PATH for portability.

# Enable Bash Strict Mode (fail-fast error handling):
# -e: Exit immediately if any command returns a non-zero exit status.
# -u: Exit immediately if an undefined/uninitialized variable is referenced.
# -o pipefail: Pipeline fails if any command in the chain fails, not just the last.
set -euo pipefail

# ${BASH_SOURCE[0]} is this script's path; dirname + /.. resolves the repo root.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_ROOT/bin/llama-cpp"
# GitHub Releases list (not /latest): a "latest" tag may be a meta release with no binaries.
RELEASES_URL="https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=30"
TMP_DIR="$(mktemp -d)"
# trap EXIT: remove the temp dir whether the script succeeds or fails.
trap 'rm -rf "$TMP_DIR"' EXIT

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 1
fi
if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required" >&2
  exit 1
fi

echo "Resolving newest llama.cpp release with Ubuntu CUDA 13 x64 assets..."
RELEASES_JSON="$(curl -fsSL "$RELEASES_URL")"

# Prefer llama + cudart Ubuntu CUDA 13.x x64 tarballs from the newest matching release.
# Prints four lines: llama_url, llama_name, cudart_url, cudart_name.
mapfile -t ASSET_LINES < <(printf '%s' "$RELEASES_JSON" | python3 -c '
import json, re, sys

# ^llama- avoids matching cudart-llama-* (which also contains the substring llama-).
llama_re = re.compile(r"^llama-.*-bin-ubuntu-cuda-13[^/]*-x64\.tar\.gz$")
cudart_re = re.compile(r"^cudart-llama-.*-bin-ubuntu-cuda-13[^/]*-x64\.tar\.gz$")

releases = json.load(sys.stdin)
for release in releases:
    assets = release.get("assets") or []
    llama = sorted(
        [a for a in assets if llama_re.search(a.get("name", ""))],
        key=lambda a: a["name"],
    )
    cudart = sorted(
        [a for a in assets if cudart_re.search(a.get("name", ""))],
        key=lambda a: a["name"],
    )
    if llama and cudart:
        tag = release.get("tag_name", "?")
        # Human-readable progress on stderr; machine lines on stdout.
        print(f"Using release {tag}", file=sys.stderr)
        print(llama[0]["browser_download_url"])
        print(llama[0]["name"])
        print(cudart[0]["browser_download_url"])
        print(cudart[0]["name"])
        sys.exit(0)

sys.stderr.write("No release in the first page had Ubuntu CUDA 13 x64 llama+cudart assets\n")
sys.exit(1)
')

# ${#ARRAY[@]} is the element count; require exactly four lines from the picker.
if [[ "${#ASSET_LINES[@]}" -ne 4 ]]; then
  echo "Failed to resolve llama + cudart download URLs" >&2
  exit 1
fi

LLAMA_URL="${ASSET_LINES[0]}"
LLAMA_NAME="${ASSET_LINES[1]}"
CUDART_URL="${ASSET_LINES[2]}"
CUDART_NAME="${ASSET_LINES[3]}"

echo "Downloading $LLAMA_NAME (no GGUF)..."
# -f: fail on HTTP errors; -L: follow redirects; --progress-bar: compact progress.
curl -fL --progress-bar -o "$TMP_DIR/$LLAMA_NAME" "$LLAMA_URL"
echo "Downloading $CUDART_NAME (no GGUF)..."
curl -fL --progress-bar -o "$TMP_DIR/$CUDART_NAME" "$CUDART_URL"

mkdir -p "$DEST"
echo "Extracting into $DEST ..."
tar -xzf "$TMP_DIR/$LLAMA_NAME" -C "$DEST"
tar -xzf "$TMP_DIR/$CUDART_NAME" -C "$DEST"

# Normalize: some archives nest a single top-level directory.
# -x: file exists and is executable.
if [[ ! -x "$DEST/llama-server" ]]; then
  # head -n 1: take the first match only; || true: do not trip set -e if find is empty.
  nested="$(find "$DEST" -maxdepth 2 -type f -name llama-server | head -n 1 || true)"
  # -n: string length > 0.
  if [[ -n "$nested" ]]; then
    nested_dir="$(dirname "$nested")"
    # dotglob: include hidden files; nullglob: unmatched globs expand to nothing.
    shopt -s dotglob nullglob
    # 2>/dev/null: silence mv noise if a name already exists at DEST.
    mv "$nested_dir"/* "$DEST"/ 2>/dev/null || true
    shopt -u dotglob nullglob
  fi
fi

# Normalize CUDA runtime libraries: cudart archive unpacks into a subfolder.
# Co-locating .so files in $DEST ensures libggml-cuda.so can resolve them via LD_LIBRARY_PATH.
# -d: checks if directory exists; find locates any nested cudart subfolder.
cudart_dir="$(find "$DEST" -maxdepth 2 -type d -name "cudart*" | head -n 1 || true)"
# -n: checks if string length is greater than 0.
if [[ -n "$cudart_dir" ]]; then
  # nullglob: unmatched globs expand to nothing rather than the literal pattern string.
  shopt -s nullglob
  # Iterate and move all shared libraries (.so / .so.version) from the cudart subfolder into $DEST.
  for lib in "$cudart_dir"/*.so*; do
    # -f: regular file (or symlink).
    if [[ -f "$lib" ]]; then
      # 2>/dev/null: silence warnings if destination file is being overwritten.
      mv "$lib" "$DEST"/ 2>/dev/null || true
    fi
  done
  shopt -u nullglob
  # rmdir cleans up the subfolder if it is now empty.
  rmdir "$cudart_dir" 2>/dev/null || true
fi

SERVER="$DEST/llama-server"
if [[ ! -x "$SERVER" ]]; then
  SERVER="$(find "$DEST" -type f -name llama-server | head -n 1 || true)"
fi

# -z: string is empty; -f: path is a regular file.
if [[ -z "$SERVER" || ! -f "$SERVER" ]]; then
  echo "llama-server not found after extract under $DEST" >&2
  exit 1
fi

chmod +x "$SERVER" || true
# Prepend $DEST to LD_LIBRARY_PATH so dynamic linker finds libggml-base and CUDA runtime libraries.
export LD_LIBRARY_PATH="$DEST:${LD_LIBRARY_PATH:-}"
echo "Installed: $SERVER"
if "$SERVER" --version >/dev/null 2>&1; then
  "$SERVER" --version
elif "$SERVER" -h >/dev/null 2>&1; then
  "$SERVER" -h | head -n 20
else
  "$SERVER" --help | head -n 20 || true
fi

echo "Install complete. Next: bash scripts/smoke-llama-server.sh"
