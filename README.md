# Shadow

Ash's declarative NixOS and Home Manager configuration for a Razer Blade 14
(`RZ09-0530`, x86_64 Linux). One machine, one user: host `shadow`, account `aqua`.

[System and tools inventory](REFERENCES.md) · [Major work checklist](ROADMAP.md)

## Find the configuration

| Path                                              | Responsibility                                                      |
| ------------------------------------------------- | ------------------------------------------------------------------- |
| [flake.nix](flake.nix) / [flake.lock](flake.lock) | Dependencies, pinned revisions, host output, formatter and checks   |
| [configuration.nix](configuration.nix)            | Explicit system imports and Home Manager wiring                     |
| [home.nix](home.nix)                              | Explicit user imports, identity and defaults                        |
| [system/](system/)                                | Base, hardware, storage, networking, security, desktop and services |
| [home/desktop/](home/desktop/)                    | Desktop behavior, appearance and integration                        |
| [home/terminal/](home/terminal/)                  | Shell, terminal and terminal navigation                             |
| [home/apps/](home/apps/)                          | Applications, editors and development integration                   |
| [gaming/](gaming/) | Steam, Heroic, overlays, shortcuts and gaming persistence, with separate system/home entry files |
| [home/packages.nix](home/packages.nix)            | User packages without dedicated configuration                       |
| [encrypted-secrets/](encrypted-secrets/)          | SOPS ciphertext                                                     |
| [AGENTS.md](AGENTS.md)                            | Repository working rules                                            |

Start with the two root entry files. Related settings live together; scripts,
styles and icons stay beside their feature. Disabled imports are drafts, not
active features. Configuration is authoritative; the inventory describes it.

## Change and validate

Work from `/saved/nixos-config`. Inspect existing changes before editing:

```sh
git status --short
git diff
nix fmt
git diff --check
nix flake check
nh os build /saved/nixos-config
```

New files must be visible to Git for flake evaluation; use `git add -N <path>`
when preparing an uncommitted change. Builds do not activate a configuration.

After reviewing the diff and successful build, temporarily activate when ready:

```sh
sudo nh os test /saved/nixos-config
```

Check the affected behavior while keeping an authenticated terminal and a
known-good boot generation available. After acceptance, make it persistent:

```sh
sudo nh os switch /saved/nixos-config
```

Boot, kernel and driver changes require a reboot test. A build or temporary
activation does not establish boot, suspend/resume or recovery acceptance.

For dependency updates, select inputs deliberately, inspect `flake.lock`, and
repeat validation. Flatpak applications follow their declared remotes separately;
their versions are not pinned or rolled back by the NixOS generation.

## Persistence and secrets

Root is temporary. `/nix`, `/saved`, encrypted disk swap and the EFI partition
survive reboot. [Disk layout](system/storage/disks.nix) owns mounts;
[persistence](system/storage/persistence.nix) owns retained state.
**Downloads is temporary.** Store work in persistent locations.

Before adding or changing a persistence mount, stop the owning application or
service and migrate existing data into the saved backing directory. An empty
backing directory can hide the original data. Verify ownership, writes and
survival across reboot. Flatpak profile selection comes from the
[app catalog](system/desktop/flatpak/apps.nix); external libraries need their own
persistent location. A per-user Flatpak installation can take precedence over a
managed system copy; verify the intended installation before retiring a test copy.

Commit encrypted secrets only. The deployment age identity belongs at
`/saved/var/lib/sops-nix/key.txt`; provision it independently before deploying
secret consumers. Back it up separately: generating another identity cannot
decrypt existing ciphertext. Secrets are rendered under `/run/secrets`.

The [secret helper](home/secrets.nix) supports `secret list`, `secret status`,
`secret add`, `secret add-token` and `secret edit`. Declare consumers in
[system secrets](system/security/secrets.nix), use runtime file paths, and keep
plaintext out of Git and the Nix store.

## Recovery

A temporary test activation leaves the previous boot default in place. For a
failed boot, choose a known-good generation in systemd-boot. Preserve a usable
generation before cleanup and retain independent installation/recovery media.

Generations restore system configuration and packages. Persistence retains
selected state across reboots. Neither replaces an independent data backup.
Keep age and LUKS recovery material usable without this laptop and prove a restore.
Never use Disko installation or formatting commands as a validation step.
