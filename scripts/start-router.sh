#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$REPO_ROOT/bin/llama-cpp/llama-server"
EXAMPLE="$REPO_ROOT/llama-cpp/models.ini.example"
PRESET="$REPO_ROOT/llama-cpp/models.ini"
MODELS_DIR="$REPO_ROOT/models"

if [[ ! -x "$SERVER" ]]; then
  # Fall back to nested extract locations.
  SERVER="$(find "$REPO_ROOT/bin/llama-cpp" -type f -name llama-server 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "${SERVER:-}" || ! -f "$SERVER" ]]; then
  echo "llama-server not found. Run: bash scripts/install-llama-cpp.sh" >&2
  exit 2
fi

chmod +x "$SERVER" || true
mkdir -p "$MODELS_DIR"

if [[ ! -f "$PRESET" ]]; then
  if [[ ! -f "$EXAMPLE" ]]; then
    echo "Missing $EXAMPLE" >&2
    exit 1
  fi
  cp "$EXAMPLE" "$PRESET"
  # Rewrite model= paths to absolute paths for reliable loading.
  python3 - "$PRESET" "$REPO_ROOT" <<'PY'
import pathlib, sys
preset = pathlib.Path(sys.argv[1])
root = pathlib.Path(sys.argv[2]).resolve()
lines = []
for line in preset.read_text().splitlines():
    if line.strip().startswith("model ") or line.strip().startswith("model="):
        key, _, value = line.partition("=")
        rel = value.strip()
        abs_path = (root / rel).resolve()
        lines.append(f"{key.strip()} = {abs_path}")
    else:
        lines.append(line)
preset.write_text("\n".join(lines) + "\n")
PY
  echo "Created $PRESET from example (gitignored)."
fi

# Locate any nested cudart directory defensively in case libraries were not flattened.
# -d: checks if directory exists; head -n 1 takes the first match if multiple exist.
CUDART_DIR="$(find "$REPO_ROOT/bin/llama-cpp" -maxdepth 2 -type d -name "cudart*" 2>/dev/null | head -n 1 || true)"
# -n: checks if string length is non-zero (i.e. cudart directory found).
if [[ -n "$CUDART_DIR" ]]; then
  # Prepend both primary binary directory and nested cudart directory to LD_LIBRARY_PATH.
  # ${LD_LIBRARY_PATH:-}: parameter expansion fallback prevents unbound variable error under set -u.
  export LD_LIBRARY_PATH="$REPO_ROOT/bin/llama-cpp:$CUDART_DIR:${LD_LIBRARY_PATH:-}"
else
  # Fallback to standard binary directory.
  export LD_LIBRARY_PATH="$REPO_ROOT/bin/llama-cpp:${LD_LIBRARY_PATH:-}"
fi

exec "$SERVER" \
  --models-dir "$MODELS_DIR" \
  --models-max 1 \
  --models-preset "$PRESET" \
  -c 8192 \
  --host 127.0.0.1 \
  --port 8080
