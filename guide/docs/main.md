# NixOS System & Technology Checklist

Legend:

- — Installed / Enabled
- — Not installed / Not enabled
- `[?]` — Needs verification
- `★` — Track major releases and developments
- `Monitored` — Follow technological progress

## 1. Firmware & Boot Security

| Status | Component                  | Purpose                                                           |
| ------ | -------------------------- | ----------------------------------------------------------------- |
| `[ ]`  | Libreboot / Coreboot       | Open-source firmware alternatives; require compatible hardware    |
| `[x]`  | USBGuard                   | Protect USB ports against unauthorized devices and BadUSB attacks |
| `[ ]`  | Lanzaboote + UKI           | Unified Kernel Images and UEFI Secure Boot integration            |
| `[ ]`  | systemd-cryptenroll        | TPM2/FIDO2-assisted LUKS disk unlocking                           |
| `[ ]`  | pam_u2f                    | Hardware security-key authentication for login and sudo           |
| `[?]`  | LUKS2 Full-Disk Encryption | Encrypt sensitive disk partitions and user data                   |
| `[?]`  | Boot Recovery Strategy     | Recovery USB, LUKS recovery keys, and bootloader fallback         |

## 2. Disk & Filesystem Architecture

| Status | Component               | Purpose                                                                   |
| ------ | ----------------------- | ------------------------------------------------------------------------- |
| `[x]`  | ★ Btrfs + btrfs-progs   | Copy-on-write filesystem, compression, snapshots, integrity, and recovery |
| `[x]`  | disko                   | Declarative disk partitioning, formatting, and encryption                 |
| `[x]`  | preservation            | Declarative persistence over an ephemeral root filesystem                 |
| `[ ]`  | Snapper                 | Automatic Btrfs snapshots, restoration, and cleanup                       |
| `[ ]`  | btrbk                   | Scheduled Btrfs snapshots, retention, and local/remote replication        |
| `[ ]`  | Btrfs Scrub Scheduling  | Periodic filesystem checksum verification                                 |
| `[ ]`  | SMART / NVMe Monitoring | Monitor SSD health, wear, and hardware errors                             |

## 3. Kernel, Drivers & OS Hardening

| Status      | Component                       | Purpose                                                                  |
| ----------- | ------------------------------- | ------------------------------------------------------------------------ |
| `[x]`       | ★ systemd                       | Init system, service management, boot infrastructure, and security       |
| `[x]`       | ★ Linux Latest Kernel           | Modern hardware support, CPU scheduling, memory management, and security |
| `[x]`       | NVIDIA Beta Driver              | Latest proprietary NVIDIA features and Wayland compatibility             |
| `[x]`       | `boot.initrd.systemd`           | Modern systemd-based early boot environment                              |
| `[x]`       | Sysctl Kernel Mitigations       | Harden kernel interfaces, BPF, pointer exposure, and debugging           |
| `[x]`       | AppArmor                        | Mandatory access control and application confinement                     |
| `[x]`       | zRAM Swap                       | Compressed memory-backed swap                                            |
| `[ ]`       | auto-cpufreq                    | Automatic CPU frequency and power optimization                           |
| `[ ]`       | Scudo Memory Allocator          | Hardened memory allocation for configured applications                   |
| `[ ]`       | Process Isolation (`hidepid=2`) | Restrict process information visibility between users                    |
| `[ ]`       | systemd Service Hardening       | Restrict service capabilities, filesystem access, and privileges         |
| `[?]`       | AMD CPU Microcode               | Processor security, stability, and compatibility updates                 |
| `[?]`       | Power Profiles Daemon / TuneD   | Laptop performance, balanced, and power-saving profiles                  |
| `[?]`       | NVIDIA PRIME Offload            | Hybrid GPU switching and on-demand NVIDIA acceleration                   |
| `Monitored` | Rust in Linux Kernel / uutils   | Memory-safe kernel components and userspace utilities                    |
| `Monitored` | Landlock LSM                    | Unprivileged application sandboxing and access restrictions              |

## 4. Core Systems, Networking & Security

| Status | Component      | Purpose                                                                                |
| ------ | -------------- | -------------------------------------------------------------------------------------- |
| `[x]`  | ★ NixOS & Nix  | Declarative operating system, reproducible builds, generations, and package management |
| `[x]`  | Home Manager   | Declarative user environments and dotfile management                                   |
| `[x]`  | sops-nix       | Encrypted declarative secrets management                                               |
| `[x]`  | WireGuard      | Modern encrypted VPN networking                                                        |
| `[x]`  | dnscrypt-proxy | Encrypted DNS resolution and optional filtering                                        |
| `[x]`  | sudo-rs        | Memory-safe Rust implementation of sudo                                                |
| `[x]`  | D-Bus Broker   | High-performance system and desktop message bus                                        |
| `[ ]`  | OpenSnitch     | Application-level outbound network firewall                                            |
| `[ ]`  | nftables       | Modern Linux packet filtering and firewall infrastructure                              |
| `[?]`  | NixOS Firewall | Host-level network traffic filtering                                                   |
| `[?]`  | NetworkManager | Wi-Fi, Ethernet, and VPN connection management                                         |
| `[?]`  | BlueZ          | Bluetooth devices and wireless peripherals                                             |
| `[?]`  | UPower         | Battery, charging, and power-state information                                         |

## 5. Display, Graphics & Audio

| Status | Component           | Purpose                                                                          |
| ------ | ------------------- | -------------------------------------------------------------------------------- |
| `[x]`  | Mesa                | Open-source GPU drivers, OpenGL, and Vulkan support                              |
| `[x]`  | ★ Wayland           | Modern display server protocol and graphical infrastructure                      |
| `[?]`  | ★ Wayland Protocols | Standardized HDR, color management, scaling, multi-GPU, and desktop capabilities |
| `[x]`  | PipeWire            | Modern audio, video, screen capture, and multimedia routing                      |
| `[x]`  | WirePlumber         | PipeWire session and device policy management                                    |

