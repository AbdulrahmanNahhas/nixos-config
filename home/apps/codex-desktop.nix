{ inputs, ... }:
{
  imports = [ inputs.codex-desktop-linux.homeManagerModules.default ];

  # Keep the bundled CLI and runtime adapters matched to the desktop package.
  programs.codexDesktopLinux.enable = true;

  # Disable the community launcher's usage-reporting ping.
  home.sessionVariables.CODEX_LINUX_DISABLE_USAGE_REPORTING = "1";
  systemd.user.sessionVariables.CODEX_LINUX_DISABLE_USAGE_REPORTING = "1";
}
