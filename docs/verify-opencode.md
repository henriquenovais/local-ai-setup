# Verify OpenCode ↔ llama.cpp

Use this checklist after the router is installed. Model downloads can wait until Setup D; steps 1–3 still validate wiring shape.

1. **Router listening on 8080**  
   `bash scripts/start-router.sh` (needs GGUFs for a useful `/v1/models` list; binary must exist first).

2. **Merge example provider**  
   Copy `providers.llamacpp` from `opencode/provider.llamacpp.jsonc.example` into `~/.config/opencode/opencode.jsonc` as a sibling provider. Do not paste Flow/Google **API keys** into this repository.

3. **Probe the OpenAI-compatible endpoint**  
   `curl -s http://127.0.0.1:8080/v1/models`

4. **OpenCode model picker**  
   Start OpenCode and run `/models`. Confirm `llamacpp/qwen25-coder-14b`, `llamacpp/qwen3-14b`, and `llamacpp/qwen3-14b-q4_k_m` appear after the merge.

5. **One short chat** (after weights exist)  
   Select `llamacpp/qwen25-coder-14b`, send a trivial prompt, confirm a streamed reply.

If the picker is empty, confirm `baseURL` ends with `/v1` and that `llama-server` is bound to `127.0.0.1:8080`.
