# Shadow — NixOS on a Razer Blade 14 (2025)

Impermanent, encrypted NixOS config for a Razer Blade 14 laptop.

- **Root**: tmpfs — wiped every reboot.
- **Disk**: LUKS2 + btrfs. Only `/nix` (store) and `/saved` (persistent state) survive.
- **Desktop**: Niri (scrollable-tiling compositor) + Noctalia 5 (shell, bar, launcher, notifications, wallpaper engine). GNOME is secondary.
- **Editor**: Zed &nbsp;·&nbsp; **Shell**: fish &nbsp;·&nbsp; **Browser**: Zen

---

## Hardware

| Component | Detail |
|---|---|
| Model | Razer Blade 14 (2025) |
| CPU | AMD Ryzen AI 9 365 — 10C/20T @ 2.00–5.0 GHz |
| iGPU | AMD Radeon 880M |
| dGPU | NVIDIA GeForce RTX 5060 Max-Q (Prime offload) |
| RAM | 16 GB LPDDR5X |
| Storage | ~953 GiB NVMe (`nvme0n1`) |

---

## Flake inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | `nixos-unstable` |
| `home-manager` | Per-user dotfiles & packages |
| `disko` | Declarative disk partitioning |
| `preservation` | Impermanence — persists selected paths across reboots |
| `nix-flatpak` | Declarative Flatpak management |
| `nixos-hardware` | Razer Blade 14 (`RZ09-0530`) hardware quirks |
| `jovian` | Steam Deck gaming mode + Proton GE |
| `noctalia` | Shell, bar, launcher, notifications for Niri |
| `zen-browser` | Zen Browser via home-manager module |

| Status | Planned |
|---|---|
| &nbsp; | `lanzaboote` — Secure Boot support |
| &nbsp; | `stylix` — System-wide theming |

---

## Repository structure

```
configuration.nix           # Top-level — imports all modules below
flake.nix                   # Inputs → nixosSystem
hardware-configuration.nix  # Auto-generated (nixos-generate-config)
home.nix                    # home-manager hook → home/aqua/

modules/
├── boot.nix                # systemd-boot, kernel params
├── desktop.nix             # Niri, GNOME prune, fonts, Wayland env
├── disko.nix               # tmpfs / + LUKS2 + btrfs subvolumes
├── flatpak.nix             # Declarative Flatpaks
├── gaming.nix              # Jovian, Steam, Proton GE, GameMode
├── graphics.nix            # NVIDIA, Bluetooth, 32-bit Mesa, udev
├── packages.nix            # System-wide packages
├── preservation.nix        # Impermanence — what survives reboots
└── services.nix            # GDM, GNOME, PipeWire, printing, Kavita, SSH, sudo

home/aqua/
├── default.nix             # Entry point — imports everything below
├── desktop.nix             # GTK theme, cursor, XDG dirs, terminal/browser
├── apps/
│   ├── default.nix         # ghostty + zed + zen
│   ├── ghostty.nix         # Terminal config
│   ├── zed/
│   │   ├── default.nix     #   Enable + extensions
│   │   ├── settings.nix    #   Editor, UI, terminal, AI
│   │   ├── languages.nix   #   Per-language formatters
│   │   └── lsp.nix         #   rust-analyzer, vtsls, clangd
│   └── zen/
│       ├── default.nix     #   Enable + profile
│       ├── search.nix      #   Search engines
│       └── settings.nix    #   about:config preferences
├── cli/
│   ├── default.nix         # packages + fish + fastfetch
│   ├── packages.nix        # eza, bat, fd, rg, yazi, opencode, obsidian…
│   ├── fastfetch.nix       # Config + ASCII logo
│   ├── fastfetch.txt
│   └── fish/
│       ├── default.nix     #   Enable + starship/zoxide/atuin init
│       ├── abbrs.nix       #   Abbreviations
│       ├── aliases.nix     #   Shell aliases
│       ├── functions.nix   #   mkcd, wallpaper, book_library, phone, devenv-new
│       └── starship.nix    #   Prompt styling
├── gnome/
│   ├── default.nix         # monitors + bookmarks + dconf + extensions
│   ├── monitors.nix        #   eDP-2 @ 2880×1800, 2× scale
│   ├── bookmarks.nix       #   Nautilus sidebar
│   ├── dconf.nix           #   Interface, background, input, privacy, mutter…
│   └── extensions.nix      #   Extensions + per-extension dconf
└── wm/
    ├── default.nix         # niri + noctalia
    ├── niri/
    │   ├── default.nix     #   Out-of-store symlinks
    │   ├── config.kdl      #   Layout, animations, window rules
    │   └── binds.kdl       #   Keybindings
    └── noctalia/
        ├── default.nix     #   Enable + systemd + symlink
        ├── config.toml     #   Bar, widgets, theme, wallpaper, lockscreen
        └── nixos.svg       #   Session widget logo
```

