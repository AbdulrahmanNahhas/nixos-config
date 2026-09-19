{ inputs, ... }:
{
  imports = [ inputs.codex-desktop-linux.nixosModules.default ];

  # Appears in the launcher as "ChatGPT Community" (blue C). One window for
  # ChatGPT, Work, and the Codex GUI; signs in through the GNOME keyring.
  # It uses the Codex CLI bundled in the .deb, so the GUI/app-server protocol
  # always matches, and shares ~/.codex (login, config.toml, AGENTS.md) with
  # pkgs.codex from home/programs/ai. Leave config.toml unmanaged: the app
  # rewrites it on every start.
  #
  # The NixOS module (not the Home Manager one) is used because it also adds
  # the app's workspace runtime libraries to nix-ld, which the document tools
  # it downloads into ~/.cache/codex-runtimes need.
  programs.codexDesktopLinux.enable = true;

  # The community launcher otherwise pings a public GoatCounter once a day.
  environment.sessionVariables.CODEX_LINUX_DISABLE_USAGE_REPORTING = "1";
}
