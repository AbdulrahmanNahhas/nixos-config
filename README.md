# Shadow

Personal NixOS and Home Manager configuration for Aqua's Razer Blade 14
(`RZ09-0530`, x86_64 Linux). One host, one user, direct module imports.

[Technology roadmap](ROADMAP.md) · [References](REFERENCES.md)

## System

| Area         | Setup                                                              |
| ------------ | ------------------------------------------------------------------ |
| Base         | NixOS unstable, pinned flake inputs, Home Manager                  |
| Desktop      | Niri, Noctalia, greetd/tuigreet, Ghostty, Fish                     |
| Graphics     | AMD Radeon 880M for the desktop; NVIDIA RTX 5060 for offload       |
| Storage      | LUKS2 + Btrfs, Disko layout, Preservation, temporary root          |
| Network      | NetworkManager with iwd, local DNSCrypt resolver, inbound firewall |
| Secrets      | SOPS + age through sops-nix; ciphertext in Git                     |
| Applications | Nix packages and a declarative Flatpak catalog                     |
| Development  | Zed, Delta, devenv, direnv, Nix language tools                     |

These describe repository declarations. Check the running host after activation.
`system.stateVersion` and `home.stateVersion` preserve compatibility defaults;
they do not identify the installed NixOS release. `flake.lock` pins dependencies.

## Repository

| Path                                                                                 | Owns                                                    |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| [`flake.nix`](flake.nix) / [`flake.lock`](flake.lock)                                | Inputs, host output, formatter, secret scan             |
| [`shadow/default.nix`](shadow/default.nix)                                           | Hardware imports, system module selection, build limits |
| [`shadow/home.nix`](shadow/home.nix)                                                 | User identity and Home Manager module selection         |
| [`shadow/disk.nix`](shadow/disk.nix)                                                 | Disk layout and persistent mounts                       |
| [`modules/nixos/`](modules/nixos/)                                                   | Boot, hardware, networking, security, storage, services |
| [`modules/home/`](modules/home/)                                                     | Desktop, programs, shell, editor, key bindings          |
| [`modules/nixos/services/flatpak-apps.nix`](modules/nixos/services/flatpak-apps.nix) | Flatpak IDs, permissions, persistence selection         |
| [`modules/nixos/storage/preservation.nix`](modules/nixos/storage/preservation.nix)   | Saved files, directories, ownership and bootstrap rules |
| [`encrypted-secrets/`](encrypted-secrets/)                                           | SOPS ciphertext                                         |

`shadow/` selects system and user modules directly. Keep hardware facts there
and application assets beside their modules. Add another composition layer only
when another host or user needs a different selection.

## Change and validate

From `/saved/nixos-config`:

```sh
git status --short
git diff
nix fmt
git diff --check
nix flake check
nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link
```

Builds leave the running generation in place. Review the diff and build result
before activating:

```sh
sudo nh os test /saved/nixos-config
```

Test the affected behavior: fresh login and sudo, application data access,
DNS and VPN routing, or the relevant service. Keep an authenticated terminal
and a known-good boot generation available. After acceptance:

```sh
sudo nh os switch /saved/nixos-config
```

Kernel, initrd and driver changes also need a reboot into the selected generation.
A temporary activation cannot establish boot or suspend/resume acceptance.
The pinned nixpkgs uses systemd initrd without the removed
`boot.initrd.systemd.enable` selector. Preservation must include upstream fix
`717cdb87` or later so it no longer reads that removed option.

Update selected dependencies deliberately, then repeat the checks:

```sh
nix flake update nixpkgs home-manager
git diff -- flake.lock
```

Nix builds allow two concurrent derivations with four cores each. Weekly cleanup
retains at least three generations and generations from the last seven days,
while preserving explicit GC roots. Keep a known-good generation before cleanup.
Flatpak installation and updates are declared through `services.flatpak`.
NixOS activation updates the managed system applications, and a daily systemd
timer checks for further updates. These updates follow the declared remotes;
they are not pinned by `flake.lock` or rolled back with a NixOS generation.

Nahhasio is managed system-wide through the
[Flatpak catalog](modules/nixos/services/flatpak-apps.nix), using its signed
`nahhasio-alpha` remote and `alpha` branch. The repository descriptor and signing
key are pinned to the 0.1.1 release; activation and daily updates follow the alpha
branch rather than pinning the app version. Its permissions allow Wayland, audio,
GPU, network and `Videos/nahhasio` downloads. The Flatpak supplies its launcher and icon.