## 6. Desktop & Application Runtimes

| Status      | Component                            | Purpose                                                                 |
| ----------- | ------------------------------------ | ----------------------------------------------------------------------- |
| `[x]`       | ★ Niri                               | Modern scrollable-tiling Wayland compositor                             |
| `[x]`       | ★ Noctalia v5                        | Desktop shell, launcher, notifications, widgets, and system controls    |
| `[x]`       | XDG Desktop Portals                  | Secure application access to desktop resources                          |
| `[x]`       | Bubblewrap                           | Unprivileged application and filesystem sandboxing                      |
| `[x]`       | nix-flatpak                          | Declarative management of Flatpak applications                          |
| `[x]`       | Proton / Wine                        | Windows application and gaming compatibility                            |
| `[x]`       | nix-ld                               | Compatibility for non-Nix dynamically linked Linux binaries             |
| `[?]`       | ★ Flatpak / Future 2.0               | Sandboxed application distribution, permissions, runtimes, and security |
| `[?]`       | Xwayland-satellite                   | X11 application compatibility under Niri                                |
| `[?]`       | XDG Portal GTK + GNOME               | File dialogs, screen sharing, and desktop integration                   |
| `[?]`       | Secret Service / oo7 / GNOME Keyring | Secure application credential storage                                   |
| `[?]`       | Polkit Authentication Agent          | Graphical authorization for privileged actions                          |
| `[?]`       | Noctalia Session Lock                | Secure screen locking and idle-session protection                       |
| `[?]`       | niri-session / systemd User Session  | Desktop service lifecycle and session management                        |
| `[ ]`       | Gamescope                            | Isolated gaming compositor, scaling, and presentation controls          |
| `Monitored` | GNOME                                | Major desktop innovations and ecosystem developments                    |

## 7. Nix Tooling & Workflow

| Status | Component                               | Purpose                                                      |
| ------ | --------------------------------------- | ------------------------------------------------------------ |
| `[x]`  | nh                                      | Modern NixOS rebuilds, generations, cleanup, and search      |
| `[x]`  | nix-direnv                              | Automatic and cached Nix development environments            |
| `[x]`  | statix + deadnix                        | Nix code linting and unused-code detection                   |
| `[x]`  | Alejandra / nixfmt                      | Consistent formatting of Nix expressions                     |
| `[ ]`  | nix-index-database + comma              | Locate packages and temporarily execute uninstalled programs |
| `[ ]`  | nix-output-monitor (`nom`)              | Visual Nix build progress and diagnostics                    |
| `[ ]`  | nvd                                     | Compare packages between NixOS generations                   |
| `[x]`  | nixos-rebuild-ng                        | Modern NixOS configuration rebuilding implementation         |
| `[?]`  | Flake Locking / Pinned Inputs           | Reproducible system and application dependency versions      |
| `[ ]`  | `nix flake check` / Configuration Tests | Validate system configurations before deployment             |

## 8. Auditing, Backup & Maintenance

| Status | Component                          | Purpose                                                                       |
| ------ | ---------------------------------- | ----------------------------------------------------------------------------- |
| `[x]`  | Nix Store Optimise                 | Deduplicate Nix store files through hard-link optimization                    |
| `[ ]`  | Trivy / Grype                      | Vulnerability and CVE scanning for containers, SBOMs, and supported artifacts |
| `[ ]`  | Restic                             | Encrypted, deduplicated local and remote backups                              |
| `[ ]`  | vulnix                             | Nix-specific package vulnerability scanning                                   |
| `[?]`  | Automatic Generation Cleanup       | Manage old generations and Nix store disk usage                               |
| `[?]`  | Persistent systemd Journal         | Preserve system logs across reboots and ephemeral-root resets                 |
| `[?]`  | Persistent Machine Identity & Keys | Preserve critical system identity and cryptographic state                     |
| `[ ]`  | Backup Restore Verification        | Periodically test data and system recovery                                    |

## 9. External Ecosystem

| Status      | Component          | Purpose                                                    |
| ----------- | ------------------ | ---------------------------------------------------------- |
| `Monitored` | LibrePhone Project | Free and open-source mobile software ecosystem development |

## ★ Primary Release Watchlist

| Status | Component                                                                                | Purpose                                                               |
| ------ | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| ★      | [NixOS & Nix](https://nixos.org/blog/announcements/)                                     | OS architecture, package manager, reproducibility, and major releases |
| ★      | [Niri](https://github.com/niri-wm/niri/releases)                                         | Compositor features, rendering, and Wayland support                   |
| ★      | [Noctalia](https://docs.noctalia.dev/noctalia/changelogs/)                               | Desktop shell, features, and integration                              |
| ★      | [systemd](https://github.com/systemd/systemd/releases)                                   | Boot, services, security, and system management                       |
| ★      | [Linux Kernel](https://kernel.org/)                                                      | Hardware, scheduling, memory, filesystems, and security               |
| ★      | [Flatpak](https://github.com/flatpak/flatpak/releases)                                   | Application sandboxing, stable releases, and eventual 2.0             |
| ★      | [Wayland](https://wayland.freedesktop.org/releases.html)                                 | Core display infrastructure                                           |
| ★      | [Wayland Protocols](https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases) | HDR, color management, scaling, and new desktop protocols             |
| ★      | [Btrfs + btrfs-progs](https://btrfs.readthedocs.io/en/latest/CHANGES.html)               | Filesystem features, snapshots, integrity, and recovery               |
