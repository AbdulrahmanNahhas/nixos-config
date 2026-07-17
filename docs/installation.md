# Installation

> **Warning:** the Disko command below destroys the partition table and all data
> on its target device. It is an installation operation, not a validation step.

The current host layout assumes:

- Razer Blade 14 hardware supported by the selected `nixos-hardware` module.
- Target disk `/dev/nvme0n1`.
- UEFI boot.
- Repository checkout at `/saved/nixos-config` after installation.

Before installing, review `hosts/shadow/disk.nix`, replace the insecure
installation passwords in `modules/nixos/core/users.nix`, and verify that
valuable data is backed up elsewhere.

From a NixOS live environment:

```sh
git clone https://github.com/AbdulrahmanNahhas/nixos-config.git
cd nixos-config

sudo nix run github:nix-community/disko -- --impure \
  --mode=destroy,format,mount --flake .#shadow \
  --disk main /dev/nvme0n1

sudo nixos-install --flake .#shadow
```

After booting, ensure the repository exists at `/saved/nixos-config`. This path
is referenced by `nh`, fish helpers, and live-editable Niri and Noctalia links.

Routine deployment does not format the disk:

```sh
sudo nh os switch /saved/nixos-config
```

TPM auto-unlock is not configured. Keep the LUKS credential and tested recovery
material available; do not assume Secure Boot keys, snapshots, or remote backups
exist yet.
