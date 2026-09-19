# Local AI: llama-swap (parked)

Not imported today: `modules/home/programs/ai/default.nix` comments out
`./local.nix` and the Noctalia `ai` launcher entry is commented out beside it,
because `llama-cpp-cuda` compiles locally on every nixpkgs bump. Uncomment
both to enable.

`modules/home/programs/ai/local.nix` owns the whole feature: `llama-cpp-cuda`,
a user service running `llama-swap` on `127.0.0.1:8080`, the `ai` fish
function, and Zed's "Local" model provider. The GGUF files in `/saved/models`
are the only runtime state.

Nothing runs until `ai on`. llama-swap itself never touches the GPU; it starts
`llama-server` for whichever model a client asks for and stops it after the
model's `ttl`, so the RTX 5060 wakes only while a model is loaded and sleeps
again a few minutes after the last request.

## Build cost

`llama-cpp-cuda` is not served by any binary cache, so each nixpkgs bump
recompiles llama-cpp locally (minutes, one GPU architecture thanks to
`cudaCapabilities`). The CUDA runtime it links against does come from
`cache.nixos-cuda.org`. If a bump also brings a build input that Hydra has not
cached yet (Node.js was one), that compiles too; `nh os switch` a day later
usually finds it cached.

## Setup

```fish
cd /saved/models
hf download unsloth/Qwen3.5-9B-GGUF Qwen3.5-9B-Q4_K_M.gguf --local-dir .
```

Expect about 5.7 GiB. If the repo name 404s, search Hugging Face for the
current upload and change the file name in `local.nix`; a new model is a
new entry in its `models` set and in the Zed list.

Smoke test by hand before trusting the service:

```fish
llama-server -m /saved/models/Qwen3.5-9B-Q4_K_M.gguf -ngl 99 -fa on --port 8081
```

The log must say `offloaded N/N layers to GPU`. Then:

```fish
ai on
ai chat            # llama.cpp's chat UI, nothing else to install
ai status          # loaded models
ai logs            # follow the service log
ai unload          # free the GPU, keep the router
ai off
```

The Noctalia launcher has the same actions under the `ai` prefix.

## Clients

- **Chat**: `ai chat` opens llama.cpp's built-in web UI (served by llama-swap
  at `/upstream/qwen-main/`). Local, no account, conversations stay in the
  browser profile.
- **Zed**: agent panel → "Local" provider. It asks for an API key once; type
  anything. The service must be running; Zed will not start it.
- **OpenCode**: `opencode providers login` → OpenAI-compatible provider, host
  `http://127.0.0.1:8080`, model `qwen-main`, any key.
- **Codex**: a `[model_providers.local]` entry in `~/.codex/config.toml` with
  `base_url = "http://127.0.0.1:8080/v1"`, then `codex -c model_provider=local
  -m qwen-main`.
- **GNOME app**, if a native window is wanted later: Alpaca
  (`com.jeffser.Alpaca` on Flathub, libadwaita, speaks to any
  OpenAI-compatible endpoint, has speech input). Not installed.

## Two GPUs

The CUDA build can only see the RTX 5060. Small models for the AMD 880M need
`llama-cpp-vulkan` (Hydra-cached, no toolkit) with the AMD ICD pinned so they
never wake the NVIDIA card:

```nix
cmd = "${lib.getExe' pkgs.llama-cpp-vulkan "llama-server"} -m ${models}/<2B>.gguf -ngl 99 -c 8192 --port \${PORT} --host 127.0.0.1";
env = [ "VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json" ];
```

The iGPU has no VRAM of its own; a 2B model takes about 1.5 GiB of the 16 GiB
of RAM, which is fine next to the 9B in VRAM. Speech: `whisper-cpp-vulkan`
(transcription, same ICD trick) and `piper-tts` (speech synthesis, CPU) are in
nixpkgs; Alpaca can drive both. Add these when a model is chosen; nothing is
declared until then.

## Notes

- If a swap-in fails with no CUDA device, check `nvidia-smi` first; if the
  card never wakes, the fallback is `hardware.nvidia.nvidiaPersistenced = true`
  at a power cost.
