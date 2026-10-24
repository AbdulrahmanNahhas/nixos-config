# References

[System](README.md) · [Technology roadmap](ROADMAP.md)

Start with nix.dev for learning, the manuals for precise behavior, and option search
for declarations. This repository tracks unstable; stable manuals may describe a
different revision. Check `flake.lock` and upstream source when behavior differs.

## Nix and NixOS

| Reference | Use |
| --- | --- |
| [nix.dev](https://nix.dev/) | Official tutorials: language, modules, packaging and reproducible environments |
| [NixOS manual](https://nixos.org/manual/nixos/stable/) | Installation, system configuration, services, upgrades and recovery |
| [Nix manual](https://nixos.org/manual/nix/stable) | Nix commands, expressions, store, configuration and flakes |
| [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable) | Packages, overlays, overrides, library and module system |
| [NixOS option search](https://search.nixos.org/options) | Option types, defaults and declaration locations; select the relevant channel |
| [NixOS package search](https://search.nixos.org/packages) | Package attributes and versions |
| [NixOS Wiki](https://wiki.nixos.org/) | Community recipes and hardware guidance; check against current options |
| [Nixmap by Vimjoyer](https://vimjoyer.com/nixmap/) | Visual learning path through Nix, NixOS, Home Manager and flakes |
| [Nix Software](https://nixsoftware.org/en) | Browse applications available through Nix |
| [Awesome Nix](https://github.com/nix-community/awesome-nix) | Curated community tools and learning resources |
| [nix-community](https://github.com/nix-community) | Community projects, modules and maintenance |

## Configuration and state

| Reference | Use |
| --- | --- |
| [Home Manager manual](https://nix-community.github.io/home-manager/) | User modules and managed configuration |
| [Disko](https://github.com/nix-community/disko) | Declarative disk layout and installation tooling |
| [Preservation](https://github.com/nix-community/preservation) | Selected persistent state over an ephemeral root |
| [nixos-hardware](https://github.com/NixOS/nixos-hardware) | Machine-specific hardware modules |
| [nh](https://github.com/nix-community/nh) | Build, test, switch and generation cleanup |
| [devenv](https://devenv.sh/) | Project environments and services |
| [direnv](https://direnv.net/) | Directory-specific environment loading |
| [Btrfs documentation](https://btrfs.readthedocs.io/) | Subvolumes, scrub, snapshots and recovery |
| [systemd manuals](https://www.freedesktop.org/software/systemd/man/latest/) | Units, timers, boot, tmpfiles and sandboxing |
| [Restic documentation](https://restic.readthedocs.io/en/stable/) | Candidate encrypted backups and restore workflows |

## Secrets and security

| Reference | Use |
| --- | --- |
| [SOPS documentation](https://getsops.io/docs/) | Encrypt, edit, rotate and manage secret files |
| [age](https://github.com/FiloSottile/age) | Encryption identities, recipients and command-line usage |
| [sops-nix](https://github.com/Mic92/sops-nix) | NixOS secret provisioning and runtime templates |
| [USBGuard](https://github.com/USBGuard/usbguard) | USB authorization policy and upstream documentation |
| [Lanzaboote](https://nix-community.github.io/lanzaboote/) | Candidate Secure Boot setup and recovery planning |

## Networking

| Reference | Use |
| --- | --- |
| [WireGuard](https://www.wireguard.com/) | Tunnel concepts and protocol documentation |
| [NetworkManager.conf](https://www.networkmanager.dev/docs/api/latest/NetworkManager.conf.html) | Global connection, DNS and device configuration |
| [DNSCrypt](https://dnscrypt.info/) | Encrypted DNS protocol, software and resolver information |
| [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) | Resolver configuration and troubleshooting |
| [dnscrypt-proxy example configuration](https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml) | Setting names, defaults and resolver-selection rules |

## Desktop and applications

| Reference | Use |
| --- | --- |
| [Flatpak documentation](https://docs.flatpak.org/en/latest/index.html) | Runtimes, permissions, portals and command reference |
| [nix-flatpak](https://github.com/gmodena/nix-flatpak) | Declarative Flatpak installation and overrides |
| [Niri documentation](https://niri-wm.github.io/niri/) | Layout, input, outputs, key bindings and window rules |
| [Noctalia documentation](https://docs.noctalia.dev/) | Shell, launcher, lock screen and desktop controls |
| [Zed documentation](https://zed.dev/docs) | Editor settings, language tools, tasks and agents |
| [Ghostty documentation](https://ghostty.org/docs) | Terminal configuration and troubleshooting |
| [Fish documentation](https://fishshell.com/docs/current/) | Interactive shell, functions and scripting |
| [PipeWire documentation](https://docs.pipewire.org/) | Audio/video transport and configuration |
| [WirePlumber documentation](https://pipewire.pages.freedesktop.org/wireplumber/) | Media-session policy |

Release feeds for the main components are grouped in the
[roadmap watchlist](ROADMAP.md#release-watch). A project appearing here is a reading
reference, not a decision to install it.
