{
  config,
  username,
  ...
}:
{
  imports = [
    ./home/desktop/umbriel
    ./home/desktop/niri
    ./home/desktop/noctalia
    ./home/desktop/menu
    ./home/desktop/gtk.nix
    ./home/desktop/xdg.nix
    ./home/desktop/dconf.nix
    ./home/desktop/bookmarks.nix
    ./home/desktop/launchers.nix

    ./home/terminal/starship.nix
    ./home/terminal/tools.nix
    ./home/terminal/nushell.nix
    ./home/terminal/ghostty
    ./home/terminal/yazi
    ./home/terminal/fastfetch.nix

    ./home/apps/herdr.nix
    ./home/apps/codex-desktop.nix
    ./home/apps/environment.nix
    ./home/apps/firefox
    ./home/apps/zed
    ./home/apps/helix
    ./home/apps/delta.nix
    ./home/apps/ai

    ./gaming/home.nix
    ./home/packages.nix
    ./home/secrets.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "zeditor --wait";
    };
  };

  programs.home-manager.enable = true;

  # Keep mutable Git settings in their existing persistent backing file.
  xdg.configFile."git/config".source =
    config.lib.file.mkOutOfStoreSymlink "/saved/home/${username}/.gitconfig";

  # Together with the 6 GiB Nix budget, leave headroom on this 16 GiB host.
  systemd.user.slices.build.Slice = {
    MemoryHigh = "3G";
    MemoryMax = "4G";
    MemorySwapMax = "2G";
  };

  # Decrypted at activation by sops-nix; the link contains no secret material.
  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/nix-config";
}
