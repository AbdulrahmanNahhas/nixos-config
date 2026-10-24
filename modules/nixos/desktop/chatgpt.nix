{ inputs, ... }:
{
  imports = [ inputs.codex-desktop-linux.nixosModules.default ];

  # Use the bundled CLI for protocol compatibility and nix-ld for document runtimes.
  # Share ~/.codex with the standalone CLI; keep app-written config.toml mutable.
  programs.codexDesktopLinux.enable = true;

  # The community launcher otherwise pings a public GoatCounter once a day.
  environment.sessionVariables.CODEX_LINUX_DISABLE_USAGE_REPORTING = "1";
}
