# Tool catalog: what Shadow declares, and what comes next

Reviewed **2026-10-11**. The structured catalog is [`tools.json`](../tools.json).
This is a declaration/import audit of the current working tree, including dirty changes, not an installed-version report or proof that the tree evaluates, builds or is running.
Grouped entries cover related tools without pretending to list every transitive dependency.
For upstream evidence and comparisons, use [research.md](research.md); this page adds no external research.

## How to read an entry

| Field | Meaning |
| --- | --- |
| `id` | Stable, unique catalog identifier; not necessarily a package attribute. |
| `name`, `category` | Human-readable tool/group and one of the eight catalog domains. |
| `status` | Declaration status under the definitions below, never an uptime badge. |
| `owner` | Existing repository-relative source path, without the `nixos-config/` prefix. |
| `purpose` | What the declaration does, including package-only versus managed configuration. |
| `alternative` | A comparison candidate or different workflow, **not an automatic winner**. |
| `decision` | Keep/change/verify guidance and the acceptance gate before deployment. |

- **Configured:** selected by the host/home graph or explicitly package-listed. Does not imply running, logged in, healthy or successfully deployed.
- **Available / optional:** a disabled path, parked module, manual import material or candidate. Does **not** guarantee installation or pinned-package availability.
- **Proposed:** future work with no selected implementation; its owner is the existing review/extension point, not a claim that code exists there.
- **Needs verification:** a concrete integration, effective-policy or artifact gap prevents the stronger claim; underlying declarations may still be enabled.

Every entry has one primary owner. Supporting files are named in its text; grouped ownership does not move responsibility between system and home layers.
Where runtime observations in other audit pages differ, keep them as separately dated evidence rather than promoting this catalog's statuses.

## Import graph and installation boundaries

`flake.nix` constructs `nixosConfigurations.shadow` from `shadow/default.nix`.
The host imports hardware facts and Disko layout plus NixOS core, hardware, networking, security, storage, services and desktop groups; Flatpak and Steam are selected directly.
It also imports external Razer hardware, Disko, Preservation, Home Manager, nix-flatpak and sops-nix modules.
The desktop group selects the ChatGPT/Codex community module from its flake input.
`shadow/home.nix` independently selects home shell, desktop, programs, packages and window-manager groups for Aqua.
Local group `default.nix` files select their children; upstream module defaults can add behavior that requires effective-option evaluation.
There is no composition/profile layer or root `devShell` declared here, and NixOS modules do not import Home Manager user modules.

| Installation/configuration source | What is actually owned there |
| --- | --- |
| `modules/nixos/core/packages.nix` | System package list: curl, Git, USB/PCI diagnostics, clipboard and GPU recorder; Fish also explicitly enabled. |
| `modules/nixos/desktop/apps.nix` | Native GNOME utility package list plus keyring/GVfs/dconf integration, not separate application settings modules. |
| `modules/home/packages/cli.nix` | CLI utilities, archives, networking, encryption and FFmpeg; Fish aliases live elsewhere. |
| `modules/home/packages/development.nix` | Nix tooling, devenv, gh and lazygit; bubblewrap/socat lines are commented out. |
| `modules/home/packages/apps.nix` | Standalone native apps and wl-screenrec, without dedicated `programs.*` settings. |
| `modules/home/programs/` | Managed Ghostty, Helix, Zed, Brave/Chromium and cloud agents; KeePassXC uses package plus writable-config activation, Delta uses an input package. |
| `modules/nixos/services/flatpak-apps.nix` | App IDs drive Flatpak install, exceptions and preserved app-data paths; remote auto-updates are separate from the Nix lock. |
| `modules/home/desktop/` | MIME associations, GTK/dconf, bookmarks, directories and launchers; a launcher does not download its target. |
| `modules/home/wm/` | Niri KDL and Noctalia TOML/SVG beside their modules; generated theme files are runtime outputs. |

These package lists are **declarative installations**, not evidence of imperative/manual package installation.
Manual state still matters: provider logins, NetworkManager VPN import, a Brave-installed WhatsApp app, the local AppImage and KeePassXC association/vault state.
Language-server preferences in Zed do not establish globally installed Rust/C++/JavaScript toolchains.
The local AI module exists, but `programs/ai/default.nix` comments out its import: llama-swap, CUDA model service and `ai` function are **parked**, not active home configuration.
Kavita is selected and hardened but has empty `wantedBy`: configured for manual start, not autostart.
OpenSSH is explicitly disabled; decrypted WireGuard material is available for import, not a declared active tunnel or kill switch.

## Decision roadmap before changing NixOS

