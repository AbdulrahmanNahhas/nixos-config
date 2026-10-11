**Evaluation** computes the configuration and derivations. **Building** realizes the required store paths, using caches where possible. **Activation** updates system links, service definitions, users, and managed files. **Booting** loads the selected kernel/initrd and starts the generation from cold state.

| Action | Changes running system? | Meaning |
| --- | --- | --- |
| `sys-check` | No | Evaluate and run declared checks. |
| `sys-build` | No | Build the system with nh. |
| `sys-test` | Yes, temporarily | Activate without selecting it as the default boot generation. |
| `sys-switch` | Yes | Activate and select the generation for future boots. |
| `sys-update` | No | Update flake inputs only. |

For kernel or graphics-driver changes, a temporary test cannot fully validate the boot path. Review, build, arrange recovery, select the generation for boot, then verify after reboot. A service restart can disrupt ongoing work even if the change is reversible.

```
cd /saved/nixos-config
git diff
nix fmt
git diff --check
nix flake check
nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link
sudo nh os test /saved/nixos-config
```

After temporary activation, check the affected behavior: fresh login for authentication changes, IPv4/IPv6 DNS for networking, actual app launch and data access for sandbox changes. Keep an authenticated terminal and an older boot generation available. Switch only once the result is understood.

### What rollback does not restore

A previous generation restores package/configuration references. It does not rewind database migrations, documents, removed files, tokens revoked at a provider, Flatpak app data, or firmware enrollment. A configuration rollback is different from a data restore.
