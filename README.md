# Shadow

NixOS + Home Manager for Aqua's Razer Blade 14: Niri/Noctalia, an encrypted
Btrfs persistent store, and an ephemeral root.

Open [the system handbook](guide/index.html) for searchable technologies,
technical reference, source previews, locked revisions and the roadmap.
It is built with Hugo and works offline with a separate page for each sidebar section.

Edit Markdown in `guide/docs/` and the catalog data in `guide/*.json`, then run
`./guide/build.sh`. Source previews, Flatpak IDs and input revisions are derived
from the repository. See [guide maintenance and GitHub Pages deployment](guide/README.md).

```sh
nix flake check
nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link
sudo nh os test /saved/nixos-config
```

After reviewing and testing a generation, use `sudo nh os switch /saved/nixos-config`.
Disko formatting is an installation operation and must never be used as a test.
