{
"title": "Read the Nix language",
"group": "FOUNDATIONS",
"weight": 2,
"sources": [
[
"Nix language tutorial",
"https://nix.dev/tutorials/nix-language"
],
[
"Nix reference manual",
"https://nix.dev/reference/nix-manual"
]
],
"build": {
"render": "link",
"list": "always"
}
}

A Nix file is an expression that evaluates to a value. Common values are strings, numbers, booleans, paths, lists, attribute sets, and functions. An attribute set is a mapping of names to values; it is not a shell script. Nix is lazy: values are evaluated when needed.

```
{ pkgs, lib, ... }:
let
  tools = [ pkgs.ripgrep pkgs.fd ];
in
{
  home.packages = tools;
  programs.fish.enable = true;
}
```

`{ pkgs, lib, ... }:` is a function that accepts an attribute set. The module system supplies these arguments. `...` permits additional arguments. `let … in …` introduces local names. Lists use spaces between items. Attribute assignments end in semicolons. `home.packages` is a nested attribute, equivalent to `home = { packages = tools; };`.

## Patterns you will actually edit

- `./file.nix` is a path relative to the file containing it.
- `import ./flatpak-apps.nix` evaluates that expression. A module’s `imports = [ … ];` asks the module system to include modules; this has a different job.
- `inherit appId;` means `appId = appId;` using the surrounding value.
- `app.origin or "flathub-verified"` supplies a fallback when the attribute is missing. This is not boolean OR.
- `map (x: …) list` transforms a list. `lib.mapAttrsToList` transforms named entries into a list.
- `a // b` shallowly merges attribute sets with right-hand keys winning. It is not the module system’s recursive option merge.
- `"${username}"` is interpolation: insert a value into a string.

### Why a package name sometimes needs pkgs.

`pkgs` is the package set. `pkgs.ripgrep` selects a package from it. `with pkgs; [ ripgrep fd ]` brings those names into scope for that expression. Prefer explicit names when scope would be confusing.

### What purity means here

Pure evaluation avoids silently depending on unrelated machine state. Flake inputs and tracked files define the source. This helps reproduce a build, but cannot freeze internet services, external Flatpak updates, mutable databases, or firmware behavior.
