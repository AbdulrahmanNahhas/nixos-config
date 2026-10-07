# Shadow

NixOS + Home Manager for Aqua's Razer Blade 14: Niri/Noctalia, an encrypted
Btrfs persistent store, and an ephemeral root.

Open [the interactive guide](guide/index.html) in your browser for the system
map, concepts, app catalog, secrets/VPN workflows, maintenance, and sources.
It works offline and does not run commands on your machine.

```sh
nix flake check
nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link
sudo nh os test /saved/nixos-config
```

After reviewing and testing a generation, use `sudo nh os switch /saved/nixos-config`.
Disko formatting is an installation operation and must never be used as a test.
