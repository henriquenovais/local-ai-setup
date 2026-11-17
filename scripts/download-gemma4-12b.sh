#!/usr/bin/env bash
# ^ Shebang: Uses /usr/bin/env to locate the bash binary from the user's $PATH for portability across Unix environments.

# Enable Bash Strict Mode (fail-fast error handling):
# -e: Exit immediately if any command returns a non-zero exit status.
# -u: Exit immediately if an undefined/uninitialized variable is referenced (catches typos).
# -o pipefail: Ensures a pipeline (cmd1 | cmd2) fails if any command in the chain fails, not just the last.
set -euo pipefail

# Source: unsloth/gemma-4-12b-it-GGUF
# Remote: gemma-4-12b-it-Q4_K_M.gguf (~7.1 GiB)
# Local:  models/gemma-4-12b-it-q4_k_m.gguf

# ${BASH_SOURCE[0]} resolves the executing script path; dirname + /.. resolves the repository root directory.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_DIR="$REPO_ROOT/models"
REMOTE_REPO="unsloth/gemma-4-12b-it-GGUF"
REMOTE_FILE="gemma-4-12b-it-Q4_K_M.gguf"
LOCAL_FILE="gemma-4-12b-it-q4_k_m.gguf"
DEST="$MODELS_DIR/$LOCAL_FILE"
HF_URL="https://huggingface.co/${REMOTE_REPO}/resolve/main/${REMOTE_FILE}"

# -p flag ensures parent directory is created if missing and succeeds if it already exists.
mkdir -p "$MODELS_DIR"

# Helper function to check if the Hugging Face CLI binary is installed and executable.
hf_works() {
  # command -v searches $PATH for the binary; >/dev/null suppresses stdout; 2>&1 redirects stderr to stdout.
  command -v hf >/dev/null 2>&1 || return 1
  # Verify CLI executes without error.
  hf --help >/dev/null 2>&1
}

# -f test operator checks if destination file already exists and is a regular file.
if [[ -f "$DEST" ]]; then
  echo "Already present: $DEST"
else
  if hf_works; then
    echo "Downloading via Hugging Face CLI: $REMOTE_REPO / $REMOTE_FILE..."
    hf download "$REMOTE_REPO" "$REMOTE_FILE" --local-dir "$MODELS_DIR"
    DOWNLOADED="$MODELS_DIR/$REMOTE_FILE"
    # Rename if remote file casing differs from local naming convention.
    if [[ -f "$DOWNLOADED" && "$DOWNLOADED" != "$DEST" ]]; then
      mv -f "$DOWNLOADED" "$DEST"
    fi
  else
    echo "hf unavailable; downloading via curl (resumable)..."
    # -f fails fast on HTTP error codes (4xx/5xx).
    # -L follows HTTP redirects.
    # --retry and --retry-delay manage transient connection drops.
    # -C - automatically resumes a partially downloaded file.
    # -o specifies the target output path (using .part suffix until complete).
    curl -fL --retry 3 --retry-delay 2 -C - -o "$DEST.part" "$HF_URL"
    # Atomic rename from partial download to final destination filename.
    mv -f "$DEST.part" "$DEST"
  fi
fi

# Assert destination file exists after download phase.
if [[ ! -f "$DEST" ]]; then
  echo "Download failed: missing $DEST" >&2
  exit 1
fi

# Guard: Ensure model weight file is gitignored to prevent accidental large binary commits.
if ! git -C "$REPO_ROOT" check-ignore -q "$DEST"; then
  echo "ERROR: $DEST is not gitignored" >&2
  exit 1
fi

git -C "$REPO_ROOT" check-ignore -v "$DEST"
echo "OK: $DEST"
ls -lh "$DEST"
