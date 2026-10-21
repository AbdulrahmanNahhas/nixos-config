{
  "title": "Check → build → test → switch",
  "group": "DAILY WORK",
  "weight": 5,
  "sources": [
    [
      "NixOS changing configuration",
      "https://nixos.org/manual/nixos/stable/#sec-changing-config"
    ],
    [
      "nh project",
      "https://github.com/nix-community/nh"
    ]
  ],
  "build": {
    "render": "link",
    "list": "always"
  }
}

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

### Build resources and scheduled cleanup

Shadow's host configuration bounds Nix to two concurrent derivations with four build cores each. The previous automatic defaults could schedule a derivation for each of the twenty CPU threads while advertising all cores to each builder. On this 16 GiB laptop, the new starting policy aims to leave memory and CPU capacity for the desktop and development tools. It can lengthen large builds; it is not a measured throughput improvement or a hard memory/CPU limit. Some builders ignore `NIX_BUILD_CORES`, and project tools outside Nix need their own limits. The [Nix configuration reference](https://nix.dev/manual/nix/latest/command-ref/conf-file.html) distinguishes `max-jobs` from `cores`.

The Friday `nh-clean` service now uses idle CPU/I/O scheduling and nice level 19 so a missed persistent timer catching up after login competes less with interactive work. Retention and scheduling are unchanged. Nix store optimisation and Btrfs scrub already carry low-priority scheduling in the pinned modules; no extra daemon or duplicate tuning is added. Priority is not an energy cap, and the storage scheduler can affect how much I/O priority helps.

### What rollback does not restore

A previous generation restores package/configuration references. It does not rewind database migrations, documents, removed files, tokens revoked at a provider, Flatpak app data, or firmware enrollment. A configuration rollback is different from a data restore.
