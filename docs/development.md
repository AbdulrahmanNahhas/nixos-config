# Development environments

Development toolchains belong to each project. Home Manager installs only the
shared orchestration and Nix tooling: Zed, devenv, direnv, nixd, nixfmt, and
general Git utilities. Rust, Node.js, pnpm, Biome, and similar versioned tools
come from each project's `devenv.nix`.

Zed loads project environments with its direct direnv integration. This keeps
GUI-launched Zed working without starting it from `devenv shell`. Direnv
approval is intentionally required for a new or changed `.envrc`; approved
hashes persist across reboot.

## Creating or enabling an environment

Create a new directory and initialize devenv:

```fish
devenv-new my-project
```

Run `devenv-new` without an argument to initialize the current directory. It
refuses to replace an existing devenv configuration.

For an existing project that already has `devenv.nix`, create the canonical
`.envrc` if missing and approve it:

```fish
devenv-enable
```

The generated `.envrc` is:

```sh
eval "$(devenv direnvrc)"
use devenv
```

Commit `.envrc`, `devenv.nix`, `devenv.yaml`, and `devenv.lock`. Ignore
`.devenv`, `.direnv`, and the generated `.pre-commit-config.yaml`.

## Rust project

Use the project-local Rust toolchain:

```nix
{ ... }:
{
  languages.rust.enable = true;
}
```

After `direnv allow`, Zed discovers `cargo`, `rustc`, and `rust-analyzer`.
Rust Analyzer runs Clippy for checks through the global Zed configuration.

## TypeScript and web project

Add the git-hooks input to `devenv.yaml`:

```yaml
inputs:
  nixpkgs:
    url: github:cachix/devenv-nixpkgs/rolling
  git-hooks:
    url: github:cachix/git-hooks.nix
```

Use this base `devenv.nix`:

```nix
{ pkgs, ... }:
{
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_26;
    npm.enable = false;
    pnpm = {
      enable = true;
      install.enable = true;
    };
  };

  languages.typescript.enable = true;

  packages = [
    pkgs.biome
    pkgs.typos
  ];

  git-hooks.hooks = {
    biome = {
      enable = true;
      package = pkgs.biome;
    };
    typos = {
      enable = true;
      package = pkgs.typos;
    };
  };

  enterTest = ''
    nix_biome_version="$(${pkgs.biome}/bin/biome --version)"
    pnpm_biome_version="$(pnpm exec biome --version)"

    if [ "$nix_biome_version" != "$pnpm_biome_version" ]; then
      echo "Biome version mismatch:" >&2
      echo "  nix:  $nix_biome_version" >&2
      echo "  pnpm: $pnpm_biome_version" >&2
      exit 1
    fi
  '';
}
```

Create `biome.json` or `biome.jsonc` at the root opened by Zed. Zed then uses
Biome for JavaScript, JSX, TypeScript, TSX, CSS, JSON, and JSONC while keeping
vtsls active for TypeScript completion, type checking, navigation, and
refactoring.

This is a small starting `biome.json`:

```json
{
  "$schema": "./node_modules/@biomejs/biome/configuration_schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "files": {
    "ignoreUnknown": true
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "assist": {
    "actions": {
      "source": {
        "organizeImports": "on"
      }
    }
  }
}
```

For contributors and CI that do not use Nix, also pin the same Biome release in
the JavaScript project. From the active devenv Fish shell:

```fish
set biome_version (biome --version | string replace "Version: " "")
pnpm add --save-dev --save-exact @biomejs/biome@$biome_version
```

Check both versions whenever either lock file changes:

```sh
biome --version
pnpm exec biome --version
```

Run all configured hooks through devenv:

```sh
devenv test
```

After approving a newly created environment in an already-open Zed workspace,
run `workspace: reload` once. An unchanged environment should load directly on
later Zed launches and after reboot.
