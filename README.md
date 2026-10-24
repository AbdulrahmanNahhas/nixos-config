# Shadow

Personal NixOS and Home Manager configuration for Aqua's Razer Blade 14
(`RZ09-0530`, x86_64 Linux). One host, one user, direct module imports.

[Technology roadmap](ROADMAP.md) · [References](REFERENCES.md)

## System

| Area | Setup |
| --- | --- |
| Base | NixOS unstable, pinned flake inputs, Home Manager |
| Desktop | Niri, Noctalia, greetd/tuigreet, Ghostty, Fish |
| Graphics | AMD Radeon 880M for the desktop; NVIDIA RTX 5060 for offload |
| Storage | LUKS2 + Btrfs, Disko layout, Preservation, temporary root |
| Network | NetworkManager with iwd, local DNSCrypt resolver, inbound firewall |
| Secrets | SOPS + age through sops-nix; ciphertext in Git |
| Applications | Nix packages and a declarative Flatpak catalog |
| Development | Zed, Delta, devenv, direnv, Nix language tools |

These describe repository declarations. Check the running host after activation.
`system.stateVersion` and `home.stateVersion` preserve compatibility defaults;
they do not identify the installed NixOS release. `flake.lock` pins dependencies.

## Repository

| Path | Owns |
| --- | --- |
| [`flake.nix`](flake.nix) / [`flake.lock`](flake.lock) | Inputs, host output, formatter, secret scan |
| [`shadow/default.nix`](shadow/default.nix) | Hardware imports, system module selection, build limits |
| [`shadow/home.nix`](shadow/home.nix) | User identity and Home Manager module selection |
| [`shadow/disk.nix`](shadow/disk.nix) | Disk layout and persistent mounts |
| [`modules/nixos/`](modules/nixos/) | Boot, hardware, networking, security, storage, services |
| [`modules/home/`](modules/home/) | Desktop, programs, shell, editor, key bindings |
| [`modules/nixos/services/flatpak-apps.nix`](modules/nixos/services/flatpak-apps.nix) | Flatpak IDs, permissions, persistence selection |
| [`modules/nixos/storage/preservation.nix`](modules/nixos/storage/preservation.nix) | Saved files, directories, ownership and bootstrap rules |
| [`encrypted-secrets/`](encrypted-secrets/) | SOPS ciphertext |

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

Update selected dependencies deliberately, then repeat the checks:

```sh
nix flake update nixpkgs home-manager
git diff -- flake.lock
```

Nix builds allow two concurrent derivations with four cores each. Weekly cleanup
retains at least three generations and generations from the last seven days,
while preserving explicit GC roots. Keep a known-good generation before cleanup.
Flatpak updates have their own lifecycle.

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
The exact list belongs in
[`preservation.nix`](modules/nixos/storage/preservation.nix).

Before activating a new persistence entry, migrate existing data into the matching
path under `/saved`. Stop the owning service while copying, preserve permissions,
and use a coherent backup for an active database. An empty backing mount can hide
existing state. Removing an entry leaves the old backing data in place.

**Pending host acceptance:** the retained Btrfs, SMART and power-profile state
at `/var/lib/btrfs`, `/var/lib/smartmontools` and
`/var/lib/power-profiles-daemon` still needs migration where data exists, mount
checks, service write checks and reboot verification. Earlier network, firmware
and Nix-cache entries also need verification if they have not been migrated.
See [storage work](ROADMAP.md#disk--filesystem-architecture).

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
