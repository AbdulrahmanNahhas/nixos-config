# Shadow NixOS configuration

Declarative NixOS and Home Manager configuration for `shadow`, a Razer Blade
14 (2025). The root filesystem is tmpfs; LUKS2 protects a Btrfs filesystem whose
`/nix` and `/saved` subvolumes retain selected state.

## Hardware

| Component | Detail |
| --- | --- |
| CPU | AMD Ryzen AI 9 365 |
| GPU | AMD Radeon 880M and NVIDIA RTX 5060 Max-Q |
| RAM | 16 GB LPDDR5X |
| Disk | NVMe at `/dev/nvme0n1` |

## Current features

- Niri with Noctalia as the only desktop session, launched by greetd/tuigreet.
- Selected GNOME/GTK applications with declarative preferences and Files
  bookmarks, without GNOME Shell or its extension stack.
- PipeWire, NetworkManager, DNSCrypt Proxy, Bluetooth, OpenRazer, fwupd,
  declarative Flatpak, standard Steam, and Kavita.
- OpenSSH, printing, scanning, ModemManager, and usbmuxd are disabled.
- The firewall is enabled. Only Kavita's `8083/tcp` opening on `wlan0` is
  active; SimpleX and GSConnect rules remain commented out.
- Preservation retains explicitly selected system and Aqua state under
  `/saved`; everything else on root is lost at reboot.

## Architecture

`flake.nix` constructs the host. `hosts/shadow` owns machine facts and selects
NixOS profiles. Profiles compose reusable modules, while `home/aqua` owns Aqua's
identity and Home profile selection.

```text
flake.nix -> hosts/shadow -> profiles/nixos -> modules/nixos
                         -> home/aqua -> profiles/home -> modules/home
```

See [architecture](docs/architecture.md) for the full layout and dependency
rules. See the [development environment guide](docs/development.md) for the
Zed, devenv, direnv, Rust, and web-tooling workflow.

## Installation

The Disko installation procedure destroys the target disk. Review the device,
layout, credentials, and persistence policy first. Follow the dedicated
[installation guide](docs/installation.md); do not run its destructive commands
as ordinary validation.

## Maintenance

```sh
sudo nh os switch /saved/nixos-config
nix flake check
nix eval .#nixosConfigurations.shadow.config.system.build.toplevel.drvPath
```

`nh` assumes this repository lives at `/saved/nixos-config`. Its scheduled
Friday cleanup keeps the three newest generations while preserving explicit GC
roots such as direnv/devenv environments (`--keep 3 --no-gcroots`).

## Security status

- **Implemented:** LUKS2 disk encryption, tmpfs root, firewall, DNSCrypt Proxy,
  randomized Wi-Fi MAC addresses, and explicit persistence.
- **Partially implemented:** Flatpak application isolation and a small baseline
  security module; neither is a complete confinement strategy.
- **Planned:** AppArmor, Secure Boot, further service hardening, snapshots,
  backups, and TPM-assisted unlock.
- **Researching:** hardened-kernel/NVIDIA compatibility and future NixOS
  specialisations.
- **Postponed:** no additional security mechanism is claimed active until its
  configuration exists and is imported.

Persisting logs, core dumps, browser caches, Flatpak state, and application
state improves continuity but retains sensitive activity across reboots. See
[security](docs/security.md) and [persistence](docs/persistence.md).

## Roadmap

Security changes are intentionally separated from this structural layout.
Priorities include removing plaintext initial passwords, reducing Nix trust,
reviewing DNS and firewall assumptions, and adding tested recovery and backup
procedures. See the [roadmap](docs/roadmap.md).
