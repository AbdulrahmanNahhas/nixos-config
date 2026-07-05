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
- [X] Jovian-Experiments/Jovian-NixOS (Steam Deck Gaming Mode + Decky (Disabled Now))
- [ ] nix-community/lanzaboote
- [ ] nix-community/stylix

## Repository layout

```
configuration.nix        # Top-level system module — imports everything below
flake.nix                # Inputs: nixpkgs-unstable, home-manager, disko, preservation, nix-flatpak, nixos-hardware, jovian, firefox-gnome-theme
hardware-configuration.nix # Auto-generated hardware probe (nixos-generate-config) — used
home.nix                 # home-manager hook → delegates to home/aqua/
modules/
  boot.nix               # systemd-boot, kernel params, GPU module preload
  desktop.nix            # GNOME + fonts + Wayland env vars
  disko.nix              # tmpfs / + LUKS2 + btrfs subvolumes @nix @saved @swap
  flatpak.nix            # Declarative Flatpak apps via nix-flatpak
  gaming.nix             # Steam Deck Gaming Mode (Jovian) + Proton GE + Decky + GameMode
  packages.nix           # System-wide packages (git, curl, …)
  preservation.nix       # /saved = persistent layer; lists everything kept across reboots
  services.nix           # PipeWire, Bluetooth, upower, openssh, sudo
home/aqua/                # Everything per-user (managed by home-manager)
  default.nix             # Imports, home basics, out-of-store nix.conf
  desktop.nix             # GTK, cursor, XDG dirs, terminal/browser routing
  scripts.nix             # User helper scripts (setwallpaper)
  apps/
    default.nix           # Aggregates firefox/ghostty/zed
    ghostty.nix           # Ghostty terminal config
    firefox/              # Firefox split into focused modules
      default.nix         #   enable + profile basename
      search.nix          #   search engines
      policies.nix        #   enterprise policies (uBlock…)
      settings.nix        #   about:config prefs (theme toggles + extras)
      theme.nix           #   userChrome/userContent + gnome-theme symlink
    zed/                  # Zed editor, userSettings merged across files
      default.nix         #   enable + extensions
      settings.nix        #   core editor / UI / terminal / AI settings
      languages.nix       #   per-language formatter + format-on-save
      lsp.nix             #   rust-analyzer / vtsls / clangd options
  cli/
    default.nix           # Aggregates packages/fish/yazi/fastfetch
    packages.nix          # User CLI tools (eza, bat, fd, ripgrep, yazi, …)
    yazi.nix              # Yazi file manager + keymap
    fastfetch.nix         # fastfetch system info (config.jsonc + logo)
    fastfetch.txt         # ASCII logo
    fish/                 # Fish split into focused modules
      default.nix         #   enable + interactive init (starship/zoxide/atuin)
      abbrs.nix           #   abbreviations
      aliases.nix         #   shell aliases
      functions.nix       #   mkcd, wallpapers, wallpaper-next/prev, phone…
      starship.nix        #   starship prompt config
  gnome/
    default.nix           # Aggregates gnome submodules
    monitors.nix          # monitors.xml (eDP-2 layout/scale)
    bookmarks.nix         # Nautilus sidebar bookmarks
    dconf.nix             # dconf: interface, background, input, privacy, mutter…
    extensions.nix        # GNOME Shell extensions + per-extension dconf
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


## NOTESSS:
# ────────────────────────────────────────────────────────────────
# Shared builder for "fetch a GNOME Shell extension from GitHub and
# drop it into the correct UUID-named folder" — avoids repeating the
# same mkDerivation boilerplate for every extension not in nixpkgs.
# ────────────────────────────────────────────────────────────────
mkGnomeExtension =
  {
    pname,
    owner,
    repo,
    rev,
    hash,
    uuid,
  }:
  pkgs.stdenv.mkDerivation {
    inherit pname;
    version = rev;

    src = pkgs.fetchFromGitHub {
      inherit
        owner
        repo
        rev
        hash
        ;
    };

    nativeBuildInputs = [ pkgs.glib ];
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/gnome-shell/extensions/${uuid}
      cp -r . $out/share/gnome-shell/extensions/${uuid}

      if [ -d $out/share/gnome-shell/extensions/${uuid}/schemas ]; then
        glib-compile-schemas $out/share/gnome-shell/extensions/${uuid}/schemas
      fi
      runHook postInstall
    '';

    passthru.extensionUuid = uuid;
  };

chromaleon = mkGnomeExtension {
  pname = "gnome-shell-extension-chromaleon";
  owner = "Fabito02";
  repo = "ChromaLeon";
  rev = "91add7c0138a8f3cd05ad598ad24a15767ca8293";
  hash = "sha256-OYbVG91js7tejdc+TqRU6ZYRUR53KOYb7GhNP410ipo=";
  uuid = "user-accent-colors@fabito02";
};

# o-tiling = pkgs.stdenv.mkDerivation rec {
#   pname = "gnome-shell-extension-o-tiling";
#   version = "2.9.5";
#   uuid = "o-tiling@oliwebd.github.com";

#   src = pkgs.fetchurl {
#     url = "https://github.com/oliwebd/o-tiling/releases/download/v${version}/o-tiling@oliwebd.github.com-v${version}.zip";
#     hash = "sha256-DEBm9+mvRuccTbgQXfC4aJxQ0g04FGanaj9Gmi2gr30=";
#     name = "o-tiling-v${version}.zip";
#   };

#   nativeBuildInputs = [
#     pkgs.unzip
#     pkgs.glib
#   ];
#   dontUnpack = true;
#   dontBuild = true;
#   dontConfigure = true;

#   installPhase = ''
#     runHook preInstall
#     mkdir -p $out/share/gnome-shell/extensions/${uuid}
#     unzip -o $src -d $out/share/gnome-shell/extensions/${uuid}
#     if [ -d $out/share/gnome-shell/extensions/${uuid}/schemas ]; then
#       glib-compile-schemas $out/share/gnome-shell/extensions/${uuid}/schemas
#     fi
#     runHook postInstall
#   '';

#   passthru.extensionUuid = uuid;
# };
