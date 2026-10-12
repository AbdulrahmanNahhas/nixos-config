{
"title": "The app & file map",
"group": "REFERENCE",
"weight": 18,
"sources": [
[
"Repository package collection",
"https://search.nixos.org/packages"
],
[
"Flatpak reference",
"https://docs.flatpak.org/en/latest/"
]
],
"build": {
"render": "link",
"list": "always"
}
}

Use the app catalog below to locate a Flatpak entry. Origin is the configured remote; runtime installations can differ until reconciliation succeeds. Exceptions describe declared overrides, not a complete effective-permissions audit.

## Native and special application owners

| Application                     | Source owner                                       |
| ------------------------------- | -------------------------------------------------- |
| Delta                           | Official flake + `modules/home/programs/delta.nix` |
| Brave                           | `modules/home/programs/brave.nix`                  |
| Zed                             | `modules/home/programs/zed/`                       |
| KeePassXC                       | `modules/home/programs/keepassxc.nix`              |
| Obsidian, Anki, Mullvad Browser | `modules/home/packages/apps.nix`                   |
| GNOME file/system apps          | `modules/nixos/desktop/apps.nix`                   |
| Steam and game tools            | `modules/nixos/gaming/steam.nix`                   |
| Nahhas Cinema local AppImage    | `modules/home/desktop/local-apps.nix`              |

Binary updates for the local AppImage are still outside the flake graph. Keep its provenance and update method clear. No extra launcher is needed for Delta because the official package supplies one.
