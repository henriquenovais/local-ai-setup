# OpenCode local provider example

This folder holds an **example** provider block for OpenCode v2. It does not contain live API keys.

## Merge into your machine config

1. Start `llama-server` router: `bash scripts/start-router.sh`
2. Open `~/.config/opencode/opencode.jsonc`
3. Copy the `providers.llamacpp` object from `provider.llamacpp.jsonc.example` as a **sibling** next to your existing providers (for example Flow / Google)
4. Optionally set `"model": "llamacpp/qwen25-coder-14b"` when you want the local default
5. Keep cloud `apiKey` values only in the machine config — never copy them into this repository

## Endpoint

- Package: `@opencode/ai/providers/openai-compatible`
- `baseURL`: `http://127.0.0.1:8080/v1`
- `apiKey`: `local` (placeholder bearer for compatible clients)

## Model IDs

See [../docs/model-id-map.md](../docs/model-id-map.md). After merge, use OpenCode `/models` and pick `llamacpp/qwen25-coder-14b` or `llamacpp/qwen3-14b`.

## Verify

Follow [../docs/verify-opencode.md](../docs/verify-opencode.md).
