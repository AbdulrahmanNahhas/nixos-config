# Local AI: llama-swap and Hermes

The NixOS side is declared in `modules/nixos/services/llama.nix` (llama.cpp
with CUDA, `services.llama-swap` on `127.0.0.1:8080`), `docker.nix`, and
`modules/home/programs/hermes.nix` (the `hermes` CLI and desktop app from the
`hermes` flake input). Everything below is one-time runtime setup that lives in
`/saved/models` and `~/.hermes`, both persistent.

Hermes updates come from `nix flake update hermes`; the Nix build refuses
`hermes update`.

## 1. Verify the GPU and the binary

```fish
nvidia-smi                 # must list the RTX 5060, idle
llama-server --version     # from the CUDA-enabled llama-cpp
```

## 2. Download the models

```fish
cd /saved/models
hf download unsloth/Qwen3.5-9B-GGUF Qwen3.5-9B-Q4_K_M.gguf --local-dir .
hf download unsloth/Qwen3.5-4B-GGUF Qwen3.5-4B-Q4_K_M.gguf --local-dir .
```

Expect about 5.7 GiB and 3.4 GiB. If a repo name 404s, search Hugging Face for
the current Qwen3.5 GGUF upload and adjust the file names in `llama.nix`.

Smoke test the 9B by hand before trusting the service:

```fish
llama-server -m /saved/models/Qwen3.5-9B-Q4_K_M.gguf -ngl 99 -c 32768 --port 8081
```

The startup log must say `offloaded N/N layers to GPU`. Anything less means
the layers landed on the CPU; fix that first. Then confirm the service path:

```fish
systemctl status llama-swap
curl http://127.0.0.1:8080/v1/models
journalctl -u llama-swap -f      # watch the first swap-in
```

## 3. Hermes: first run and lockdown

```fish
hermes setup
```

Edit `~/.hermes/config.yaml` before the first real task:

```yaml
approvals:
  mode: on                # never "off"

terminal:
  backend: docker         # default is "local", direct host execution
  container_memory: 3072  # MB; 16 GB total, llama-server needs the rest
  container_persistent: true
  docker_forward_env: []  # anything here is readable by agent code
```

Persistent mode keeps `/workspace` and `/root` under
`~/.hermes/sandboxes/docker/<task_id>/`. The Docker daemon is socket-activated
and starts on the first `hermes` task.

Trim the tool surface with `hermes tools`; enable the minimum. Do not run
`hermes gateway`.

## 4. Point Hermes at llama-swap

```fish
hermes model
```

OpenAI-compatible provider, endpoint `http://127.0.0.1:8080/v1`, model
`qwen-main`, any dummy API key. `hermes doctor` should pass. Add `qwen-fast`
as a second profile and Claude as a third; `/model` switches mid-session.
Skip Nous Portal.

## 5. Make it yours

```fish
cd ~/.hermes && git init
printf 'sandboxes/\n*.key\n.env\n' > .gitignore
git add -A && git commit -m "baseline"
```

Write `~/.hermes/SOUL.md` by hand. Skills in `~/.hermes/skills/` follow the
agentskills.io layout and also load in Claude Code.

## Notes

- Both models together exceed the 8 GiB of VRAM; llama-swap unloads an idle
  model after its `ttl` (600 s main, 300 s fast) so the other can load.
- The dGPU is normally asleep. If a swap-in fails with no CUDA device, check
  `nvidia-smi` first; if the card never wakes, the fallback is
  `hardware.nvidia.nvidiaPersistenced = true` at a power cost.

## Profiles (the household)

Each bot is a profile under `~/.hermes/profiles/<name>/` — its own
`config.yaml`, `.env`, `auth.json`, `SOUL.md`, `memories/`, sessions.
`--clone` copies config, `.env`, `SOUL.md`, skills, and the curated
memories, never OAuth logins: each bot signs in itself with
`hermes -p <name> auth add anthropic`.

| Bot | Role | Backend | Toolsets |
|-----|------|---------|----------|
| vivy | Shadow's keeper: NixOS config, Hermes, packages, AIs | `local`, manual approvals, write-sandboxed to the flake, `~/Projects`, her profile | terminal, file, delegation, memory, skills, todo, clarify, session_search |
| mira | companion, search, news, university | no terminal | web (keyless ring), file, memory, skills, todo, clarify, session_search |
| ash | engineering, real work | `docker`, `~/Projects` mounted at `/workspace` | terminal, code_execution, file, memory, skills, todo, clarify, session_search |

The root profile (`~/.hermes/config.yaml`) is the locked baseline the
clones inherit: `approvals.mode: manual`, the `approvals.deny` list,
docker backend, checkpoints on, wake word and catalog fetches off. Do
not run `hermes gateway`; `hermes setup` starts one, stop it with
`hermes gateway stop` and `systemctl --user disable --now hermes-gateway`.

## Updating

```fish
cd /saved/nixos-config
nix flake update hermes          # or: nix flake update  (everything)
nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link
sudo nh os test /saved/nixos-config
hermes config check              # new keys since the last version?
hermes config migrate            # adds them with defaults; review the diff
hermes doctor
```

`hermes update` is refused by the Nix build; ignore doctor's "reinstall
entry point with pip" line for the same reason. If the desktop app fails
its Electron-headers hash after a bump, either the override in
`modules/home/programs/hermes.nix` is now unnecessary (remove it) or its
hash needs the new value from the build error's `got:` line.

## Local models: when and how

`llama-swap` is running and `qwen-main`/`qwen-fast` are declared, but
the GGUF files are not downloaded until you run the `hf download` lines
above. Then, per bot:

```fish
hermes -p mira model    # Custom OpenAI-compatible → http://127.0.0.1:8080/v1, model qwen-main, any key
```

Good fits for the 9B: Mira's chat and summaries, quick questions,
anything you would rather not send to a cloud provider. Poor fits: Vivy's
NixOS work and Ash's engineering — tool-heavy, long-context tasks where a
9B fumbles. `/model` switches mid-session in either direction.
