# Repository Guidelines

## Project Structure & Module Organization

This flake configures the single `shadow` host and Aqua's Home Manager environment. `flake.nix` constructs the system; `shadow/default.nix` contains machine facts, Disko layout, and directly selects the `modules/nixos/` groups it needs. `shadow/home.nix` owns Aqua's identity and directly selects the `modules/home/` groups it needs. There is one host and one user, so both live flat under `shadow/` rather than `hosts/<name>/` and `home/<user>/` subdirectories. Keep module-owned KDL, TOML, SVG, and text assets beside their module. Use `guide/` for the interactive operator guide and `encrypted-secrets/` for committed SOPS ciphertext only.

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

Use two-space indentation and `nixfmt` output for Nix. Prefer small domain-focused modules named with lowercase descriptive words, such as `modules/nixos/services/power.nix`. Keep hardware facts in `shadow/`; avoid embedding host or user paths in reusable modules. Add comments for non-obvious hardware workarounds and security tradeoffs.

## Testing Guidelines

There is no unit-test framework or coverage target. For configuration changes, run `nix flake check`, `git diff --check`, and the no-link system build. For guide-only changes, use the guide checks below. Validate edited KDL/TOML with its owning application when possible. For boot, storage, GPU, networking, or persistence changes, use `nh os test` before `switch` and verify the relevant service or hardware state. Build validation does not authorize activation.

## Guide Maintenance

Before each commit, review the diff and update every affected guide explanation,
technology entry, workflow, roadmap item, history relationship and persistence note.
Update only information affected by the change. A change to a module's behavior
must include its relevant documentation; do not leave documentation as later work.

Keep each fact in one authoritative source: explanations in `guide/docs/`, grouped
technologies in `guide/tools.json`, proposed work in `guide/roadmap.json`, and
semantic history in `guide/timeline.json`. Configuration previews, declaration
checks and input revisions come from repository sources at build time. Derive
counts, labels, links and period boundaries instead of copying them between pages.
Generated declarations describe configuration; runtime verification and the reason
for a decision require evidence. Never invent adoption dates or commit IDs.

Run `./guide/build.sh`, `node guide/check.mjs guide` and `git diff --check` before
committing. Include refreshed generated HTML with source changes; never edit HTML
directly. For a coordinated commit series, update affected prose in its scoped
commit and finish the shared guide rebuild before the final commit in that series.
Guide-only changes need no NixOS activation. These instructions require the agent
to maintain the guide; they do not install a Git hook or generate explanations.

The Pages workflow publishes only Hugo output and rebuilds after every push to
`main`. A local commit does not deploy. Never include decrypted secrets,
credentials or private runtime files in the guide or Pages artifact.

## Commit & Pull Request Guidelines

Use `<scope>: <imperative description>` for new commit subjects, with a lowercase
scope such as `zed`, `graphics`, `power`, `network`, `system` or `guide`. For example:
`graphics: prefer AMD renderer in niri`. Describe the actual change, keep subjects
concise, and split independent work into focused commits. Preserve existing commit
IDs and history evidence when standardizing future titles; rewriting published
history is a separate task because it changes IDs and downstream links.

Pull requests should explain motivation, affected modules, validation, and rollback
concerns. Include screenshots only for visible desktop changes and link related
issues when applicable.

## Security & State

Do not commit credentials, keys, tokens, or `/saved/secrets/nix.conf`. Root is tmpfs; update the persistence section in `guide/` whenever persistent state changes. Preserve unrelated modifications in a dirty worktree.
