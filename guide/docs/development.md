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
# In a new project directory:
devenv init --include-envrc
# Review the generated files before these approvals:
direnv allow
devenv allow
```

Home Manager's `programs.devenv` installs devenv and enables its native Fish hook. Home Manager groups devenv and direnv in `modules/home/shell/development.nix`; direnv is installed for Zed with its terminal hooks and nix-direnv disabled. System Nix daemon/cache/cleanup policy stays in `modules/nixos/core/nix.nix`, and plain shared tools remain in `modules/home/packages/development.nix`. Native devenv activates a trusted project in a subshell; Zed's `load_direnv = "direct"` reads the project's `.envrc` independently for editor tools and tasks. An integrated terminal that already has `DEVENV_ROOT` does not need another native activation.

For a new project, run `devenv init --include-envrc`, review the generated environment and `.envrc`, then run `direnv allow` and `devenv allow`. The approvals are separate: direnv approves `.envrc` contents, while devenv trusts the project directory. Changing `.envrc` requires renewed direnv approval. Existing projects need review and approvals, not another initialization.

Use the standard devenv and direnv commands rather than custom shell helpers. Approval permits environment setup code to execute. Projects using `use flake` or `use nix` no longer receive nix-direnv's environment caching and GC-root handling.

Commit the project's environment source and locks. Generated `.devenv`/`.direnv` state stays out of Git but should remain in a persistent project directory. Retained direnv approvals and devenv state avoid repeating trust setup every reboot. Verify that GC roots protect the environment's required store paths. This activation split does not fix missing caches or establish offline readiness: prepare dependencies while online, then test `devenv shell --offline` and the actual project workflow after reboot without networking. The Nix fetch/evaluation cache at `~/.cache/nix` is now declared persistent; devenv 2.4 keeps its evaluation database in each project's `.devenv` directory. Keep projects under `~/Projects` or another retained location. Global language/package-manager caches still need review for the actual project tooling; there is no blanket cache preservation.

## Editor ownership

Zed’s configuration is divided into settings, languages, LSP definitions, keymaps, and extensions because those are substantial. Delta comes from the official flake; its user configuration/state remains retained. Both still operate with application and agent permissions independent of package reproducibility.

JavaScript and TypeScript use project-local Oxc/Oxfmt and vtsls when available. Save actions use the dedicated Oxc fix action; broad `quickfix` automation stays disabled. TOML uses Tombi. The repository's `.zed/settings.json` recognizes Hugo layouts as Go HTML Template files so formatters preserve template syntax. The ownership and authentication notes live beside the module in `modules/home/programs/zed/README.md`; provider sessions and credentials remain runtime state.

Java uses the declared Java extension and JDTLS for formatting on save. The extension resolves its Java runtime from the project's `JAVA_HOME` or PATH; no global JDK override is declared. Enable Java in the project's devenv configuration and approve its `.envrc`; Zed's `load_direnv = "direct"` imports that environment. Select a JDK compatible with the installed JDTLS version (Zed currently documents Java 21 or newer). Maven/Gradle and the Java target remain project-owned; open the project root containing `pom.xml` or `build.gradle`. The extension downloads JDTLS and supporting components unless a project-PATH `jdtls` launcher overrides it.

C and C++ use Zed's built-in support, explicitly selecting clangd for formatting on save. Zed prefers a working clangd from the project PATH and otherwise downloads one. `.clang-format` controls style; `compile_commands.json` or `.clangd` supplies compiler standards and include paths. For CMake, configure with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and expose the generated database at the project root, such as a symlink to `build/compile_commands.json`. The shared `-std=c++20` fallback is cleared so C files are not parsed with a C++-only flag. Build tools and debuggers stay in project environments. No new persistence paths are declared; build validation does not prove Java import, completion or editor formatting at runtime.

## Local AI costs

The optional local-AI module is currently parked. It would expose a loopback llama-swap endpoint and load models on demand. CUDA compilation can be expensive when Nixpkgs changes; importing the module has build consequences even if the service does not run at boot. Model files belong in retained storage and need their own space/backup policy. Provider-hosted inference has different privacy and account costs.

> When adapting another project’s setup, follow the target’s actual lockfile. A Bun project should not inherit pnpm assumptions just because a reference environment uses pnpm.
