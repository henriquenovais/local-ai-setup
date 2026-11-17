#!/usr/bin/env bash
# ^ Shebang: Uses /usr/bin/env to locate bash from $PATH for portability.

# Enable Bash Strict Mode (fail-fast error handling):
# -e: Exit immediately if any command returns a non-zero exit status.
# -u: Exit immediately if an undefined/uninitialized variable is referenced.
# -o pipefail: Pipeline fails if any command in the chain fails, not just the last.
set -euo pipefail

# ${BASH_SOURCE[0]} is this script's path; dirname + /.. resolves the repo root.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE="$REPO_ROOT/opencode/provider.llamacpp.jsonc.example"
# ${XDG_CONFIG_HOME:-$HOME/.config}: prefer XDG config home when set, else ~/.config.
CONFIG="${OPENCODE_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.jsonc}"

# -f: path exists and is a regular file.
if [[ ! -f "$EXAMPLE" ]]; then
  echo "Missing example provider: $EXAMPLE" >&2
  exit 1
fi
if [[ ! -f "$CONFIG" ]]; then
  echo "Missing OpenCode config: $CONFIG" >&2
  exit 1
fi

# Backup timestamp: YYYYMMDDHHMMSS from date +%Y%m%d%H%M%S.
BACKUP="${CONFIG}.bak-$(date +%Y%m%d%H%M%S)"
cp -a "$CONFIG" "$BACKUP"
echo "Backup: $BACKUP"

# Merge providers.llamacpp only; never overwrite top-level "model".
# Logs provider ids and booleans only — never prints apiKey / settings values.
python3 - "$EXAMPLE" "$CONFIG" <<'PY'
import json
import re
import sys
from pathlib import Path

example_path = Path(sys.argv[1])
config_path = Path(sys.argv[2])


def strip_jsonc(text: str) -> str:
    # Remove /* ... */ block comments (non-greedy, DOTALL).
    no_block = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    # Remove // line comments outside of strings (simple pass; configs here are plain JSON).
    no_line = re.sub(r"(?m)^\s*//.*?$", "", no_block)
    return no_line


def load_jsonc(path: Path) -> dict:
    raw = path.read_text(encoding="utf-8")
    return json.loads(strip_jsonc(raw))


example = load_jsonc(example_path)
config = load_jsonc(config_path)

if "providers" not in example or "llamacpp" not in example["providers"]:
    sys.stderr.write("Example is missing providers.llamacpp\n")
    sys.exit(1)

providers = config.setdefault("providers", {})
example_llamacpp = example["providers"]["llamacpp"]
changed = False

if "llamacpp" not in providers:
    providers["llamacpp"] = example_llamacpp
    changed = True
else:
    # Deep merge models dictionary so newly added models appear in existing installations.
    target_models = providers["llamacpp"].setdefault("models", {})
    for model_id, model_def in example_llamacpp.get("models", {}).items():
        if model_id not in target_models:
            target_models[model_id] = model_def
            changed = True

# Intentionally do not copy example["model"] — keep the machine default.
if changed:
    config_path.write_text(
        json.dumps(config, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

print("has_llamacpp=True")
print("provider_ids=" + ",".join(sorted(providers.keys())))
print(f"unchanged={not changed}")
PY

echo "Merged providers.llamacpp into $CONFIG (top-level model unchanged)."
echo "Pick local models in OpenCode via /models (llamacpp/qwen25-coder-14b, llamacpp/qwen3-14b, llamacpp/qwen3-14b-q4_k_m, llamacpp/gemma4-12b)."
