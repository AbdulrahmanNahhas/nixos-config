# Repository Guidelines

## Project Structure & Module Organization

This flake configures the single `shadow` host and Aqua's Home Manager environment. `flake.nix` constructs the system; `hosts/shadow/` contains machine facts and Disko layout. `profiles/nixos/` and `profiles/home/` compose features, while reusable implementations live under `modules/nixos/` and `modules/home/`. Keep module-owned KDL, TOML, SVG, and text assets beside their module. Use `assets/` only for shared assets, `docs/` for design and operational notes, and `secrets/` for documentation—not secret material.

Follow the dependency direction documented in `docs/architecture.md`: hosts select profiles, and profiles import modules. Do not import Home Manager user modules from NixOS modules.

## Build, Test, and Development Commands

- `nix flake check`: evaluate all flake outputs and catch module errors.
- `nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link`: build the complete system without switching generations.
- `sudo nh os test /saved/nixos-config`: activate temporarily; the previous configuration returns after reboot.
- `sudo nh os switch /saved/nixos-config`: build and activate a reviewed configuration.
- `nix fmt`: format every Nix file with the flake's `nixfmt`/`fd` formatter.
- `niri validate --config ~/.config/niri/config.kdl`: validate the live Niri configuration, including Noctalia's generated include.

Never use the destructive Disko installation command in `docs/installation.md` as a test.

## Coding Style & Naming Conventions

Use two-space indentation and `nixfmt` output for Nix. Prefer small domain-focused modules named with lowercase descriptive words, such as `modules/nixos/services/power.nix`. Keep hardware facts in `hosts/shadow/`; avoid embedding host or user paths in reusable modules. Add comments for non-obvious hardware workarounds and security tradeoffs.

## Testing Guidelines

There is no unit-test framework or coverage target. At minimum, run `nix flake check`, `git diff --check`, and the no-link system build. Validate edited KDL/TOML with its owning application when possible. For boot, storage, GPU, networking, or persistence changes, use `nh os test` before `switch` and verify the relevant service or hardware state.

## Commit & Pull Request Guidelines

History uses concise subjects, sometimes with prefixes such as `fix:`, `docs:`, `chore:`, or `preservation:`. Prefer an imperative, scoped subject, for example `graphics: prefer AMD renderer in niri`. Keep commits focused. Pull requests should explain motivation, affected host/profile, validation commands, rollback concerns, and include screenshots only for visible desktop changes. Link related issues when applicable.

## Security & State

Do not commit credentials, keys, tokens, or `/saved/secrets/nix.conf`. Root is tmpfs; update `docs/persistence.md` whenever persistent state changes. Preserve unrelated modifications in a dirty worktree.
