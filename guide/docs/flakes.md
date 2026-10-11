`flake.nix` describes inputs and outputs. `flake.lock` records resolved revisions and hashes. The unstable channel URL is a moving source, but the lock records the revision you actually use. Updating inputs changes that pin; it does not immediately change the running system.

The host output is `nixosConfigurations.shadow`. Its `config.system.build.toplevel` is the complete system derivation. The formatter is exposed separately, and the Gitleaks source scan is a check. These are named outputs selected with the `#` part of a flake reference.

```
delta = {
  url = "github:zed-industries/delta-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

`follows` aligns Delta’s Nixpkgs with the system’s packages and graphics stack. It avoids an unnecessary independent package-set pin. It is appropriate where upstream supports it; do not apply it blindly to every input. Some projects require their own compatible dependency revisions.

## Three different kinds of trust

-   A source hash establishes identity of fetched content. It does not prove that code is harmless.
-   A cache public key verifies signatures on substituted build results. Private signing keys belong to the cache operator.
-   Nix `trusted-users` grants powerful daemon permissions. Shadow trusts root, not the wheel group. You do not need root-equivalent Nix trust just to use a declared binary cache.

Git-backed flakes exclude untracked new files. Use `git add` for new module files before evaluation; staging is not committing. Read the lock diff after an update. Delta updates through its official input, and its packaged updater is disabled by upstream.
