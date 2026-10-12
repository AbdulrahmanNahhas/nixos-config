{
"title": "Go deeper & test yourself",
"group": "REFERENCE",
"weight": 19,
"sources": [
[
"Nix language",
"https://nix.dev/tutorials/nix-language"
],
[
"Module system deep dive",
"https://nix.dev/tutorials/module-system/deep-dive"
],
[
"Nixpkgs manual",
"https://nixos.org/manual/nixpkgs/stable/"
],
[
"NixOS manual",
"https://nixos.org/manual/nixos/stable/"
],
[
"Home Manager manual",
"https://nix-community.github.io/home-manager/"
],
[
"Preservation",
"https://github.com/nix-community/preservation"
],
[
"SOPS",
"https://getsops.io/docs/"
],
[
"age",
"https://github.com/FiloSottile/age"
],
[
"sops-nix",
"https://github.com/Mic92/sops-nix"
],
[
"Flatpak sandboxing",
"https://docs.flatpak.org/en/latest/sandbox-permissions.html"
],
[
"nix-flatpak",
"https://github.com/gmodena/nix-flatpak"
],
[
"NetworkManager WireGuard",
"https://networkmanager.dev/docs/api/latest/settings-wireguard.html"
],
[
"DNSCrypt configuration",
"https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml"
],
[
"systemd execution and sandboxing",
"https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html"
],
[
"devenv",
"https://devenv.sh/"
],
[
"Btrfs documentation",
"https://btrfs.readthedocs.io/"
],
[
"Official Delta flake",
"https://github.com/zed-industries/delta-nix"
]
],
"build": {
"render": "link",
"list": "always"
}
}

## A useful order

1.  Read Nix expressions and evaluate small examples in `nix repl`.
2.  Understand module imports, types, merging, and priorities.
3.  Trace Shadow’s host and user graph.
4.  Practice an app addition: owner, permissions, persistence, evaluation.
5.  Trace a secret from ciphertext to runtime consumer.
6.  Explain disk encryption, generation rollback, and backup boundaries.
7.  Inspect DNS and VPN routing before changing failure policy.

## Explain these without looking

- Why is an age recipient safe in Git, but its identity is not?
- Why does a new VPN not normally need a new age identity?
- Why can a flake update leave the running system unchanged?
- Why can a generation rollback fail to repair app data?
- Why is a closed inbound firewall not an outbound app policy?
- Why might a Flatpak still access Documents after !home?
- Why does a file under /run disappear while an app profile survives?
- Why does a Nix package need runtime launch testing after it builds?

This guide is a starting point for mastery, not a guarantee of complete knowledge. Real confidence comes from small changes, predicting their effects, testing those predictions, and learning to recover. The linked sources let you move from the practical model to exact semantics.

### Further topics once these foundations are comfortable

Package derivations and overlays; fixed-output derivations; store closures and GC roots; systemd credentials and sandboxing; nftables routing and firewall hooks; WireGuard policy routing; UEFI trust and measured boot; Btrfs subvolumes and backup consistency; agent/application runtime permissions.
