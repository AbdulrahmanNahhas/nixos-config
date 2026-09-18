| Category                           | Status      | Component                  | Description                                                                            |
| ---------------------------------- | ----------- | -------------------------- | -------------------------------------------------------------------------------------- |
| **Firmware & Boot Security**       | `[ ]`       | Libreboot / Coreboot       | Open-source hardware firmware for root-of-trust boot security                          |
|                                    | `[x]`       | USBGuard                   | Firewall protecting USB ports against BadUSB and unauthorized device attacks           |
|                                    | `[ ]`       | Lanzaboote & UKI           | Unified Kernel Images enabling native UEFI Secure Boot                                 |
|                                    | `[ ]`       | systemd-cryptenroll        | Automated LUKS volume unlocking via hardware TPM2 chips                                |
|                                    | `[ ]`       | `pam_u2f`                  | Hardware FIDO2/YubiKey multi-factor authentication for login and `sudo`                |
| **Disk & Filesystem Architecture** | `[x]`       | disko                      | Declarative disk partitioning, formatting, and LUKS encryption management              |
|                                    | `[x]`       | Btrfs                      | Copy-on-write filesystem supporting subvolumes, compression, and snapshots             |
|                                    | `[x]`       | preservation               | Declarative file persistence over an ephemeral tmpfs root filesystem                   |
|                                    | `[ ]`       | btrbk                      | Automated local and remote Btrfs snapshot generation and retention management          |
| **Kernel & OS Hardening**          | `[x]`       | SystemD                    | Core init system, service supervisor, and stage-1 initrd runtime                       |
|                                    | `[x]`       | Linux Latest Kernel        | Up-to-date kernel package for high-end CPU/GPU hardware support                        |
|                                    | `[x]`       | NVIDIA Beta Driver         | Cutting-edge proprietary GPU drivers tailored for Wayland                              |
|                                    | `[x]`       | `boot.initrd.systemd`      | Modern stage-1 initrd integration powered natively by systemd                          |
|                                    | `[x]`       | Sysctl Kernel Mitigations  | Hardening unprivileged BPF loading, kernel pointer leaks, and dmesg buffers            |
|                                    | `[x]`       | AppArmor                   | Linux security module for mandatory access control and application profiling           |
|                                    | `[x]`       | zRAM Swap                  | In-memory compressed swap space to optimize RAM usage                                  |
|                                    | `[ ]`       | auto-cpufreq               | Automatic CPU frequency tuner for dynamic power and thermal management                 |
|                                    | `[ ]`       | Scudo Memory Allocator     | Hardened user-mode memory allocator replacing glibc malloc against heap exploits       |
|                                    | `[ ]`       | Process Isolation          | Mounting `/proc` with `hidepid=2` so users only view their own running processes       |
|                                    | `[ ]`       | systemd Service Hardening  | Strict drop-in security flags like `ProtectSystem=strict` and `PrivateTmp=true`        |
|                                    | _Monitored_ | Rust in Kernel & uutils    | Memory-safe core utilities and kernel modules written in Rust                          |
|                                    | _Monitored_ | Landlock LSM               | Unprivileged access control framework for application sandboxing                       |
| **Core Systems & Security**        | `[x]`       | NixOS & Nix                | Declarative OS foundation and purely functional package manager                        |
|                                    | `[x]`       | Home Manager               | Declarative management of user dotfiles, shell environments, and applications          |
|                                    | `[x]`       | sops-nix                   | Declarative secret management encrypted via age/GPG keys                               |
|                                    | `[x]`       | WireGuard                  | High-performance, modern encrypted VPN tunnel                                          |
|                                    | `[x]`       | dnscrypt-proxy             | Encrypted DNS provider integration with local ad-blocking                              |
|                                    | `[x]`       | sudo-rs                    | Memory-safe Rust implementation of sudo                                                |
|                                    | `[x]`       | D-Bus Broker               | High-performance, secure drop-in replacement for dbus-daemon                           |
|                                    | `[ ]`       | OpenSnitch                 | Interactive application-level network firewall and connection monitor                  |
|                                    | `[ ]`       | nftables                   | Modern, high-performance packet filtering firewall framework replacing iptables        |
| **Display, Graphics & Audio**      | `[x]`       | Mesa                       | Open-source 3D graphics drivers and API implementation                                 |
|                                    | `[x]`       | Wayland                    | Modern, secure display server protocol replacing legacy X11                            |
|                                    | `[x]`       | PipeWire                   | Low-latency audio and video routing multimedia framework                               |
|                                    | `[x]`       | WirePlumber                | Modular session and policy manager for PipeWire streams                                |
| **Desktop & Application Runtimes** | `[x]`       | Niri                       | Scrollable-tiling Wayland compositor                                                   |
|                                    | `[x]`       | Noctalia v5                | Desktop shell environment components                                                   |
|                                    | `[x]`       | XDG Desktop Portals        | Secure system dialog and desktop resource delegation under Wayland                     |
|                                    | `[x]`       | Bubblewrap                 | Unprivileged sandboxing tool for isolating un-trusted processes                        |
|                                    | `[x]`       | nix-flatpak                | Declarative management for sandboxed Flatpak applications                              |
|                                    | `[x]`       | Proton / Wine              | Compatibility layers for running Windows applications and games                        |
|                                    | `[x]`       | nix-ld                     | Compatibility shim layer for running unpatched, dynamic Linux binaries                 |
|                                    | _Monitored_ | GNOME                      | Desktop environment ecosystem monitoring                                               |
| **Nix Tooling & Workflow**         | `[x]`       | nh                         | Modern CLI helper for NixOS generation management and rebuilds                         |
|                                    | `[x]`       | nix-direnv                 | Fast automatic Flake dev-environment loader                                            |
|                                    | `[ ]`       | nix-index & comma          | Instant execution of uninstalled packages via `,` lookup                               |
|                                    | `[ ]`       | nix-output-monitor (`nom`) | Visual build-tree display for Nix evaluations                                          |
|                                    | `[ ]`       | nvd                        | Version diff analyzer between NixOS generations before switching                       |
|                                    | `[x]`       | statix & deadnix           | Static analysis linter and dead-code detection for Nix code                            |
|                                    | `[x]`       | Alejandra / `nixfmt`       | Opinionated, deterministic code formatters for Nix expressions                         |
| **Auditing & Maintenance**         | `[ ]`       | Trivy / Grype              | Vulnerability and CVE scanning for Nix derivations                                     |
|                                    | `[ ]`       | Restic                     | Fast, encrypted snapshot backup utility for local and remote storage                   |
|                                    | `[x]`       | Nix Store Optimise         | Automatic hard-linking of duplicate store paths via `nix.settings.auto-optimise-store` |
| **External Ecosystem**             | _Monitored_ | LibrePhone Project         | FSF-backed free mobile software ecosystem initiative                                   |
