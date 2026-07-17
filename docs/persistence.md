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

Preserved files include machine ID, Ed25519 SSH host keys, systemd random seed,
Aqua's Git config, and Aqua's dconf database. Preserved directories include:

- `/var/lib/nixos`, `/var/lib/systemd/timers`, and `/var/lib/systemd/coredump`
- `/var/log`
- `/var/lib/flatpak`, `/var/lib/bluetooth`, and `/var/lib/decky-loader`
- `/var/lib/kavita`
- `/etc/NetworkManager/system-connections` and `/etc/nixos`

## Aqua state

The configuration preserves standard XDG directories except `Downloads`, plus
Books, SSH/GnuPG credentials, GitHub CLI and keyring state, Zen profile/cache,
Zed and Neovim state, fish and Atuin history, Niri and Noctalia state, audio
state, Steam, Obsidian, OpenCode, OpenRazer, Polychromatic, and all Flatpak user
state under `~/.var`.

The authoritative list is
`modules/nixos/storage/preservation.nix`; update this document whenever that
list changes.

## Privacy and recovery

Persistent logs, core dumps, browser caches, Flatpak state, shell history, and
application state can reveal activity after a reboot. Retaining them is a
continuity choice, not an impermanence guarantee. Review data minimization and
consider volatile journald with narrowly retained security logs.

Btrfs snapshots are not configured. Snapshots are not backups, and snapshots
reachable by a compromised system should not be presented as ransomware
protection. Recovery procedures for a corrupted `/saved` and external encrypted
backups remain roadmap work.
