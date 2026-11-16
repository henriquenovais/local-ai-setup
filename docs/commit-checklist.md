# Commit checklist

Run this before every commit. Do not skip after downloading models.

1. `git status` — confirm only intended text/scripts are untracked or modified.
2. `git diff --cached --stat` — review staged paths and sizes.
3. Confirm no `*.gguf` or `*.safetensors` appear in staged or “to be added” lists.
4. Confirm the largest staged file is under **50 MiB** (the pre-commit hook also enforces this).
5. Confirm you are not staging live secrets (`~/.config/opencode/opencode.jsonc`, `.env`, API keys).
6. Prefer path-specific adds (`git add README.md docs/ …`) over `git add .` after any weight download.
7. If hooks are disabled, re-enable: `bash scripts/enable-git-hooks.sh`.
