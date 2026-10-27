# Technology roadmap

[System](README.md) · [References](REFERENCES.md)

Reviewed against repository source on **2026-10-21**. Technologies are grouped
by area, with proposed work beside the area it affects.

| Mark         | Meaning                                                           |
| ------------ | ----------------------------------------------------------------- |
| ✓ Configured | Explicit declaration exists; host acceptance may still be pending |
| ? Verify     | Inherited, hardware-dependent or runtime behavior needs evidence  |
| — Candidate  | Not enabled here; evaluate only when useful                       |
| ○ Watch      | Follow upstream; no adoption commitment                           |

P0 is the first recovery priority; P1 covers reliability and measurement; P2 covers
security follow-up; P3 is conditional. Candidates are possibilities, not a promise
to install everything. These are manually maintained source snapshots, not live checks.

## Start here

1. [Choose an independent backup and prove a restore](#backups).
2. [Migrate and verify the declared maintenance state](#maintenance-state).
3. [Measure battery behavior](#battery-baseline) and [test resume](#resume).
4. [Rehearse Signal key storage](#signal-key-storage), then [adopt the update policy](#update-policy).

## Release watch

Follow changes before updating the corresponding pins or applications.

- [systemd](https://github.com/systemd/systemd/releases)
- [Btrfs + btrfs-progs](https://btrfs.readthedocs.io/en/latest/CHANGES.html)
- [Linux kernel](https://kernel.org/)
- [NixOS & Nix](https://nixos.org/blog/announcements/)
- [Wayland](https://wayland.freedesktop.org/releases.html)
- [Wayland protocols](https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases)
- [Niri](https://github.com/niri-wm/niri/releases)
- [Noctalia](https://github.com/noctalia-dev/noctalia/releases)
- [Flatpak](https://github.com/flatpak/flatpak/releases)

## Firmware & boot security

| Status       | Technology                                                                                                        | Purpose                                                                                        |
| ------------ | ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| ? Verify     | [Coreboot / Libreboot](https://coreboot.org/)                                                                     | Open firmware alternatives; compatibility with this Razer hardware is unverified.              |
| ✓ Configured | [systemd-boot + systemd initrd](modules/nixos/core/boot.nix)                                                      | UEFI boot menu, generation fallback and systemd early boot.                                    |
| ✓ Configured | [USBGuard](modules/nixos/security/baseline.nix)                                                                   | Authorize USB devices through an explicit allowlist.                                           |
| — Candidate  | [Lanzaboote + UKI / measured boot](https://nix-community.github.io/lanzaboote/)                                   | Candidate for signed boot and measured unlock; requires firmware and key recovery planning.    |
| — Candidate  | [TPM2 / FIDO2 unlock + pam_u2f](https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html) | Optional disk unlocking and security-key authentication; no enrollment or PAM policy declared. |
| ? Verify     | Boot & key recovery                                                                                               | Verify independent recovery media, encryption credentials and a known-good boot generation.    |

<a id="secure-boot"></a>

### P2: Evaluate Lanzaboote Secure Boot

**Next:** After backup, resume and update-policy acceptance, check firmware recovery, vendor keys and ESP capacity. Build signed artifacts before considering key enrollment.

**Done when:** Recover independently; verify signed boot, NVIDIA/OpenRazer, boot rollback and protected PKI backup.

Firmware enrollment can prevent boot. TPM unlock needs a separate threat-model and recovery decision.

## Disk & filesystem architecture

| Status       | Technology                                                             | Purpose                                                                                                                             |
| ------------ | ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| ✓ Configured | [LUKS + Btrfs](shadow/disk.nix)                                        | Encrypted persistent storage with subvolumes, compression and checksums; ESP remains outside LUKS.                                  |
| ✓ Configured | [Disko + Preservation](shadow/disk.nix)                                | Declarative disk layout and explicit persistence over a temporary root.                                                             |
| — Candidate  | [Snapper / btrbk](https://digint.ch/btrbk/)                            | Optional snapshot scheduling, retention and replication; neither is configured.                                                     |
| ✓ Configured | [Btrfs scrub + SMART monitoring](modules/nixos/storage/default.nix)    | Scheduled checksum verification and drive-health monitoring with retained progress/state; verify completed runs and alert delivery. |
| ✓ Configured | [zRAM + encrypted disk swap + TRIM](modules/nixos/storage/default.nix) | Compressed RAM swap, disk overflow and periodic SSD maintenance.                                                                    |

<a id="maintenance-state"></a>

### P1: Persistence and maintenance acceptance

**Next:** Before activation, migrate existing Btrfs, SMART and PPD state into the matching saved directories while the owning service is stopped. Inspect mounts, write access, missed timers and notification delivery.

**Done when:** Complete a scrub, receive a test warning, and confirm the selected profile and relevant history survive reboot.

An empty backing mount can hide existing data. Single-device scrub detects damage without guaranteeing repair.

## Kernel, drivers & power

| Status       | Technology                                                                 | Purpose                                                                                                                                               |
| ------------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| ✓ Configured | [Linux latest kernel](modules/nixos/core/boot.nix)                         | Track modern hardware support; retain a working generation when updating.                                                                             |
| ✓ Configured | [NVIDIA open driver · latest channel](modules/nixos/hardware/graphics.nix) | RTX support and offload; runtime GPU sleep must be checked after workloads and resume.                                                                |
| ✓ Configured | [Kernel mitigations + AppArmor](modules/nixos/core/boot.nix)               | Kernel access and sticky-directory restrictions, discarded kernel crash dumps, and AppArmor support; enablement does not imply full profile coverage. |
| ? Verify     | AMD microcode + PRIME / RTD3                                               | Hardware-dependent and inherited settings; confirm effective options and runtime behavior.                                                            |
| ✓ Configured | [Power Profiles Daemon + AMD P-state](modules/nixos/services/power.nix)    | Desktop power profiles and CPU energy preference; UPower supplies battery state.                                                                      |
| — Candidate  | TLP / TuneD / auto-cpufreq                                                 | Alternative policy backends; compare only if the current backend has a measured gap.                                                                  |
| ✓ Configured | [systemd service sandboxing](modules/nixos/services/kavita.nix)            | Kavita has explicit restrictions; service hardening is applied per service.                                                                           |

<a id="battery-baseline"></a>

### P1: Repeatable battery baseline

**Next:** Compare balanced and power-saver profiles at fixed brightness and workload, using the display’s advertised 60/120 Hz modes. Record repeated power and task-energy measurements.

**Done when:** Retain responsiveness, confirm GPU sleep, and restore the original mode/profile.

Measure before changing policy; a single watt reading is not an endurance test.

<a id="resume"></a>

### P1: GPU sleep and suspend/resume

**Next:** After the battery baseline, check both GPU PCI functions after offload, external-display disconnect and resume. Test locking, Wi-Fi, audio and overnight unplugged drain.

**Done when:** Keep the session and lock intact, reproduce acceptable drain, and return the dGPU to runtime suspension after workloads.

Save work before testing. Do not force unsupported deep sleep or hibernation.

<a id="power-alternative"></a>

### P3: Trial another power backend if needed

**Next:** Only after baseline and resume checks show a gap, inspect pinned TuneD/TLP integration and shell compatibility. Trial one backend with rollback to PPD.

**Done when:** Show repeatable energy savings without resume, USB, audio, Wi-Fi or responsiveness regressions.

Keep PPD until an alternative earns the change; do not stack competing policy daemons.

## Core systems, networking & security

| Status       | Technology                                                                          | Purpose                                                                                                         |
| ------------ | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| ✓ Configured | [NixOS & Nix](flake.nix)                                                            | Declarative builds, pinned dependencies and system generations.                                                 |
| ✓ Configured | [Home Manager + sops-nix](shadow/default.nix)                                       | User configuration and encrypted declarative secrets.                                                           |
| ✓ Configured | [NetworkManager + DNSCrypt + firewall](modules/nixos/networking/networkmanager.nix) | Network connections, encrypted DNS and inbound filtering.                                                       |
| ? Verify     | WireGuard tunnel                                                                    | Secret material is prepared for NetworkManager import; an active tunnel is not established by that declaration. |
| ✓ Configured | [sudo-rs + USB authorization](modules/nixos/security/baseline.nix)                  | Rust sudo implementation and user-controlled device authorization.                                              |
| ✓ Configured | [BlueZ / Bluetooth](modules/nixos/hardware/bluetooth.nix)                           | Bluetooth support with the radio disabled at boot.                                                              |
| — Candidate  | OpenSnitch / nftables custom policy                                                 | Optional outbound application filtering or custom packet rules; no such policy declared.                        |

<a id="security-edges"></a>

### P2: Session and network protections

**Next:** Use a fresh login after activation to check device access, portals and calls. Restart the desktop agent after the retired managed policy and verify Git reads and approved development commands. Inspect AppArmor coverage, reproduce the PAM workaround, and check VPN IPv4/IPv6 routes and DNS.

**Done when:** Record effective protections and necessary exceptions with a reproducible test for removing each workaround.

Authentication, DNS and USB policy changes need an authenticated recovery terminal.

<a id="signal-key-storage"></a>

### P1: Signal database-key storage

**Next:** Back up the closed Signal profile and keyring to protected persistent storage. Rehearse a gnome-libsecret migration separately before changing the live backend.

**Done when:** Read existing messages across two launches and a reboot, verify the intended keyring backend, and retain a usable rollback.

Check the installed Flatpak’s current key backend and migration warnings before acting; never reset the profile.

## Display, graphics & audio

| Status       | Technology                                                 | Purpose                                                                                                     |
| ------------ | ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| ? Verify     | Wayland + Mesa                                             | Compositor display infrastructure and integrated-GPU graphics; confirm effective driver stack.              |
| ○ Watch      | Wayland protocols                                          | Follow HDR, color management, capture and scaling support; protocol availability is not feature acceptance. |
| ✓ Configured | [PipeWire + WirePlumber](modules/nixos/services/audio.nix) | Audio/video transport and session policy; PipeWire is explicitly enabled.                                   |

## Desktop & application runtimes

| Status       | Technology                                                               | Purpose                                                                                                         |
| ------------ | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------- |
| ✓ Configured | [Niri](modules/nixos/desktop/niri.nix)                                   | Scrollable tiling compositor with an integrated-GPU rendering preference.                                       |
| ✓ Configured | [Noctalia v5 · shell, lock & idle](modules/home/wm/noctalia/default.nix) | Launcher, notifications, system controls and session locking; verify lock and wake behavior.                    |
| ✓ Configured | [Flatpak + nix-flatpak / Bubblewrap](modules/nixos/services/flatpak.nix) | Sandboxed app distribution with explicit filesystem allowlists and credential-path denials.                     |
| ✓ Configured | [Nahhasio Flatpak](modules/nixos/services/flatpak-apps.nix) | Signed alpha remote, branch updates, scoped media access and derived profile persistence; pending profile migration, system installation and host verification. |
| ? Verify     | XDG portals + keyring + Polkit / user session                            | Desktop integration, credential storage, authorization and service lifecycle; verify actual routing and agents. |
| ✓ Configured | [Steam / Proton + Xwayland-satellite](modules/nixos/gaming/steam.nix)    | Gaming compatibility and X11 support under Niri.                                                                |
| ? Verify     | nix-ld / external binaries                                               | Runtime library compatibility inherited from external modules; inspect effective settings.                      |
| — Candidate  | [Gamescope](https://github.com/ValveSoftware/gamescope)                  | Optional gaming compositor and presentation controls; not declared.                                             |

## Nix tooling & workflow

| Status       | Technology                                                                        | Purpose                                                                                                                                                                                       |
| ------------ | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ✓ Configured | [nh + generation maintenance](modules/nixos/core/nix.nix)                         | Build, test, switch, search and retained-generation cleanup.                                                                                                                                  |
| ✓ Configured | [Zed · Java / C / C++](modules/home/programs/zed/extensions.nix)                  | JDTLS with a project-provided Java runtime and built-in clangd support; project environments own build toolchains and compiler flags.                                                         |
| ✓ Configured | [devenv + direnv](modules/home/shell/development.nix)                             | Native Fish environment activation with direct direnv loading in Zed; nix-direnv disabled.                                                                                                    |
| ✓ Configured | [Starship + Fish prompt](modules/home/shell/fish/starship.nix)                    | Rounded two-line prompt, language versions aligned right, and command separation without a leading blank line after clearing; local trial reviewed, declarative activation remains to verify. |
| ✓ Configured | [nixd + nixfmt + statix / deadnix](modules/home/packages/development.nix)         | Nix language support, consistent formatting and linting.                                                                                                                                      |
| — Candidate  | [nix-index-database + comma](https://github.com/nix-community/nix-index-database) | Candidate for finding and running commands without permanently installing packages.                                                                                                           |
| — Candidate  | [nom + nvd](https://github.com/maralorn/nix-output-monitor)                       | Optional build-progress display and generation package comparisons.                                                                                                                           |
| ✓ Configured | [Pinned inputs + flake checks](flake.nix)                                         | Locked dependencies and configured flake checks; a declared check is not a recorded passing run.                                                                                              |

## Backup & maintenance

| Status       | Technology                                                                                       | Purpose                                                                                                    |
| ------------ | ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| ✓ Configured | [Nix store optimisation + cleanup](modules/nixos/core/nix.nix)                                   | Scheduled deduplication and generation retention; cleanup yields CPU and I/O priority to interactive work. |
| ✓ Configured | [Persistent journal, identity & keys](modules/nixos/security/baseline.nix)                       | Retain bounded logs and selected machine/security state across ephemeral-root reboots.                     |
| — Candidate  | [Restic / Borg + restore verification](https://restic.readthedocs.io/en/stable/050_restore.html) | Independent encrypted backups and recovery drills; no automated backup job is declared.                    |
| — Candidate  | [vulnix / Trivy / Grype](https://github.com/nix-community/vulnix)                                | Optional vulnerability scanning; results require applicability and false-positive review.                  |

<a id="backups"></a>

### P0: Encrypted off-device backup

**Next:** Choose a destination, quota, retention and independent recovery credentials. Inventory documents, projects, password databases, age/LUKS recovery material and app state before adding a backup module.

**Done when:** Restore selected files and recovery material without relying on Shadow. Keep the rehearsal separate from live data.

Choose storage and recovery arrangements first; persistence and generations cannot recover a lost SSD.

<a id="update-policy"></a>

### P1: Reviewed updates and generation retention

**Next:** After backup acceptance, adopt a weekly input/security review, targeted dependency updates and post-reboot checks. Inspect cleanup retention before deleting generations; review Flatpak updates separately.

**Done when:** Pass build, activation and boot checks while keeping a known-good generation reachable.

Latest kernel, NVIDIA and unstable inputs need a reproducible recovery path.

## Technology watch

| Status  | Technology                                                                               | Purpose                                                                                              |
| ------- | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| ○ Watch | [Rust in Linux / uutils + Landlock](https://docs.kernel.org/userspace-api/landlock.html) | Follow memory-safe systems work and unprivileged sandboxing; not a claim of deployment here.         |
| ○ Watch | [GNOME ecosystem](https://release.gnome.org/)                                            | Follow desktop, portal, graphics and accessibility developments relevant to the selected stack.      |
| ○ Watch | [LibrePhone](https://www.fsf.org/campaigns/librephone)                                   | Follow the FSF effort toward a free mobile software ecosystem; external to the laptop configuration. |

## Maintaining this roadmap

Change status with its configuration change. A successful build proves the build;
record host tests separately before claiming activation, recovery or runtime health.
Keep operating details in [README.md](README.md) and general reading links in
[REFERENCES.md](REFERENCES.md).
