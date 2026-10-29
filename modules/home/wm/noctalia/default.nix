{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.gpu-screen-recorder
    pkgs.slurp
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  # Read the runtime configuration rendered by sops-nix.
  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/rendered/noctalia-config.toml";

  xdg.configFile."noctalia-assets/nixos.svg".source = ./nixos.svg;
}
