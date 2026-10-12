{
  "title": "Project environments & editors",
  "group": "OPERATIONS",
  "weight": 15,
  "sources": [
    [
      "devenv getting started",
      "https://devenv.sh/getting-started/"
    ],
    [
      "direnv documentation",
      "https://direnv.net/"
    ],
    [
      "Delta’s Nix packaging",
      "https://github.com/zed-industries/delta-nix"
    ]
  ],
  "build": {
    "render": "link",
    "list": "always"
  }
}

Home Manager provides shared tools such as Zed, Delta, devenv, direnv, nixd, nixfmt, statix, and deadnix. Rust, Node, Bun, package managers, formatters, and language servers should follow each project’s requirements in its devenv configuration.

```
devenv-new my-project
# In an existing project with devenv.nix:
devenv-enable
```

Your helpers initialize a new environment without replacing an existing one, or add the canonical .envrc if missing. Review .envrc before approval: entering a directory with an approved .envrc can execute its environment setup. Changing its contents requires new approval.

Commit the project’s environment source and locks. Generated .devenv/.direnv state stays out of Git. Retained direnv approvals and devenv state avoid repeating trust setup every reboot. Nix GC roots protect referenced environments.

## Editor ownership

Zed’s configuration is divided into settings, languages, LSP definitions, keymaps, and extensions because those are substantial. Delta comes from the official flake; its user configuration/state remains retained. Both still operate with application and agent permissions independent of package reproducibility.

JavaScript and TypeScript use project-local Oxc/Oxfmt and vtsls when available. Save actions use the dedicated Oxc fix action; broad `quickfix` automation stays disabled. TOML uses Tombi. The repository's `.zed/settings.json` recognizes Hugo layouts as Go HTML Template files so formatters preserve template syntax. The ownership and authentication notes live beside the module in `modules/home/programs/zed/README.md`; provider sessions and credentials remain runtime state.

## Local AI costs

The optional local-AI module is currently parked. It would expose a loopback llama-swap endpoint and load models on demand. CUDA compilation can be expensive when Nixpkgs changes; importing the module has build consequences even if the service does not run at boot. Model files belong in retained storage and need their own space/backup policy. Provider-hosted inference has different privacy and account costs.

> When adapting another project’s setup, follow the target’s actual lockfile. A Bun project should not inherit pnpm assumptions just because a reference environment uses pnpm.
