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

Java uses the declared Java extension and JDTLS for formatting on save. The extension resolves its Java runtime from the project's `JAVA_HOME` or PATH; no global JDK override is declared. Enable Java in the project's devenv configuration and approve its `.envrc`; Zed's `load_direnv = "direct"` imports that environment. Select a JDK compatible with the installed JDTLS version (Zed currently documents Java 21 or newer). Maven/Gradle and the Java target remain project-owned; open the project root containing `pom.xml` or `build.gradle`. The extension downloads JDTLS and supporting components unless a project-PATH `jdtls` launcher overrides it.

C and C++ use Zed's built-in support, explicitly selecting clangd for formatting on save. Zed prefers a working clangd from the project PATH and otherwise downloads one. `.clang-format` controls style; `compile_commands.json` or `.clangd` supplies compiler standards and include paths. For CMake, configure with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and expose the generated database at the project root, such as a symlink to `build/compile_commands.json`. The shared `-std=c++20` fallback is cleared so C files are not parsed with a C++-only flag. Build tools and debuggers stay in project environments. No new persistence paths are declared; build validation does not prove Java import, completion or editor formatting at runtime.

## Local AI costs

The optional local-AI module is currently parked. It would expose a loopback llama-swap endpoint and load models on demand. CUDA compilation can be expensive when Nixpkgs changes; importing the module has build consequences even if the service does not run at boot. Model files belong in retained storage and need their own space/backup policy. Provider-hosted inference has different privacy and account costs.

> When adapting another project’s setup, follow the target’s actual lockfile. A Bun project should not inherit pnpm assumptions just because a reference environment uses pnpm.