---

## Disk layout

```
/dev/nvme0n1
├── ESP             1 GiB   vfat    →  /boot     (EFI)
└── luks (LUKS2)    rest    btrfs   →  crypted
    ├── @nix                   →  /nix       [compress=zstd, noatime]
    ├── @saved                 →  /saved     [compress=zstd, noatime]
    └── @swap  (16 GiB file)   →  /swap      [swapfile]
```

`/` is **tmpfs** — empty after every reboot. See the table below for what survives.

---

## 📦 Installation

> **`nixos-rebuild switch` does NOT format disks.** These commands do.

Boot a NixOS live USB, clone this repo, then:

```sh
# One-shot: partition, format, mount, install
sudo nix run github:nix-community/disko -- --impure \
  --mode=destroy,format,mount --flake .#shadow --disk main /dev/nvme0n1
sudo nixos-install --flake .#shadow
```

Day-to-day updates:

```sh
sudo nh os switch /saved/nixos-config
```

---

## 🔒 What survives reboots

Everything not listed here lives on tmpfs and is **gone** after reboot.

### System paths

| Path | Why |
|---|---|
| `/etc/machine-id` | Stable machine identity |
| `/etc/ssh/ssh_host_ed25519_key*` | SSH host keys |
| `/var/lib/systemd/random-seed` | Entropy seed (faster RNG on boot) |
| `/var/lib/nixos` | UID/GID mappings |
| `/var/log` | Persistent logs (journald) |
| `/var/lib/systemd/coredump` | Crash dumps |
| `/var/lib/systemd/timers` | Timer state |
| `/var/lib/bluetooth` | Bluetooth pairings |
| `/var/lib/flatpak` | Flatpak system data |
| `/var/lib/decky-loader` | Decky Loader plugin state |
| `/var/lib/kavita` | Kavita book library + token |
| `/etc/NetworkManager/system-connections` | Saved Wi-Fi networks |

### User `aqua` paths

| Path | Why |
|---|---|
| `Desktop/` `Documents/` `Music/` `Pictures/` `Projects/` `Public/` `Templates/` `Videos/` `Books/` | XDG user directories |
| `Downloads/` | **Not persisted** — wiped every reboot |
| `~/.ssh` | SSH keys (`chmod 700`) |
| `~/.gnupg` | GPG keys (`chmod 700`) |
| `~/.gitconfig` | Git identity |
| `~/.config/gh` | GitHub CLI auth |
| `~/.local/share/keyrings` | GNOME Keyring (Zed auth token lives here) |
| `~/.config/zen` · `~/.cache/zen` | Zen Browser profile + web cache |
| `~/.config/zed` · `~/.local/share/zed` | Zed editor state + login |
| `~/.config/nvim` · `~/.local/state/nvim` | Neovim state |
| `~/.config/fish` · `~/.local/share/fish` | Fish shell history + config |
| `~/.config/atuin` · `~/.local/share/atuin` | Atuin shell history DB |
| `~/.config/niri` | Niri compositor state |
| `~/.config/noctalia` · `~/.local/share/noctalia` · `~/.cache/noctalia` | Noctalia shell state |
| `~/.local/state/pipewire` · `~/.local/state/wireplumber` | Per-app audio volumes |
| `~/.local/share/Steam` · `~/.steam` | Steam library + Proton prefixes |
| `~/.config/openrazer` · `~/.local/share/openrazer` | Razer hardware config |
| `~/.config/polychromatic` · `~/.local/share/polychromatic` | Razer RGB profiles |
| `~/.config/obsidian` | Obsidian preferences |
| `~/.config/opencode` · `~/.local/share/opencode` | OpenCode AI editor state |
| `~/.var` | Every Flatpak app's session data |

---

## 🖥️ Desktop

### Niri + Noctalia 5 _(default session)_

Niri is a scrollable-tiling Wayland compositor. Noctalia 5 layers on top:
top bar, app launcher (`Mod+Space`), notification center, clipboard manager,
wallpaper engine with auto-cycling, and lockscreen.

