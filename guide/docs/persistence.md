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
- Heroic's retained app directory includes its sandbox home and default game library; keep games and Wine prefixes inside that sandbox until another library path has explicit access and persistence. The Flatpak lesson owns the path and permission details.
- The Rust Book browser profile is retained with a private directory mode. KeePassXC's settings mount and the Discord, SiYuan and Zotero app mounts are no longer declared; their old backing directories under `/saved/home/aqua` remain available for deliberate recovery or removal. Password databases and documents are not deleted by removing these applications.
- Native Nahhasio client state at `~/.local/state/nahhasio` is retained with mode `0700`. Media files have separate storage paths; this declaration does not establish that every client feature persists its state there.
- Development state retains direnv approvals, devenv trust/GC-root metadata, and Nix fetch/evaluation metadata in `~/.cache/nix`. Zoxide's learned directory rankings remain temporary by choice; Atuin's command history is retained separately. Project-local `.devenv` and `.direnv` survive when the project is under retained `~/Projects`; runtime sockets under `/run/user` remain temporary.
- NetworkManager's internal state is retained separately from connection profiles. Its iwd Wi-Fi backend also retains `/var/lib/iwd` with root ownership and mode `0700`; that directory contains saved network credentials and was previously lost with the tmpfs root. DNSCrypt's catalog/signature state is retained at `/var/lib/private/dnscrypt-proxy`, the real DynamicUser state directory; systemd recreates `/var/lib/dnscrypt-proxy` as a symlink and manages the transient service ownership. Both private-state parents remain root-only. Firmware-update history/pending bookkeeping at `/var/lib/fwupd` is retained.
- Btrfs scrub progress/results at `/var/lib/btrfs` and PPD's selected-profile state at `/var/lib/power-profiles-daemon` are retained. This does not automatically resume an interrupted scrub or prove a selected profile is effective. SMART monitoring saves its disk state through an explicit `--savestates=/var/lib/smartmontools/` prefix; systemd creates that directory with mode `0700` and Preservation retains it. Monitoring history is not proof of notification delivery or a successful self-test.
- Atuin configuration/history/key directories and GitHub CLI configuration use mode `0700`. Atuin's network/history policy is explained in the security lesson. Changing directory modes does not delete existing credentials or command history.
- Runtime decrypted files under `/run/secrets` remain ephemeral.
- Agent sandbox permissions introduce no retained data. The system-managed credential-read policy has been retired; existing credential persistence is unchanged. The security lesson explains the client sandbox and its limits.
- Logs retain up to seven days / 128 MiB. Core dumps are disabled.

Removing a preservation entry does not erase its backing directory. Conversely, deleting the backing directory destroys data independently of a configuration rollback. New preservation mounts need migration before first activation: back up and transfer the current `~/.cache/nix`, `/var/lib/NetworkManager`, `/var/lib/iwd`, `/var/lib/fwupd`, and `/var/lib/private/dnscrypt-proxy` into their matching paths under `/saved` before an empty backing mount hides existing state. Use a coherent SQLite backup for an active Nix cache. Service-state migration requires host-root access and a controlled maintenance window; preserve ownership/permissions, do not pin a DynamicUser numeric UID, and do not disrupt networking casually. Declaration/build validation does not perform that migration or prove service health. After `nh os test`, check the mounts, DNS, connections and firmware daemon; verify survival after a reviewed reboot.

The 2026-10-21 additions need the same pre-activation handling for `/var/lib/btrfs`, `/var/lib/power-profiles-daemon` and `/var/lib/smartmontools`. Copy existing state, when present, to the matching `/saved/var/lib/` directories while the owning service is stopped; do not run a scrub during migration. Create an empty backing directory only when no state exists. In the audit namespace the PPD directory existed, while the other two paths were absent; inspect again on the host before deciding what to copy. The audit did not migrate or activate these mounts. After activation, verify the three mounts and service write access, then confirm profile/history survival after reboot.

### Why root:root 0700 or aqua:users 0700?

Ownership selects who controls a file. Directory mode 0700 permits only its owner to traverse it. File mode 0600 permits owner read/write; 0400 is owner read-only. Mount parents need correct ownership too. Permissions reduce access but do not protect against root compromise.