The earlier test installation is per-user and takes precedence over a system
installation when launching by app ID. After activation and verification of the
managed system copy, retire the test copy without deleting its app data. This
scope cleanup is separate from system configuration activation.

## Noctalia desktop and recording

[Desktop settings](modules/home/wm/noctalia/config.toml) declare the bar layout,
widgets, launcher, theme and wallpapers. The
[Noctalia module](modules/home/wm/noctalia/default.nix) supplies
`gpu-screen-recorder` and `slurp` for recording and region selection.
Recordings use `Videos/Recordings`, covered by the existing `Videos` persistence.

After activating the dependency change, restart Noctalia with
`systemctl --user restart noctalia.service` so it rechecks recorder availability.
Verify a short recording, stop it, and verify a second recording saves and plays.
For failures, inspect `journalctl --user -b -u noctalia.service` and
`~/.local/state/noctalia/screen_recorder/gpu-screen-recorder.log`.
`noctalia config validate` checks the active configuration, including persisted
settings overrides; those can differ from the repository declarations.

## Persistent state

```text
NVMe
├─ ESP → /boot
└─ LUKS2 → Btrfs
           ├─ /nix    package store
           ├─ /saved  repository, keys, selected system and user state
           └─ /swap   encrypted disk swap
RAM → /              4 GiB tmpfs, cleared on reboot
```

Preservation exposes selected saved paths where applications expect them.
Projects, documents, media, browser profiles, keyrings, editor state and selected
service state are retained. **Downloads is temporary.** Flatpak data selection
comes from the app catalog; external game libraries need their own persistence.
Nahhasio's catalog entry retains `.var/app/io.nahhasio.Linux`; downloaded media
under `Videos/nahhasio` is covered by the existing `Videos` entry. Its test profile
must be migrated into `/saved/home/aqua/.var/app/io.nahhasio.Linux` before first
activation of that new persistence mount, following the migration guidance below.
The exact list belongs in
[`preservation.nix`](modules/nixos/storage/preservation.nix).

**Pending host acceptance:** the retained Btrfs, SMART and power-profile state
at `/var/lib/btrfs`, `/var/lib/smartmontools` and
`/var/lib/power-profiles-daemon` still needs migration where data exists, mount
checks, service write checks and reboot verification. Earlier network, firmware
and Nix-cache entries also need verification if they have not been migrated.
See [storage work](ROADMAP.md#disk--filesystem-architecture).

To diagnose a full temporary filesystem, check its capacity and the largest
directories without crossing into persistent mounts:

```sh
df -h /home /tmp /saved
du -xhd2 /home /tmp 2>/dev/null | sort -h | tail -30
```

`/home` and `/tmp` currently share the same 4 GiB tmpfs allocation. The `-x`
option keeps saved bind mounts out of the totals. If `df` reports substantially
more usage than `du`, check for inaccessible directories or deleted files still
held open by running programs.

Persistence, snapshots and system generations each serve a different purpose.
An independent encrypted backup and a restore drill remain the first recovery
priority. Keep age and LUKS recovery material usable without this laptop.

## Secrets and recovery

Commit encrypted files only. The deployment age identity is provisioned at
`/saved/var/lib/sops-nix/key.txt`; it must exist before deploying encrypted users
and services. Back it up independently. A newly generated identity cannot decrypt
old ciphertext. Runtime secrets are rendered under `/run/secrets`.

The local `secret` helper manages ciphertext:

```sh
secret list
secret status
secret add example /private/path/example
secret add-token example
secret edit example
```

Keep plaintext outside the repository. Adding ciphertext also needs a declared
consumer in [`secrets.nix`](modules/nixos/security/secrets.nix). Use file-valued
runtime options; plaintext interpolated into Nix can enter the public Nix store.
Update the encrypted password hash for durable login-password changes.

For a failed temporary activation, reboot into the previous default generation.
For a failed boot, choose a known-good generation in systemd-boot. A generation
rollback restores configuration and packages; recovering documents, databases or
keys requires a data backup. Disko formatting erases storage and is never a test.

## Documentation

Maintain these three files with configuration changes:

- **README.md:** system layout, operating commands, persistence and recovery.
- **[ROADMAP.md](ROADMAP.md):** grouped technology status and outstanding work.
- **[REFERENCES.md](REFERENCES.md):** documentation, learning material and upstream links.

Keep comments brief and direct. Explain a constraint or workaround where it matters;
put longer explanations here. Update roadmap status only with source or host evidence.

Before committing, check local documentation links and run `git diff --check`.
Documentation changes need no system activation. Earlier documentation and
configuration history remain available in Git.