Both configs are live-editable via out-of-store symlinks:

| File | Reload |
|---|---|
| `home/aqua/wm/niri/config.kdl` | `niri msg action reload-config` |
| `home/aqua/wm/niri/binds.kdl` | (included by config.kdl — same reload) |
| `home/aqua/wm/noctalia/config.toml` | Noctalia watches for changes |

Noctalia auto-generates Material You (M3 tonal spot) themes from the current
wallpaper. Templates are pushed to: **GTK3, GTK4, Ghostty, Niri, Zen Browser,
Zed** — all update when the wallpaper changes.

### GNOME _(secondary session)_

Enabled via GDM as a fallback. Also provides gnome-keyring and dconf.

- 11 extensions: User Themes, AppIndicator, Dash to Dock, Blur my Shell,
  Clipboard Indicator, Caffeine, Just Perfection, Status Area Spacing,
  GSConnect, Auto Accent Colour, Accent Directories.
- `services.gnome.gnome-software.enable = false` — Flatpaks are managed declaratively.
- Bloat removed: tour, connections, console, characters, yelp, epiphany, geary.

---

## 🔧 Services & hardware

| Service | Detail |
|---|---|
| **PipeWire** | Audio (ALSA, Pulse, JACK, 32-bit Steam) |
| **GDM** | Display manager |
| **NetworkManager** | Wi-Fi, ethernet |
| **Bluetooth** | `powerOnBoot = false` |
| **OpenRazer + Polychromatic** | Keyboard lighting, fan control |
| **Kavita** | Book server on `:8083` — `book_library on\|off\|status` |
| **Printing** | CUPS + Epson ESC/P-R drivers |
| **Scanning** | SANE + `epsonscan2` backend |
| **SSH** | OpenSSH server enabled |
| **firmware** | `fwupd` for firmware updates |
| **direnv** | `nix-direnv` integration |

### Firewall

| Port | For |
|---|---|
| `8083/tcp` | Kavita |
| `36679/tcp+udp` | SimpleX |
| `1714–1764/tcp+udp` | GSConnect |

---

## 🎮 Gaming

- **Jovian** — Steam Deck gamescope session (selectable from GDM).
- **Steam** — Native + Proton GE, remote play, dedicated server.
- **GameMode** — `gamemoderun` wrapper; `gamemode` group for the user.
- Decky Loader is installed but **disabled** (`jovian.decky-loader.enable = false`).
- Steam library + prefixes persist in `/saved` via preservation.

NVIDIA offload alias: `nv <command>` (uses `nvidia-offload`).

---

## 🛠️ Maintenance commands

```sh
# Rebuild system
sudo nh os switch /saved/nixos-config

# Test build (doesn't switch)
sudo nh os test /saved/nixos-config

# Garbage-collect old generations (keep 14d + last 10)
nh clean all --keep-since 14d --keep 10

# Update flake inputs
nix flake update --flake /saved/nixos-config
```

### Fish shell quick-reference

| Shortcut | Expands to |
|---|---|
| `nx-rebuild` | `nh os switch /saved/nixos-config` |
| `nx-test` | `nh os test /saved/nixos-config` |
| `nx-clean` | `nh clean all --keep-since 14d --keep 10` |
| `nv` | `nvidia-offload` |
| `wp` | `wallpaper` (set / random / info) |
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -l --icons --git` |
| `cat` | `bat` |
| `grep` | `rg` |
| `find` | `fd` |
| `top` | `btop` |

---

## 🔑 TPM2 auto-unlock _(future)_

`disko.nix` already enables `allowDiscards` (SSD TRIM). To enroll the LUKS
slot in the TPM and skip the boot passphrase:

```sh
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto /dev/nvme0n1p2
```

Then uncomment `crypttabExtraOpts = [ "tpm2-device=auto" ]` in `disko.nix`.

Also needs: `boot.initrd.systemd.enable = true` + `tpm2-tss` in initrd.

---

## ℹ️ Notes

- Repo lives at `/saved/nixos-config`. `nh.flake` points there.
- `hardware-configuration.nix` is auto-generated — don't hand-edit it.
  `modules/graphics.nix` + `nixos-hardware` handle all GPU quirks.
- `stateVersion = "26.05"` on `nixos-unstable`.
- `EDITOR` = `micro` (set in `home/aqua/default.nix`).
