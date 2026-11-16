# OpenCode local provider example

This folder holds an **example** provider block for OpenCode v2. It does not contain live API keys.

## Merge into your machine config

1. Start `llama-server` router: `bash scripts/start-router.sh`
2. Run the idempotent merger (preferred):

```bash
bash scripts/merge-opencode-llamacpp.sh
```

That script:

- Backs up `~/.config/opencode/opencode.jsonc` to a timestamped `.bak-*` beside it
- Inserts only `providers.llamacpp` from `provider.llamacpp.jsonc.example`
- Leaves the top-level `"model"` unchanged (switch locals via OpenCode `/models`)
- Never writes cloud `apiKey` values into this repository

Manual alternative: copy the `providers.llamacpp` object from `provider.llamacpp.jsonc.example` as a **sibling** next to your existing providers. Keep cloud `apiKey` values only in the machine config.

## Endpoint

- Package: `@opencode/ai/providers/openai-compatible`
- `baseURL`: `http://127.0.0.1:8080/v1`
- `apiKey`: `local` (placeholder bearer for compatible clients)

## Model IDs

See [../docs/model-id-map.md](../docs/model-id-map.md). After merge, use OpenCode `/models` and pick `llamacpp/qwen25-coder-14b` or `llamacpp/qwen3-14b`.

## Verify

Follow [../docs/verify-opencode.md](../docs/verify-opencode.md).
