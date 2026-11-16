# Model ID map

One-to-one mapping between OpenCode model IDs, llama.cpp INI sections, and on-disk GGUF filenames.

| OpenCode model | INI section (`models.ini`) | File under `models/` |
| --- | --- | --- |
| `llamacpp/qwen25-coder-14b` | `qwen25-coder-14b` | `qwen2.5-coder-14b-instruct-q4_k_m.gguf` |
| `llamacpp/qwen3-14b` | `qwen3-14b` | `qwen3-14b-q4_k_m.gguf` |

## Runtime rule

`llama-server` is started with `--models-max 1`. Only one of these GGUFs is loaded at a time. Switching in the Web UI or via OpenCode `/models` unloads the previous model and loads the next. Expect a full reload (seconds to minutes on this GPU), not a millisecond hot-swap.

Quantization for both LLM entries is **Q4_K_M** unless you deliberately change the filenames and INI paths together.
