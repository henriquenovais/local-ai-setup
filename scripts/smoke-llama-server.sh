#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$REPO_ROOT/bin/llama-cpp/llama-server"

if [[ ! -x "$SERVER" ]]; then
  SERVER="$(find "$REPO_ROOT/bin/llama-cpp" -type f -name llama-server 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "${SERVER:-}" || ! -f "$SERVER" ]]; then
  echo "Run scripts/install-llama-cpp.sh first" >&2
  exit 2
fi

chmod +x "$SERVER" || true

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

# Probe help output for router capability.
# 2>&1 redirects standard error to standard output so failures are captured.
HELP_OUT="$("$SERVER" --help 2>&1 || "$SERVER" -h 2>&1 || true)"

if ! printf '%s' "$HELP_OUT" | grep -Eq 'models-max|models-dir'; then
  echo "llama-server help did not mention models-max or models-dir" >&2
  printf '%s\n' "$HELP_OUT" | head -n 40 >&2
  exit 1
fi

echo "OK: llama-server exposes router model flags"

# Check GPU acceleration and list available compute devices.
echo "Checking compute devices..."
DEVICES_OUT="$("$SERVER" --list-devices 2>&1 || true)"
printf '%s\n' "$DEVICES_OUT"

# Verify that at least one CUDA device is registered and accessible.
if ! printf '%s' "$DEVICES_OUT" | grep -q 'CUDA'; then
  echo "ERROR: No CUDA device found by llama-server (libggml-cuda.so may have failed to load)." >&2
  echo "Ensure libcudart.so and libcublas.so are co-located in bin/llama-cpp or in LD_LIBRARY_PATH." >&2
  exit 1
fi

echo "OK: CUDA acceleration verified"
echo "Binary: $SERVER"
exit 0
