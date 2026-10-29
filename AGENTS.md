# Repository Guidelines

## Project Structure & Module Organization

This flake configures the single `shadow` host and Aqua's Home Manager environment. `flake.nix` constructs the system; `shadow/default.nix` contains machine facts, Disko layout, and directly selects the `modules/nixos/` groups it needs. `shadow/home.nix` owns Aqua's identity and directly selects the `modules/home/` groups it needs. There is one host and one user, so both live flat under `shadow/`. Keep module-owned assets beside their module. Maintain `README.md`, `ROADMAP.md` and `REFERENCES.md` as the primary documentation. Use `encrypted-secrets/` for committed SOPS ciphertext only.

Follow the dependency direction: `shadow/` selects modules directly. Do not import Home Manager user modules from NixOS modules. Only split `shadow/` into per-host/per-user subdirectories (and reintroduce a `profiles/` composition layer) once a second host or user needs a differing module selection.

## Build, Test, and Development Commands

- `nix flake check`: evaluate all flake outputs and catch module errors.
- `nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link`: build the complete system without switching generations.
- `sudo nh os test /saved/nixos-config`: activate temporarily; the previous configuration returns after reboot.
- `sudo nh os switch /saved/nixos-config`: build and activate a reviewed configuration.
- `nix fmt`: format every Nix file with the flake's `nixfmt`/`fd` formatter.
- `niri validate --config ~/.config/niri/config.kdl`: validate the live Niri configuration, including Noctalia's generated include.

Never run destructive Disko installation/formatting commands as a test.

## Coding Style & Naming Conventions

Use two-space indentation and `nixfmt` output for Nix. Prefer small domain-focused modules named with lowercase descriptive words, such as `modules/nixos/services/power.nix`. Keep hardware facts in `shadow/`; avoid embedding host or user paths in reusable modules. Keep comments brief and direct: explain constraints, hardware workarounds and security tradeoffs. Put longer explanations in the documentation.

## Testing Guidelines

There is no unit-test framework or coverage target. For configuration changes, run `nix flake check`, `git diff --check`, and the no-link system build. For documentation-only changes, check local links and run `git diff --check`. Validate edited KDL/TOML with its owning application when possible. For boot, storage, GPU, networking, or persistence changes, use `nh os test` before `switch` and verify the relevant service or hardware state. Build validation does not authorize activation.

## Documentation Maintenance

Do not update `README.md`, `ROADMAP.md` or `REFERENCES.md` automatically after each edit. Change them only when explicitly requested or when a change makes existing guidance materially incorrect or leaves essential operating, migration or recovery instructions missing. Update only the relevant file and section; routine package additions, small configuration tweaks and refactors do not need documentation entries.

Keep these files curated, not as changelogs, package inventories or task logs. Do not add incidental details, speculative follow-up work, validation transcripts or upstream links merely because a tool or application was touched. These documentation rules take precedence over broader update-on-every-change wording elsewhere in the repository.

When a documentation update is warranted, use these scopes:

- `README.md`: system layout, commands, persistence and recovery.
- `ROADMAP.md`: grouped technology status, proposed work and acceptance criteria.
- `REFERENCES.md`: upstream documentation and learning links.

Keep facts with their owner. Link to configuration instead of copying declarations.
Distinguish source declarations, successful builds and host verification. Never
invent adoption dates or commit IDs.

Before committing, review the staged diff, check documentation links and run
`git diff --check`. Documentation and comment changes need no activation.
Never include decrypted secrets, credentials or private runtime files in documentation.

## Commit & Pull Request Guidelines

Use `<scope>: <imperative description>` for new commit subjects, with a lowercase
scope such as `zed`, `graphics`, `power`, `network`, `system` or `docs`. For example:
`graphics: prefer AMD renderer in niri`. Describe the actual change, keep subjects
concise, and split independent work into focused commits. Preserve existing commit
IDs and history evidence when standardizing future titles; rewriting published
history is a separate task because it changes IDs and downstream links.

Pull requests should explain motivation, affected modules, validation, and rollback
concerns. Include screenshots only for visible desktop changes and link related
issues when applicable.

## Security & State

Do not commit credentials, keys, tokens, or `/saved/secrets/nix.conf`. Root is tmpfs; document persistence changes in `README.md` only when they affect existing persistence guidance or require essential migration or recovery instructions. Do not list every new application state directory there; the configuration owns the exact paths. Preserve unrelated modifications in a dirty worktree.
