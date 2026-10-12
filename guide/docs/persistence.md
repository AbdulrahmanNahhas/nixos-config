{
"title": "What survives a reboot",
"group": "STATE & IDENTITY",
"weight": 9,
"sources": [
[
"Preservation module",
"https://github.com/nix-community/preservation"
],
[
"systemd tmpfiles",
"https://www.freedesktop.org/software/systemd/man/latest/systemd-tmpfiles.html"
]
],
"build": {
"render": "link",
"list": "always"
}
}

Shadow’s root is a 4 GiB tmpfs. Its contents disappear on reboot unless a path is backed by persistent storage. LUKS protects a Btrfs filesystem whose `/nix`, `/saved`, and swap subvolumes survive.

```
NVMe → LUKS2 → Btrfs
                  ├─ /nix    package store
                  ├─ /saved  selected system/user data + repository
                  └─ /swap   encrypted disk swap
RAM → /            temporary root
```

Preservation exposes selected backing directories/files at the paths applications expect. Declaring a path describes that relationship; it is not a backup. The authoritative declaration is `modules/nixos/storage/preservation.nix`. Direct paths already under `/saved`, such as the repository and deployment identity, do not need another preservation mount.

## Important choices

- Documents, Projects, Books, media, keyring state, browser state, editor data, and selected desktop state are retained.
- Downloads is intentionally temporary. Move valuable downloads into a retained directory.
- Flatpak directories derive from the catalog. Theme extensions are excluded.
- KeePassXC settings and the Rust Book browser profile are now retained with private directory modes.
- Runtime decrypted files under `/run/secrets` remain ephemeral.
- Logs retain up to seven days / 128 MiB. Core dumps are disabled.

Removing a preservation entry does not erase its backing directory. Conversely, deleting the backing directory destroys data independently of a configuration rollback. New preservation mounts also need migration care: data created in an unpreserved home path before activation should be backed up and checked before a mount hides or replaces that view.

### Why root:root 0700 or aqua:users 0700?

Ownership selects who controls a file. Directory mode 0700 permits only its owner to traverse it. File mode 0600 permits owner read/write; 0400 is owner read-only. Mount parents need correct ownership too. Permissions reduce access but do not protect against root compromise.
