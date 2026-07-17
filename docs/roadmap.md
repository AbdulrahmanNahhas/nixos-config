# Roadmap

Roadmap items are not active configuration. Security behavior changes should be
separate from structural refactors so their effects can be reviewed and
bisected.

## Critical credentials and trust

- Remove `initialPassword = "changeme"` for root and Aqua.
- Decide whether root should have a password. Use a hashed installation-only
  credential or establish credentials interactively during installation.
- Reconsider `trusted-users = [ "root" "@wheel" ]`; trusted Nix users can gain
  root-equivalent power.
- Introduce sops-nix or another reviewed secret workflow, including age-key
  recovery, before adding secret modules.

## Privacy and networking

- Align DNSCrypt's IPv4-only listener with configured `127.0.0.1` and `::1`
  nameservers.
- Evaluate `require_nolog = true` and verify whether required DNSSEC/no-filter
  properties exclude desired resolvers.
- Decide whether LUKS `allowDiscards` matches the privacy model.
- Review persistent logs, core dumps, browser caches, Flatpak state, and shell
  history; consider volatile journald with selected retained security logs.
- Restrict Kavita's wildcard bind if remote access is unnecessary.
- Replace the assumed `wlan0` firewall binding and make each service own its
  opening. Keep SimpleX and GSConnect closed until needed.

## Maintainability and validation

- Move the host-specific preferred-GPU PCI address into a dedicated
  `hosts/shadow/hardware.nix` when more host facts justify that file.
- Add custom module options only when real reuse removes duplication.
- Add a flake formatter using `nixfmt-rfc-style` or `treefmt-nix`.
- Add `deadnix`, `statix`, and CI evaluation of `nixosConfigurations.shadow`.
- Keep the simple flake shape until a second host requires generalization.

## Storage, backup, and recovery

- Implement snapshots separately from backups.
- Store encrypted backups externally or remotely; snapshots reachable from the
  running system are not ransomware protection.
- Document and test recovery from a broken generation, lost Secure Boot keys,
  lost LUKS credentials, corrupted `/saved`, and lost sops age keys.

## Future security modules

- Research AppArmor, Secure Boot with Lanzaboote, systemd service hardening,
  secrets management, and NixPak without claiming they are active.
- Research hardened-kernel compatibility with NVIDIA.
- Add gaming and hardened NixOS specialisations only after their behavioral
  differences and recovery path are defined. Current `profiles/nixos/gaming.nix`
  is a composition profile, not a specialisation.
