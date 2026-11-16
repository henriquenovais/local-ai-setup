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
export LD_LIBRARY_PATH="$REPO_ROOT/bin/llama-cpp:${LD_LIBRARY_PATH:-}"

HELP_OUT="$("$SERVER" --help 2>&1 || "$SERVER" -h 2>&1 || true)"

if printf '%s' "$HELP_OUT" | grep -Eq 'models-max|models-dir'; then
  echo "OK: llama-server exposes router model flags"
  echo "Binary: $SERVER"
  exit 0
fi

echo "llama-server help did not mention models-max or models-dir" >&2
printf '%s\n' "$HELP_OUT" | head -n 40 >&2
exit 1
