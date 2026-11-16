# Directory layout

Path contract for this repository. Later phases drop files only into these locations.

```text
local-ai-setup/
  .gitignore
  .githooks/pre-commit
  README.md
  docs/
    hardware.md
    commit-checklist.md
    directory-layout.md
    verify-llama-cpp.md
    verify-opencode.md
    model-id-map.md
    download-models.md
    flux.md
  llama-cpp/
    install.md
    router.md
    models.ini.example
    models.ini          # local only, gitignored
  scripts/
    enable-git-hooks.sh
    install-llama-cpp.sh
    start-router.sh
    smoke-llama-server.sh
    download-*.sh
  opencode/
    README.md
    provider.llamacpp.jsonc.example
  models/               # weights only; gitignored except .gitkeep
    .gitkeep
    *.gguf              # never commit
    flux/               # never commit
  bin/                  # downloaded llama.cpp binaries; gitignored
    llama-cpp/
```

## Rules

- `llama-cpp/` — install + router documentation and examples.
- `scripts/` — operator automation (install, start, smoke, download).
- `opencode/` — example provider config only (no live secrets).
- `models/` — GGUF / FLUX weights only.
- `docs/` — runbooks and verification.
- `bin/` — prebuilt `llama-server` and CUDA runtime extracts.
