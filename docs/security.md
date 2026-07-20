# Security status

This document distinguishes active controls from planned work. A documented
path or placeholder directory does not mean a feature is implemented.

## Active controls

- LUKS2 disk encryption with a tmpfs root and explicit preservation.
- NixOS firewall enabled; Kavita `8083/tcp` is open only on `wlan0`.
- DNSCrypt Proxy with DNSSEC-required, no-filter resolvers; `require_nolog` is
  currently false.
- NetworkManager Wi-Fi MAC randomization and IPv6 temporary addresses.
- Flatpak for selected desktop applications.
- OpenSSH and printing disabled.
- SOPS/age secret management with separate Aqua editing and root-only Shadow
  deployment identities. Declared plaintext exists only in access-controlled
  tmpfs runtime files.
- Declarative users: Aqua's yescrypt password hash is encrypted with SOPS and
  direct root password login is locked.
- Volatile, size-bounded journald and disabled systemd core dumps limit
  persistent activity and process-memory disclosure.

Kavita listens on `0.0.0.0` and `::`, although its firewall opening is tied to
`wlan0`. SimpleX `36679` and GSConnect `1714-1764` rules are commented out.

## Known risks

- `trusted-users = [ "root" "@wheel" ]` gives wheel users root-equivalent Nix
  capabilities.
- DNSCrypt listens only on `127.0.0.1:53`, while system nameservers also include
  `::1`; IPv6 resolver behavior needs verification.
- DNSCrypt permits resolvers that log (`require_nolog = false`). DNSSEC and
  no-filter requirements may also reduce the intended resolver set.
- LUKS discards, persistent application profiles, and broad Flatpak persistence
  have privacy costs.
- Kavita's wildcard bind and interface-name-specific firewall policy should be
  reviewed together.
- Noctalia's third-party AniList plugin copies its token into preserved user
  state. SOPS prevents Git/Nix-store disclosure but cannot change that upstream
  runtime behavior.
- The previously committed AniList token and Wallhaven API key remain
  compromised until revoked; removing them from the current tree does not
  remove Git history.

## Planned, not active

AppArmor, Lanzaboote/Secure Boot, NixPak, systemd hardening, snapshots,
TPM auto-unlock, hardened and gaming specialisations, and remote encrypted
backups are not implemented. Planned locations are:

```text
modules/nixos/security/apparmor.nix
modules/nixos/security/secure-boot.nix
modules/nixos/security/systemd-hardening.nix
modules/nixos/storage/snapshots.nix
specialisations/gaming.nix
specialisations/hardened.nix
```

These files should be created and imported only when they contain reviewed,
testable behavior. Secure Boot and TPM enrollment also require documented
recovery for lost keys or credentials.
