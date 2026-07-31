# Persistence

`/` is a 4 GiB tmpfs. Disko creates an encrypted Btrfs filesystem with
persistent `/nix`, `/saved`, and a 16 GiB swapfile under `/swap`. Files not
explicitly preserved or mounted from those locations disappear at reboot.

```text
/dev/nvme0n1
├── ESP       1 GiB, vfat -> /boot
└── LUKS2     remaining space
    └── Btrfs
        ├── /nix   -> /nix
        ├── /saved -> /saved
        └── /swap  -> /swap (16 GiB swapfile)
```

LUKS currently allows discards. This supports SSD TRIM but leaks information
about which encrypted blocks are unused; review it against the intended privacy
model.

## System state

Preserved files include machine ID, systemd random seed, Aqua's Git config, and
Aqua's dconf database. Preserved directories include:

- `/var/lib/nixos`, `/var/lib/systemd/timers`, and `/var/log/journal`
- `/var/lib/flatpak` and `/var/lib/bluetooth`
- `/var/lib/kavita`
- `/etc/NetworkManager/system-connections`

OpenSSH is currently disabled. Its Ed25519 host identity is preserved
conditionally whenever the server is enabled, avoiding both unused persistent
key material now and a changing host identity after future tmpfs-root reboots.

`/saved/games` is a direct-persistent Steam library created by the gaming
module. Like `/saved/nixos-config` and the SOPS deployment identity, it lives
directly on the persistent `/saved` mount rather than through Preservation.

## Aqua state

The configuration preserves standard XDG directories except `Downloads`, plus
Books, SSH/GnuPG credentials, GitHub CLI and keyring state, the complete
LibreWolf profile, Zed and Neovim state, fish and Atuin history, direnv
approvals, devenv trust data and GC roots, Niri and Noctalia state, audio state,
Steam (including per-game shader data), Mesa/RADV shader caches, Obsidian,
OpenRazer, and Polychromatic. Flatpak state is limited to the application IDs
declared in the Flatpak module; this includes Brave's complete browser profile.
Removed or manually installed Flatpaks do not gain persistence automatically.
Browser and Noctalia caches are ephemeral except for caches stored inside an
application's required profile directory.

Direnv approvals are retained in `~/.local/share/direnv`, so an unchanged
`.envrc` remains approved after reboot. Changing `.envrc` still invalidates its
approval and requires another review and `direnv allow`. Devenv's
`~/.local/share/devenv` directory is also retained for its trust metadata,
cached keys, and explicit Nix GC roots.

The Espressif Xtensa Rust compiler and LLVM payload are retained in `~/.rustup`;
espup's supporting Clang-library link is retained in `~/.espup`. ESP-IDF and its
C toolchain are intentionally workspace-local under each project's
`.embuild/espressif` directory, so they survive through the already-preserved
`~/Projects` tree without an additional home-level persistence entry.

LibreWolf's profile is preserved at `~/.config/librewolf`, its current XDG
location. The obsolete `~/.librewolf` path is intentionally not preserved.

Aqua's SOPS editing identity is preserved at `~/.config/sops`. Shadow's
root-only SOPS deployment identity lives directly at
`/saved/var/lib/sops-nix/key.txt`; because `/saved` is already a persistent
mount, it is not a Preservation bind mount. Decrypted files under `/run/secrets`
remain deliberately ephemeral.

The authoritative list is
`modules/nixos/storage/preservation.nix`; update this document whenever that
list changes.

## Nix store maintenance

`nh clean all --keep 3 --no-gcroots` runs every Friday at 03:00. It keeps the
three newest generations for each cleaned profile, removes older generations,
and garbage-collects store paths that are no longer reachable. `--no-gcroots`
prevents `nh` from deleting explicit roots, including direnv and devenv project
environments; the Nix garbage collector therefore continues protecting
everything reachable from those roots.

Nix store optimisation runs every Friday at 04:00, after cleanup. Optimisation
hard-links identical store files to save space; `/nix/store/.links` is its
deduplication index, not a separate cache to delete.

The single Btrfs filesystem is scrubbed monthly through its `/saved` mount.
Scrub verifies checksums across all of its subvolumes, including `/nix` and
`/swap`. SMART monitoring also watches the physical NVMe device and warns
logged-in users about detected health problems. A single-device scrub can
detect corruption but usually cannot repair it without another good copy.

## Privacy and recovery

Journald persists up to 128 MiB or seven days on the LUKS-encrypted `/saved`
filesystem so failures remain diagnosable after booting an older generation.
Systemd core dumps remain disabled because they can retain process memory.
Flatpak state, shell history, browser profiles, and other application state can
still reveal activity after a reboot. Retaining them is a continuity choice,
not an impermanence guarantee.

Btrfs snapshots are not configured. Snapshots are not backups, and snapshots
reachable by a compromised system should not be presented as ransomware
protection. Recovery procedures for a corrupted `/saved` and external encrypted
backups remain roadmap work. The SOPS admin identity requires a separate,
encrypted offline backup; another copy on `/saved` does not protect against disk
loss.
