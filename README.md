# Shadow — NixOS on a Razer Blade 14 (2025)

Lightweight, opinionated NixOS config built around an **impermanent**, fully
encrypted setup: tmpfs root + LUKS2 + btrfs, with only `/nix` and `/saved`
surviving reboots. Desktop is GNOME on Wayland; editor is Zed; shell is fish.

## Hardware

- Razer Blade 14 (2025)
- AMD Ryzen AI 9 365 — 10 cores / 20 threads, base 2.00 GHz, boost up to 5.0 GHz
- AMD Radeon 880M  — integrated GPU
- NVIDIA GeForce RTX 5060 Max-Q (Mobile) — discrete GPU (Prime offload)
- 16 GB LPDDR5X RAM
- ~953 GiB NVMe (single `nvme0n1`)

## Todo List:

- [X] NixOS/nixpkgs/nixos-unstable
- [X] nix-community/home-manager
- [X] nix-community/disko
- [X] gmodena/nix-flatpak
- [X] rafaelmardojai/firefox-gnome-them
- [X] nix-community/preservation
- [X] nix-community/nixos-hardware
- [ ] nix-community/lanzaboote
- [ ] nix-community/stylix

## Repository layout

```
configuration.nix        # Top-level system module — imports everything below
flake.nix                # Inputs: nixpkgs-unstable, home-manager, disko, preservation, nix-flatpak, firefox-gnome-theme
hardware-configuration.nix # Auto-generated hardware probe (nixos-generate-config) — used
home.nix                 # home-manager hook → delegates to home/aqua/
modules/
  boot.nix               # systemd-boot, kernel params, GPU module preload
  desktop.nix            # GNOME + fonts + Wayland env vars
  disko.nix              # tmpfs / + LUKS2 + btrfs subvolumes @nix @saved @swap
  flatpak.nix            # Declarative Flatpak apps via nix-flatpak
  packages.nix           # System-wide packages (git, curl, …)
  preservation.nix       # /saved = persistent layer; lists everything kept across reboots
  services.nix           # PipeWire, Bluetooth, upower, openssh, sudo
home/aqua/                # Everything per-user (managed by home-manager)
  default.nix            # GTK, cursor, fonts, XDG dirs, terminal routing
  packages.nix           # User CLI tools (eza, bat, fd, ripgrep, yazi, …)
  firefox.nix            # Firefox profile, search engines, GNOME theme
  fish.nix               # Fish + starship + aliases/functions
  ghostty.nix            # Ghostty terminal config
  gnome-extensions.nix   # GNOME Shell extensions as user packages
  fastfetch.nix          # fastfetch system info
  zed.nix                # Zed editor settings
```

## Disk layout (declared by `modules/disko.nix`)

```
/dev/nvme0n1
├─ ESP             1 GiB   vfat   →  /boot        (EFI, umask=0077)
└─ luks (LUKS2)    rest    btrfs  →  crypted
   ├─ @nix   subvol  →  /nix    (compress=zstd, noatime)   [read-only-ish, never wiped]
   ├─ @saved subvol  →  /saved  (compress=zstd, noatime)   [persistent state lives here]
   └─ @swap  subvol  →  /swap   (16 GiB swapfile — full RAM, supports hibernate)
```

The whole root (`/`) is **tmpfs**: anything not listed in `modules/preservation.nix`
is wiped on reboot. Things that survive (configured in preservation.nix):

- System: machine-id, SSH host keys, entropy seed, NetworkManager connections,
  Bluetooth pairings, NixOS uid/gid state, journald, coredumps, timers.
- User `aqua`: XDG directories (`Desktop/`, `Documents/`, `Music/`, `Pictures/`,
  `Projects/`, `Public/`, `Templates/`, `Videos/`; **`Downloads/` is intentionally
  not persisted** — it lives on the tmpfs root and is wiped on reboot),
  `~/.ssh`, `~/.gnupg`, `~/.mozilla` (Firefox session/logins),
  `~/.local/share/zed` (Zed login + workspace state), `~/.local/share/keyrings`
  (GNOME Keyring, where Zed keeps its auth token), `~/.var` (every Flatpak app's
  session), `~/.local/share/atuin` (shell history), pipewire/wireplumber state.

> When you adopt a new app and want its login/state to survive reboots, add
> its data directory to `modules/preservation.nix`.

## ⚠ Important: how to actually format the disk

`nixos-rebuild switch` does **NOT** format anything. Neither does `nix build`
nor `nix flake check` — those only validate / build the config; they leave the
disk untouched.

To install onto a fresh `/dev/nvme0n1` (this **destroys** everything on it),
boot a NixOS live USB, copy this repo into the live env, and either:

```sh
# Option A — one-shot (disko + nixos-install in a single command):
sudo nix run github:nix-community/disko -- --impure \
  --mode=destroy,format,mount --flake .#shadow --disk main /dev/nvme0n1
sudo nixos-install --flake .#shadow

# Option B — same thing via disko-install:
sudo nix run github:nix-community/disko#disko-install -- \
  --flake .#shadow --disk main /dev/nvme0n1
```

After the first install, day-to-day updates on the running system are:

```sh
sudo nh os switch /etc/nixos   # or: sudo nixos-rebuild switch --flake .#shadow
```

…which never touches the disk layout, only updates the system closure.

## TPM2 auto-unlock (future work)

`modules/disko.nix` already passes `allowDiscards = true` (SSD TRIM through
LUKS). After install, enroll the LUKS volume in the TPM and remove the
passphrase prompt by setting `crypttabExtraOpts = [ "tpm2-device=auto" ]` in
`disko.nix` (already stubbed out as a comment there) and running:

```sh
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto /dev/nvme0n1p2
```

(Also requires `boot.initrd.systemd.enable = true` and the `tpm2-tss` package
in the initrd.)

## Notes

- `nh.flake = "/etc/nixos"` is set in `configuration.nix`. After install, the
  expected layout is `/etc/nixos` pointing at this repo (e.g.
  `sudo ln -sfn /saved/nixos-config /etc/nixos`).
- `hardware-configuration.nix` (repo root) is the auto-generated probe file from
  `nixos-generate-config`, imported by `configuration.nix`. All NVIDIA/AMD hybrid
  graphics quirks live in the `nixos-hardware` Razer Blade 14 module, so the only
  hand-maintained hardware code here is the GPU env-var block in `configuration.nix`.
- This config follows `nixpkgs/nixos-unstable` and pins `stateVersion = "26.05"`.
