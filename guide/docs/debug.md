| Layer | Typical symptom | First check |
| --- | --- | --- |
| Evaluation | Unknown option, type error, missing path | Imports, option declaration, staged new files |
| Build | Download/hash/compiler failure | Specific derivation log, network/cache access |
| Activation | Managed-file collision, permission/mount error | Activation output and relevant ownership |
| Runtime | App crashes, no DNS, unavailable keyring | Service/app logs and actual session behavior |

```
systemctl --failed
systemctl --user --failed
journalctl -b -u dnscrypt-proxy
systemctl status kavita
ss -lntu
niri validate --config ~/.config/niri/config.kdl
```

User services and the system service manager have different scopes. A graphical-session keyring problem should be tested in that graphical session. A sandboxed tool failing to contact D-Bus or the Nix cache is an execution-environment limitation, not proof the system service is broken.

If the same app symptom appears from both Flatpak and a native package, investigate shared layers such as display, D-Bus, keyring, GPU, and user state. Do not repeatedly replace packages without evidence. Element’s Secret Service integration under Niri is an example of a shared session concern.

## Inspect without exposing secrets

Use metadata: service state, paths, ownership, modes, public recipient count, encryption status. Avoid printing private identities, NetworkManager secret fields, environment files, or token-bearing command lines. If a process is listening broadly, its name/working directory is often enough to identify its owner.

## Read the final configuration

```
nix eval --json /saved/nixos-config#nixosConfigurations.shadow.config.networking.nameservers
nix eval /saved/nixos-config#nixosConfigurations.shadow.config.security.apparmor.enable
```

Change one cause at a time and verify the affected behavior. Repeatedly running unrelated tests adds noise without strengthening evidence.
