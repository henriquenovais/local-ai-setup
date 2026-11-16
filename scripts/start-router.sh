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

export LD_LIBRARY_PATH="$REPO_ROOT/bin/llama-cpp:${LD_LIBRARY_PATH:-}"

exec "$SERVER" \
  --models-dir "$MODELS_DIR" \
  --models-max 1 \
  --models-preset "$PRESET" \
  -c 8192 \
  --host 127.0.0.1 \
  --port 8080
