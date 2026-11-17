# Hardware inventory

Snapshot of the machine this repository targets. Re-check with `nvidia-smi` and `free -h` if hardware changes.

## CPU

- Intel Core i5-12450H (8 cores / 12 threads)

## Memory

- 15 GiB system RAM
- Expect swap use when a 14B Q4 GGUF is partially offloaded

## GPU

- NVIDIA GeForce RTX 3050 Laptop GPU, 6 GiB VRAM
- Driver series 580, CUDA 13.0 reported by `nvidia-smi`
- Compute capability 8.6

## Disk

- About 278 GiB free on the root filesystem at initial inventory
- Store all weights under `models/` (gitignored)

## Software baseline (inventory)

- Pop!_OS 24.04 LTS
- OpenCode CLI v2.3.0 available on PATH
- No llama.cpp / Ollama install at inventory time
- No CUDA toolkit / `nvcc` / `cmake` at inventory time (use prebuilt CUDA binaries)

## VRAM contention

- Desktop apps such as Handy can hold roughly 2 GiB VRAM when hardware acceleration is set to GPU or Auto.
- **Configuring Handy for CPU/RAM:**
  To free ~1.0–2.2 GiB VRAM for local models, configure Handy to run its transcription model on the CPU and system RAM:
  1. Quit Handy completely.
  2. In `~/.local/share/com.pais.handy/settings_store.json`, set:
     ```json
     "transcribe_accelerator": "cpu",
     "ort_accelerator": "cpu"
     ```
  3. Relaunch Handy. Verify via `nvidia-smi` that Handy is no longer listed in GPU memory and processes display `handy --transcribe-worker --cpu-only`.
- Always verify free VRAM with `nvidia-smi` before launching a 14B model (aim for ~5.5 GiB free).
