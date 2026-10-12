{
"title": "Where to add something",
"group": "DAILY WORK",
"weight": 6,
"sources": [
[
"Home Manager manual",
"https://nix-community.github.io/home-manager/"
],
[
"Flatpak application IDs",
"https://docs.flatpak.org/en/latest/conventions.html"
]
],
"build": {
"render": "link",
"list": "always"
}
}

Start with the behavior you want. A device driver or system service belongs to NixOS. A configured personal application belongs to Home Manager. A compiler version for one project belongs to devenv. An ordinary sandboxed desktop app usually fits the Flatpak catalog.

| Change                            | Place                                     |
| --------------------------------- | ----------------------------------------- |
| Flatpak app + exceptions          | `modules/nixos/services/flatpak-apps.nix` |
| Configured native application     | `modules/home/programs/`                  |
| Plain GUI / CLI / shared dev tool | `modules/home/packages/`                  |
| Launcher for local AppImage       | `modules/home/desktop/local-apps.nix`     |
| File type default                 | `modules/home/desktop/xdg.nix`            |
| System service                    | Relevant `modules/nixos/` domain          |
| Machine-specific fact             | `shadow/`                                 |

Configured modules install their own applications when appropriate. Do not repeat Delta, Brave, or KeePassXC in a plain package list. Delta now comes from the official input with its own desktop entry; the old custom wrapper is removed.

The Flatpak catalog is intentionally ordinary Nix data, not a custom module framework. The service adapter derives installation and overrides. Preservation derives data directories from the same entries. Native applications still need their own persistence declarations because there is no reliable universal rule for where every native app writes.

## Check for duplicates

```
rg 'application-name|application.id' modules shadow flake.nix
```

Occurrences can have legitimate roles: installation, settings, MIME defaults, and persistence. The aim is one owner per role, not one occurrence of every name. Removing an app’s install entry is separate from deleting its data.
