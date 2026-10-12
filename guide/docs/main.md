{
"title": "Architecture",
"group": "REFERENCE",
"weight": 0,
"build": {
"render": "link",
"list": "always"
}
}

Shadow is a single-host NixOS configuration with Home Manager. The technology catalog below owns tool descriptions and decisions; configuration previews and locked revisions are generated from source.

## Configuration flow

| Layer   | Source                 | Responsibility                                  |
| ------- | ---------------------- | ----------------------------------------------- |
| Inputs  | flake.nix / flake.lock | Dependencies and pinned revisions               |
| Machine | shadow/default.nix     | Hardware facts and NixOS module selection       |
| User    | shadow/home.nix        | User identity and Home Manager module selection |
| System  | modules/nixos/         | Boot, storage, security, services and drivers   |
| Desktop | modules/home/          | Programs, shell, editor and window manager      |

## System information display

Fastfetch’s display is managed by `modules/home/shell/fastfetch.nix`. Its Noctalia, Nix and Flatpak version commands run without `condition.succeeded`: that condition checks the preceding module and is incompatible with parallel command modules in Fastfetch 2.69. With the conditions removed, the version rows and the following user environment section render successfully. To expose a hidden configuration error, run `fastfetch --show-errors true`. Source changes take effect after Home Manager activation.

## State flow

NVMe → LUKS → Btrfs → persistent /nix and /saved. The root filesystem is temporary; Preservation restores explicitly selected state. Independent backups provide recovery beyond the laptop.

## Change flow

Edit → evaluate → build → temporary activation → review → switch → reboot and verify.

- [x] One host and one user with direct module imports
- [x] Declarative system and user configuration
- [x] Explicit persistent-state ownership
- [ ] Independent backup and restore acceptance: see the roadmap

These marks describe configuration and outstanding work, not live service health.
