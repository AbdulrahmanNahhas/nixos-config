Modules contribute definitions to named options. The module system checks types and combines definitions according to each option’s rules. Package lists normally combine; contradictory ordinary scalar definitions normally produce an error rather than silently choosing the last file.

`config` is the evaluated configuration. `pkgs` provides packages. `lib` provides module helpers. `options` describes the available option declarations. Your `inputs` and `username` arguments are passed from the host composition, not magically available in every unrelated Nix project.

```
imports = [ ./power.nix ./audio.nix ];
services.upower.enable = true;
some.option = lib.mkDefault "fallback";
some.option = lib.mkForce "deliberate override";
```

`mkDefault` gives a low-priority default. `mkForce` overrides weaker definitions; use it to resolve a specific ownership conflict, not to hide an unexplained error. `mkIf` conditionally contributes definitions while allowing the module system to resolve dependencies. Read an option’s type and upstream module before assuming the merge behavior.

## Shadow’s import boundary

`shadow/default.nix` imports external NixOS modules and selects system domains. `shadow/home.nix` selects Home Manager domains. A system module should not reach across and import user modules. For example, installing a desktop integration service belongs to NixOS; your browser settings belong to Home Manager.

A `default.nix` inside a domain is an explicit aggregator. Files omitted from its import list do nothing. Local AI currently illustrates this: its module exists, but its import is parked, so the system does not automatically build or start it.

> To inspect the effective value: `nix eval /saved/nixos-config#nixosConfigurations.shadow.config.networking.firewall.enable`. Source comments explain intent; evaluated values establish what the module graph actually produces.
