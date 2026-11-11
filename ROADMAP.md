# Roadmap

[Project guide](README.md) · [References and notes](REFERENCES.md)

Daily-driver priorities: performance, security and modern technology without
unnecessary disruption. Checked = configured, not necessarily live-tested.
[🎯 Planned] = intended work · [🔎 Considering] = evaluate before deciding ·
[📖 Learning] = configured, but understanding and management are unfinished.

## ⚙ System foundation

- [x] **[NixOS](https://nixos.org/manual/nixos/stable/)** — declarative system on pinned Nixpkgs unstable.
- [x] **[Nix flakes](https://nix.dev/concepts/flakes)** — locked dependencies and an explicit host configuration.
- [x] **[Home Manager](https://nix-community.github.io/home-manager/)** — user environment and settings deployed with the system.
- [x] **[nh](https://github.com/nix-community/nh)** — build, test, switch and interactive cleanup.
- [x] **[systemd](https://systemd.io/)** — boot/initrd, services, timers and resource control.
- [ ] **[Userborn](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/system/userborn.nix)** [🔎 Considering] — newer account management; preserve UID history and SOPS password provisioning during migration.
- [ ] **[OverlayFS-backed /etc](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/etc/etc.nix)** [🔎 Considering] — mount-based configuration deployment; review Preservation and writable-overlay behavior. Experimental; read-only `/etc` is a separate choice.
- [ ] **[nixos-init](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/activation/nixos-init.nix)** [🔎 Considering] — bashless initialization after compatible account management and `/etc` overlay; existing activation hooks need review.
- [ ] **[Lix](https://lix.systems/add-to-config/)** [🔎 Considering] — alternative Nix implementation, primarily C++; compare compatibility and debugging before replacing Nix.
- [ ] **[Tvix](https://code.tvl.fyi/about/tvix) / [Snix](https://snix.dev/about/)** [🔎 Considering · research only] — Rust-based Nix components; neither is a production-ready, full drop-in replacement for this daily driver.

## 🧰 Nix workflow and development

- [x] **[devenv](https://devenv.sh/)** — project-specific toolchains and development environments.
- [x] **[direnv](https://direnv.net/)** — development-environment integration for editors.
- [ ] **[Comma](https://github.com/nix-community/comma) + [nix-index-database](https://github.com/nix-community/nix-index-database)** [🎯 Planned] — run `, command` with a prebuilt package index and `nix-locate`. Downloads use store space; index results may differ from pinned packages.
- [x] **[Cachix](https://docs.cachix.org/)** — consume the nix-community and devenv binary caches with configured signing keys; hosting or uploading to a personal cache is not configured.
- [ ] **[Flake Checker](https://github.com/DeterminateSystems/flake-checker)** [🎯 Planned] — Nixpkgs lock-file freshness and support policies, with telemetry disabled; complements `nix flake check`, not a build or security audit.
- [ ] **[GitHub Actions](https://docs.github.com/en/actions)** [🎯 Planned] — automatic formatting, `nix flake check` and Flake Checker feedback on pushes/PRs; scheduled checks can catch aging inputs. No automatic host activation; keep secrets out of logs.
- [ ] **[nix-inspect](https://github.com/bluskript/nix-inspect)** [🔎 Considering] — browse evaluated NixOS and Home Manager settings in a TUI.
- [ ] **[nix-tree](https://github.com/utdemir/nix-tree)** [🔎 Considering] — explore dependency closures and explain large store dependencies; inspection, not automatic cleanup.
- [ ] **[treefmt-nix](https://github.com/numtide/treefmt-nix)** [🔎 Considering] — extend `nix fmt` to Markdown, TOML and scripts without restructuring the repository.

## 💾 Storage and boot

No backups or snapshots are in place yet. The intended backup destination is an
external USB drive; neither persistence nor system generations replace backups.

- [x] **[Disko](https://github.com/nix-community/disko) + [LUKS](https://gitlab.com/cryptsetup/cryptsetup)** — declarative disk layout and encrypted persistent storage.
- [x] **[Btrfs](https://btrfs.readthedocs.io/)** — compressed subvolumes and scheduled scrubs; snapshots are not configured.
- [x] **[tmpfs](https://docs.kernel.org/filesystems/tmpfs.html)** — ephemeral root that resets on reboot.
- [x] **[Preservation](https://nix-community.github.io/preservation/)** — explicit system/user state retained under `/saved`; Downloads stays temporary.
- [x] **[systemd-boot](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html)** — boot selection and previous system generations; not personal-data recovery.
- [x] **[Plymouth](https://www.freedesktop.org/wiki/Software/Plymouth/)** — graphical startup and encrypted-disk unlock.
- [x] **[SMART](https://www.smartmontools.org/) / [TRIM](https://man7.org/linux/man-pages/man8/fstrim.8.html)** — drive-health monitoring and SSD maintenance.
- [x] **[zRAM](https://docs.kernel.org/admin-guide/blockdev/zram.html)** — compressed swap before encrypted disk overflow; no hibernation.
- [ ] **[Restic](https://restic.readthedocs.io/) / [Borg](https://www.borgbackup.org/)** [🎯 Planned · tool undecided] — encrypted backups to an external USB drive; choose retention, retain recovery keys separately and prove a restore without Shadow.
- [ ] **[Snapper](https://github.com/openSUSE/snapper)** [🔎 Considering] — snapshots of persistent Btrfs data for local recovery; choose coverage/retention and prove file recovery. Not a backup replacement.
- [ ] **[bcachefs](https://nixos.org/manual/nixos/unstable/release-notes.html)** [🔎 Considering] — filesystem alternative using an out-of-tree module on supported kernels; review recovery and kernel compatibility before considering migration.
- [ ] **[systemd Automatic Boot Assessment](https://systemd.io/AUTOMATIC_BOOT_ASSESSMENT/)** [🔎 Considering] — boot counting and fallback after unsuccessful boots; check NixOS and Lanzaboote compatibility. Does not roll back app data.
- [ ] **[NixOS recovery ISO](https://nix.dev/tutorials/nixos/building-bootable-iso-image)** [🔎 Considering] — independent LUKS/Btrfs rescue environment; include a known-good closure for offline recovery, never private keys.

## 🛡 Security and networking

- [ ] **[SOPS](https://getsops.io/docs/) + [sops-nix](https://github.com/Mic92/sops-nix)** [📖 Learning] — already declared; understand secret editing, recipients, key rotation and recovery. Keep plaintext out of Git and the store.
- [x] **[Linux hardening](https://wiki.nixos.org/wiki/Hardening)** — memory protections, restricted kernel access and strict IOMMU.
- [x] **[sudo-rs](https://github.com/trifectatechfoundation/sudo-rs)** — PAM-integrated privilege escalation.
- [x] **[USBGuard](https://usbguard.github.io/)** — explicit USB-device authorization.
- [x] **[AppArmor](https://apparmor.net/)** — confinement support; coverage depends on applied profiles.
- [x] **[GNOME Keyring](https://gitlab.gnome.org/GNOME/gnome-keyring)** — credential storage with login PAM integration.
- [x] **[NetworkManager](https://networkmanager.dev/docs/)** — managed connections, randomized Wi-Fi MACs and reduced hostname exposure.
- [x] **[dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy)** — encrypted upstream DNS and local caching.
- [x] **[NixOS firewall](https://wiki.nixos.org/wiki/Firewall)** — declarative inbound network policy.
- [ ] **[Secure Boot (Lanzaboote)](https://nix-community.github.io/lanzaboote/)** [🎯 Planned evaluation] — signed boot after recovery readiness; verify drivers, rollback and independent key recovery before separate enrollment.
- [ ] **[TPM2 / systemd-cryptenroll](https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html)** [🔎 Considering] — policy-bound LUKS unlocking, optionally with a PIN; decide the threat model and retain independent recovery before enrollment.

## 🖥 Desktop and hardware

- [x] **[Wayland](https://wayland.freedesktop.org/)** — Niri desktop with Noctalia integration; Umbriel as a secondary session.
- [x] **[Noctalia theming](https://docs.noctalia.dev/noctalia/theming/)** — wallpaper-derived palettes and enabled application templates.
- [x] **[PipeWire](https://docs.pipewire.org/)** — audio/video routing with WirePlumber session policy.
- [x] **[XDG portals](https://flatpak.github.io/xdg-desktop-portal/)** — sandbox integration, file access and screen sharing.
- [x] **[Flatpak](https://docs.flatpak.org/) / [nix-flatpak](https://github.com/gmodena/nix-flatpak)** — declarative apps, permissions and updates; versions follow remotes.
- [x] **[AppImage](https://docs.appimage.org/)** — direct execution through system binary-format support.
- [x] **[Xwayland](https://wayland.freedesktop.org/xserver.html)** — legacy X11 compatibility, with Xwayland Satellite available.
- [x] **[Proton](https://github.com/ValveSoftware/Proton)** — Windows-game compatibility with 32-bit graphics support.
- [x] **[AMD / NVIDIA PRIME](https://wiki.nixos.org/wiki/NVIDIA)** — integrated desktop rendering and discrete-GPU offload configuration.
- [x] **[power-profiles-daemon](https://upower.pages.freedesktop.org/power-profiles-daemon/)** — desktop power profiles; UPower supplies battery reporting.
- [x] **[fwupd](https://fwupd.org/)** — supported-device firmware updates with retained history.