1. **Recovery first:** inventory any existing off-device backups; define valuable state, recovery keys, retention and an isolated restore test. Preservation, encrypted storage, scrub and local snapshots do not replace this.
2. **Verify the baseline:** evaluate/build the reviewed tree; inspect storage timers, SMART warning delivery, portal routing, confinement coverage, VPN DNS and application artifacts.
3. **Measure power:** keep PPD as the baseline. Test fixed display/workload conditions and return-to-idle after GPU offload, external displays and resume. Trial a replacement backend only for a measured benefit or missing control.
4. **Keep updates recoverable:** review lock/input and third-party wrapper changes, retain a known-good generation, and reboot-test kernel/NVIDIA/firmware changes. Latest/beta may help hardware support but increase update risk.
5. **Stage boot integrity:** consider Lanzaboote only after recovery, signing-key persistence, ESP space and NVIDIA/OpenRazer compatibility are understood. TPM unlock is a separate later policy project; a crypttab flag is not trusted boot.
6. **Revisit optional complexity:** local AI, additional apps, remote services and hibernation require a concrete use case, state/credential owner and acceptance test before activation.

Acceptance means verified behavior and rollback, not merely choosing a newer implementation. Detailed priorities and source-backed tradeoffs remain in [research.md](research.md).

## Short glossary

| Term | Practical meaning here |
| --- | --- |
| **TPM** | Hardware-backed key/policy device. Sealed unlock depends on measurements and policy; keep an independent recovery credential. |
| **UKI** | Unified Kernel Image bundling kernel, initrd and associated boot metadata into an EFI artifact that can be signed. Not a complete module-signing policy. |
| **Secure Boot / measured boot** | Secure Boot authenticates accepted boot artifacts; measured boot records what booted, often into TPM PCRs. Related but not interchangeable. |
| **PCR** | TPM Platform Configuration Register holding measurement state used by sealing/unlock policies; updates can affect policy validity. |
| **RTD3 / runtime PM** | Idle-device power management allowing the NVIDIA GPU to suspend while the laptop stays awake. Different from whole-system suspend. |
| **PRIME / offload** | Run a chosen workload on the discrete GPU while ordinary desktop rendering can stay on the integrated GPU. |
| **PPD / EPP** | Power Profiles Daemon exposes desktop profile policy; Energy Performance Preference influences CPU performance/efficiency balance. |
| **TuneD / tuned-ppd / tlp-pd** | Alternative tuning backend and PPD-compatible frontends. API similarity is not identical hardware policy or a benchmark result. |
| **LUKS / TRIM** | Linux encrypted-volume format; TRIM/discard informs SSDs about unused blocks. Pass-through can reveal allocation patterns, not plaintext. |
| **Btrfs / scrub** | Checksummed filesystem with subvolumes; scrub reads/verifies data and metadata, repairing only where a valid redundant copy exists. |
| **tmpfs / Preservation** | RAM-backed root disappears at reboot; Preservation restores selected paths from persistent storage. Neither is a backup. |
| **zram / swap / resume** | zram is compressed RAM swap; disk swap handles overflow. Hibernation needs a valid persistent resume image and separate setup. |
| **Portal / XDG** | Desktop conventions and brokered file/media APIs used by sandboxed apps. Backend routing and permissions need real workflow tests. |
| **Wayland / XWayland** | Native display protocol and compatibility layer for X11 clients; their permission/isolation properties differ. |
| **PipeWire / WirePlumber** | Media transport and its session-policy manager; PulseAudio compatibility serves apps still using that API. |
| **AppArmor / USBGuard** | Process access-control profiles and USB authorization policy. Enablement alone proves neither profile coverage nor device trust. |
| **SOPS / age / keyring** | Encrypted secret-file workflow, encryption identities and runtime credential storage. Ciphertext and a login keyring are not independent key recovery. |
| **Flake / lock / stateVersion** | Named Nix inputs/outputs, pinned revisions and compatibility defaults. Updating inputs is not a reason to bump stateVersion. |
| **Home Manager / Disko** | Declarative user environment and disk-layout tooling. Disko apply/format actions are destructive, not tests. |
| **GC / generation / cache** | Garbage collection removes unreferenced store paths; generations enable rollback; signed binary caches reduce builds under explicit trust. |
| **ACP / LSP / FHS wrapper** | Agent Client Protocol, Language Server Protocol and conventional filesystem compatibility. None inherently proves sandbox enforcement. |

## Scope and validation limits

No Nix declarations, UI, build scripts or other handbook documents are changed by this catalog work.
No package versions, firmware state, power results, service uptime or successful system build are inferred from source declarations.
External module defaults, actual installed binaries, manual configuration and existing off-device backups still need host/effective-option inspection.
For later system changes, use `nix flake check`, `git diff --check` and a no-link system build; test reviewed activation and hardware behavior before switching permanently.
Never use destructive Disko commands, firmware key enrollment or a restore over production data as handbook validation.
