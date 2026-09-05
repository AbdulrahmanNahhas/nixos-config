# Repository Guidelines

## Project Structure & Module Organization

This flake configures the single `shadow` host and Aqua's Home Manager environment. `flake.nix` constructs the system; `shadow/default.nix` contains machine facts, Disko layout, and directly selects the `modules/nixos/` groups it needs. `shadow/home.nix` owns Aqua's identity and directly selects the `modules/home/` groups it needs. There is one host and one user, so both live flat under `shadow/` rather than `hosts/<name>/` and `home/<user>/` subdirectories. Keep module-owned KDL, TOML, SVG, and text assets beside their module. Use `docs/` for design and operational notes and `encrypted-secrets/` for committed SOPS ciphertext only.

Follow the dependency direction documented in `docs/architecture.md`: `shadow/` selects modules directly. Do not import Home Manager user modules from NixOS modules. Only split `shadow/` into per-host/per-user subdirectories (and reintroduce a `profiles/` composition layer) once a second host or user needs a differing module selection.

## Build, Test, and Development Commands

- `nix flake check`: evaluate all flake outputs and catch module errors.
- `nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link`: build the complete system without switching generations.
- `sudo nh os test /saved/nixos-config`: activate temporarily; the previous configuration returns after reboot.
- `sudo nh os switch /saved/nixos-config`: build and activate a reviewed configuration.
- `nix fmt`: format every Nix file with the flake's `nixfmt`/`fd` formatter.
- `niri validate --config ~/.config/niri/config.kdl`: validate the live Niri configuration, including Noctalia's generated include.

Never use the destructive Disko installation command in `docs/installation.md` as a test.

## Coding Style & Naming Conventions

Use two-space indentation and `nixfmt` output for Nix. Prefer small domain-focused modules named with lowercase descriptive words, such as `modules/nixos/services/power.nix`. Keep hardware facts in `shadow/`; avoid embedding host or user paths in reusable modules. Add comments for non-obvious hardware workarounds and security tradeoffs.

## Testing Guidelines

There is no unit-test framework or coverage target. At minimum, run `nix flake check`, `git diff --check`, and the no-link system build. Validate edited KDL/TOML with its owning application when possible. For boot, storage, GPU, networking, or persistence changes, use `nh os test` before `switch` and verify the relevant service or hardware state.

## Commit & Pull Request Guidelines

History uses concise subjects, sometimes with prefixes such as `fix:`, `docs:`, `chore:`, or `preservation:`. Prefer an imperative, scoped subject, for example `graphics: prefer AMD renderer in niri`. Keep commits focused. Pull requests should explain motivation, affected host/profile, validation commands, rollback concerns, and include screenshots only for visible desktop changes. Link related issues when applicable.

## Security & State

Do not commit credentials, keys, tokens, or `/saved/secrets/nix.conf`. Root is tmpfs; update `docs/persistence.md` whenever persistent state changes. Preserve unrelated modifications in a dirty worktree.
